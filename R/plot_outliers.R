#' Plot Pairwise Outliers
#'
#' Generates 2D scatterplots for each pair of variables in the dataset,
#' with outliers identified using Mahalanobis or MCD distances
#' computed across all variables, without including each observation
#' in its own distance calculation.
#'
#' @param data A numeric data frame or matrix.
#' @param method Outlier detection method: "mahalanobis" or "mcd".
#' @param alpha The quantile cutoff for identifying outliers (default 0.975).
#'
#' @import ggplot2
#' @importFrom gridExtra grid.arrange
#' @importFrom cowplot get_legend
#' @importFrom rlang .data
#' @export
#' @examples
#'df_mtcars <- mtcars[, c("mpg", "hp", "wt" )]
#'head(df_mtcars)
#'
#'## Pairwise Plots: Mahalanobis
#'plot_outliers(df_mtcars, method = "mahalanobis", alpha = 0.975)
#'
#'## Pairwise Plots: MCD
#'plot_outliers(df_mtcars, method = "mcd", alpha = 0.975)

plot_outliers <- function(data, method = c("mahalanobis", "mcd"), alpha = 0.975) {
  method <- match.arg(method)

  if (!is.data.frame(data)) data <- as.data.frame(data)

  # check numeric
  if (!all(sapply(data, is.numeric))) stop("All columns in 'data' must be numeric.")

  # check NA
  if (anyNA(data)) stop("Dataset cannot contain missing values.")

  # need at least two numeric columns
  if (ncol(data) < 2) stop("Need at least two numeric columns")

  # check alpha
  if (!is.numeric(alpha) || length(alpha) != 1 || alpha <= 0 || alpha >= 1) {
    stop("'alpha' must be a single numeric value between 0 and 1")
  }

  n <- nrow(data)
  p <- ncol(data)
  dists <- numeric(n)

  # Compute leave-one-out Mahalanobis/MCD distances
  for (i in 1:n) {
    data_minus_i <- data[-i, , drop = FALSE] # For each observation i, remove that observation from the dataset.

    if (method == "mahalanobis") {
      mu <- colMeans(data_minus_i) # Compute the mean and covariance from the other nâ1 observations.
      cov_matrix <- cov(data_minus_i)

    } else if (method == "mcd") {
      rob <- MASS::cov.rob(data_minus_i, method = "mcd") # Compute robust center and covariance using the Minimum Covariance Determinant.
      mu <- rob$center
      cov_matrix <- rob$cov
    }else {
      stop("Invalid method. Choose from 'mahalanobis'or 'mcd'.")
    }

    Sinv <- solve(cov_matrix) # Invert the covariance matrix.
    dists[i] <- mahalanobis_cpp(as.matrix(data[i, , drop = FALSE]), mu, Sinv) # Compute the Mahalanobis distance of the left-out observation from the mean of the others.
  }

  threshold <- qchisq(alpha, df = p) # Chi-square threshold with p degrees of freedom.
  is_outlier <- dists > threshold # If a distance is bigger, the point is flagged as an outlier.

  # Build pairwise scatterplots, colored by global outlier flag
  plots <- list()
  k <- 1

  for (i in 1:(p - 1)) {
    for (j in (i + 1):p) {
      plot_data <- data.frame( # Loop over all unique pairs of variables
        x = data[, i],
        y = data[, j],
        outlier = factor(is_outlier)
      )

      p1 <- ggplot(plot_data, aes(x = .data$x, y = .data$y, color = .data$outlier)) +
        geom_point() +
        labs(
          title = paste0("Vars: ", names(data)[i], " vs ", names(data)[j]),
          x = names(data)[i], y = names(data)[j]
        ) +
        theme_minimal() +
        scale_color_manual(values = c("black", "red"),
                           labels = c("Inlier", "Outlier"),
                           name = "Status")

      plots[[k]] <- p1
      k <- k + 1
    }
  }

  legend <- suppressWarnings(cowplot::get_legend(plots[[1]] + guides(color = guide_legend())))
  plots_no_legend <- lapply(plots, function(p) p + theme(legend.position = "none"))

  gridExtra::grid.arrange(
    do.call(gridExtra::arrangeGrob, c(plots_no_legend, ncol = 2)),
    legend,
    nrow = 2,
    heights = c(10, 1)
  )
}

