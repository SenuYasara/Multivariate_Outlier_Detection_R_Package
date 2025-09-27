#' Detect Multivariate Outliers
#'
#' Detects multivariate outliers using Mahalanobis, Minimum Covariance Determinant (MCD), or PCA-based distances.
#' Supports robust detection by computing distance scores for each observation and comparing them against
#' a chi-squared cutoff at a specified significance level.
#'
#' @param data A numeric data frame or matrix.
#' @param method Outlier detection method: "mahalanobis", "mcd", or "pca".
#' @param alpha Significance level (default = 0.975).
#'
#' @return A data frame combining the original input data with distances and outlier flags.
#' @importFrom stats cov prcomp qchisq
#' @export
detect_multivariate_outliers <- function(data, method = "mahalanobis", alpha = 0.975) {
  # must be numeric
  if (!all(sapply(data, is.numeric))) {
    stop("All columns in 'data' must be numeric.")
  }

  # must not contain missing values
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

    # check invertibility using determinant + tryCatch
    if (abs(det(S)) < .Machine$double.eps) {
      stop("Covariance matrix is singular")
    }

    distances <- tryCatch(
      {
        S_inv <- solve(S)
        mahalanobis_cpp(data_scaled, mu, S_inv)
      },
      error = function(e) stop("Covariance matrix is singular")
    )

  } else if (method == "mcd") {
    rob <- MASS::cov.rob(data_scaled, method = "mcd")
    mu <- rob$center
    S <- rob$cov

    if (abs(det(S)) < .Machine$double.eps) {
      stop("MCD covariance matrix is singular")
    }

    distances <- tryCatch(
      {
        S_inv <- solve(S)
        mahalanobis_cpp(data_scaled, mu, S_inv)
      },
      error = function(e) stop("MCD covariance matrix is singular")
    )

  } else if (method == "pca") {
    pca_result <- prcomp(data_scaled, center = FALSE, scale. = FALSE)
    explained_variance <- cumsum(pca_result$sdev^2) / sum(pca_result$sdev^2)
    k <- which(explained_variance >= 0.90)[1]

    scores <- pca_result$x[, 1:k, drop = FALSE]
    center_pca <- colMeans(scores)
    distances <- pca_distances_cpp(scores, center_pca)
    cutoff <- qchisq(alpha, df = k)

  } else {
    stop("Invalid method. Choose from 'mahalanobis', 'mcd', or 'pca'.")
  }

  outlier_flag <- distances > cutoff
  result <- cbind(data, Distance = distances, Outlier = outlier_flag)

  return(as.data.frame(result))
}
