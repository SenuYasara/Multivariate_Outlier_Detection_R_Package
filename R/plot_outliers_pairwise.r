#' Plot Pairwise Outliers
#'
#' Generates 2D scatterplots for each pair of variables in the dataset,
#' with distances computed using Mahalanobis or robust MCD.
#'
#' @param data A numeric data frame or matrix.
#' @param method Outlier detection method: "mahalanobis" or "mcd".
#' @param alpha The quantile cutoff for identifying outliers (default 0.975).
#'
#' @import ggplot2
#' @importFrom gridExtra grid.arrange
#' @importFrom cowplot get_legend
#' @export
plot_outliers_pairwise <- function(data, method = c("mahalanobis", "mcd"), alpha = 0.975) {
  method <- match.arg(method)

  if (!is.data.frame(data)) data <- as.data.frame(data)

  # check numeric
  if (!all(sapply(data, is.numeric))) stop("All columns in 'data' must be numeric.")

  # check NA
  if (anyNA(data)) stop("Dataset cannot contain missing values.")

  p <- ncol(data)
  plots <- list()
  k <- 1

  for (i in 1:(p - 1)) {
    for (j in (i + 1):p) {
      pair_data <- data[, c(i, j)]
      mu <- colMeans(pair_data)

      if (method == "mahalanobis") {
        cov_matrix <- cov(pair_data)
        Sinv <- solve(cov_matrix)
        dists <- mahalanobis_cpp(as.matrix(pair_data), mu, Sinv)
        threshold <- qchisq(alpha, df = 2)

      } else if (method == "mcd") {
        rob <- MASS::cov.rob(pair_data, method = "mcd")
        mu <- rob$center
        cov_matrix <- rob$cov
        Sinv <- solve(cov_matrix)
        dists <- mahalanobis_cpp(as.matrix(pair_data), mu, Sinv)
        threshold <- qchisq(alpha, df = 2)

      } else {
        stop("Invalid method. Choose 'mahalanobis' or 'mcd'.")
      }

      is_outlier <- dists > threshold
      plot_data <- data.frame(
        x = pair_data[, 1],
        y = pair_data[, 2],
        outlier = factor(is_outlier)
      )

      p1 <- ggplot(plot_data, aes(x = x, y = y, color = outlier)) +
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
