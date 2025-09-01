#' Plot Multivariate Outliers (2D or 3D)
#'
#' Generates 2D or 3D scatterplots using plotly for datasets with 2 or 3 variables,
#' with distances computed using Mahalanobis, MCD, or PCA methods.
#'
#' @param data A numeric data frame or matrix with 2 or 3 columns.
#' @param method "mahalanobis" or "mcd"
#' @param alpha The quantile cutoff for identifying outliers (default 0.975).
#'
#' @importFrom plotly plot_ly
#' @export
plot_outliers <- function(data, method = "mahalanobis", alpha = 0.975) {
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("Package 'plotly' is required. Please install it.")
  }

  if (!is.data.frame(data)) data <- as.data.frame(data)

  if (!(ncol(data) %in% c(2, 3))) {
    stop("This function supports only 2 or 3 variables for plotting.")
  }

  # check numeric
  if (!all(sapply(data, is.numeric))) {
    stop("All columns in 'data' must be numeric.")
  }

  # check NA
  if (anyNA(data)) {
    stop("Dataset cannot contain missing values.")
  }

  n <- nrow(data)
  p <- ncol(data)
  data_scaled <- scale(data)

  cutoff <- qchisq(alpha, df = p)

  if (method == "mahalanobis") {
    mu <- colMeans(data_scaled)
    S <- cov(data_scaled)
    S_inv <- solve(S)
    dists <- mahalanobis_cpp(data_scaled, mu, S_inv)
    plot_data <- data
    var_names <- names(data)

  } else if (method == "mcd") {
    rob <- MASS::cov.rob(data_scaled, method = "mcd")
    mu <- rob$center
    S <- rob$cov
    S_inv <- solve(S)
    dists <- mahalanobis_cpp(data_scaled, mu, S_inv)
    plot_data <- data
    var_names <- names(data)

  }else {
    stop("Invalid method. Choose from 'mahalanobis'or 'mcd'.")
  }

  is_outlier <- dists > cutoff
  plot_data$Outlier <- factor(is_outlier, levels = c(FALSE, TRUE),
                              labels = c("Inlier", "Outlier"))

  # ==================
  # PLOTTING
  # ==================
  if (ncol(plot_data) - 1 == 2) {
    plot_data$hover <- apply(plot_data[, 1:2], 1, function(row) {
      paste0(var_names[1], ": ", round(row[1], 3), "<br>",
             var_names[2], ": ", round(row[2], 3))
    })

    fig <- plotly::plot_ly(
      plot_data, x = ~plot_data[[1]], y = ~plot_data[[2]],
      text = ~hover,
      color = ~Outlier, colors = c("black", "red"),
      type = 'scatter', mode = 'markers',
      hoverinfo = "text"
    ) %>%
      plotly::layout(
        title = paste("2D Outlier Detection (", method, ")", sep = ""),
        xaxis = list(title = var_names[1]),
        yaxis = list(title = var_names[2])
      )

  } else if (ncol(plot_data) - 1 == 3) {
    plot_data$hover <- apply(plot_data[, 1:3], 1, function(row) {
      paste0(var_names[1], ": ", round(row[1], 3), "<br>",
             var_names[2], ": ", round(row[2], 3), "<br>",
             var_names[3], ": ", round(row[3], 3))
    })

    fig <- plotly::plot_ly(
      plot_data, x = ~plot_data[[1]], y = ~plot_data[[2]], z = ~plot_data[[3]],
      text = ~hover,
      color = ~Outlier, colors = c("black", "red"),
      type = 'scatter3d', mode = 'markers',
      hoverinfo = "text"
    ) %>%
      plotly::layout(
        title = paste("3D Outlier Detection (", method, ")", sep = ""),
        scene = list(
          xaxis = list(title = var_names[1]),
          yaxis = list(title = var_names[2]),
          zaxis = list(title = var_names[3])
        )
      )
  }

  fig
}





#' #' Plot Pairwise Mahalanobis Outliers
#' #'
#' #' Generates 2D scatterplots for each pair of variables in the dataset,
#' #' with Mahalanobis distances computed using only the plotted variables.
#' #'
#' #' @param data A numeric data frame or matrix.
#' #' @param cutoff The quantile cutoff for identifying outliers (default 0.975).
#' #'
#' #' @import ggplot2
#' #' @importFrom gridExtra grid.arrange
#' #' @importFrom cowplot get_legend plot_grid
#' #' @export
#' plot_outliers <- function(data, cutoff = 0.975) {
#'   p <- ncol(data)
#'   plots <- list()
#'   k <- 1
#'
#'   for (i in 1:(p - 1)) {
#'     for (j in (i + 1):p) {
#'       pair_data <- data[, c(i, j)]
#'       mu <- colMeans(pair_data)
#'       cov_matrix <- cov(pair_data)
#'       Sinv <- solve(cov_matrix)
#'
#'       dists <- mahalanobis_cpp(as.matrix(pair_data), mu, Sinv)
#'       threshold <- qchisq(cutoff, df = 2)
#'       is_outlier <- dists > threshold
#'
#'       plot_data <- data.frame(x = pair_data[, 1],
#'                               y = pair_data[, 2],
#'                               outlier = factor(is_outlier))
#'
#'       # Plot with legend for the first one only
#'       p1 <- ggplot(plot_data, aes(x = x, y = y, color = outlier)) +
#'         geom_point() +
#'         labs(
#'           title = paste0("Vars: ", names(data)[i], " vs ", names(data)[j]),
#'           x = names(data)[i], y = names(data)[j]
#'         ) +
#'         theme_minimal() +
#'         scale_color_manual(values = c("black", "red"),
#'                            labels = c("Inlier", "Outlier"),
#'                            name = "Status")
#'
#'       plots[[k]] <- p1
#'       k <- k + 1
#'     }
#'   }
#'
#'   # Extract legend from first plot
#'   legend <- suppressWarnings(cowplot::get_legend(plots[[1]] + guides(color = guide_legend())))
#'
#'
#'
#'   # Remove legends from all plots
#'   plots_no_legend <- lapply(plots, function(p) p + theme(legend.position = "none"))
#'
#'   # Arrange plots and legend
#'   gridExtra::grid.arrange(
#'     do.call(gridExtra::arrangeGrob, c(plots_no_legend, ncol = 2)),
#'     legend,
#'     nrow = 2,
#'     heights = c(10, 1)
#'   )
#' }
