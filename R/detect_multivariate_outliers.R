#' Detect Multivariate Outliers
#'
#' Detects multivariate outliers using Mahalanobis, Minimum Covariance Determinant(MCD), or PCA-based distances.
#' This function supports robust statistical detection by computing distance scores for each observation and comparing them against a chi-squared cutoff at a specified significance level.
#' It is useful for identifying outliers in high-dimensional continuous data.
#'
#' @param data A numeric data frame or matrix.
#' @param method Outlier detection method: "mahalanobis", "mcd", or "pca"
#' @param alpha Significance level (default = 0.975)
#'
#' @return A data frame combining the original input data with distances and outlier flags
#' @importFrom stats cov prcomp qchisq
#' @export
#' @examples
#' # 1: Simulated Data
#' set.seed(123)
#' df <- data.frame(x = c(rnorm(50), 6),y = c(rnorm(50), 6))
#'
#' ## Mahalanobis Distance
#' result_mahal <- detect_multivariate_outliers(df, method = "mahalanobis", alpha = 0.975)
#' head(result_mahal)
#'
#' ## Minimum Covariance Determinant (MCD)
#'result_mcd <- detect_multivariate_outliers(df, method = "mcd", alpha = 0.975)
#'head(result_mcd)
#'
#'## Principal Component Analysis (PCA)
#'result_pca <- detect_multivariate_outliers(df, method = "pca", alpha = 0.975)
#'head(result_pca)
#'
#' # 2: Existing Dataset (mtcars)
#' df_mtcars <- mtcars[, c("mpg", "hp", "wt" )]
#' head(df_mtcars)
#'
#'## Mahalanobis Distance
#' result_mahal <- detect_multivariate_outliers(df_mtcars, method = "mahalanobis")
#' head(result_mahal)
#'
#' ## Minimum Covariance Determinant (MCD)
#' result_mcd <- detect_multivariate_outliers(df_mtcars, method = "mcd")
#' head(result_mcd)
#'
#'## Principal Component Analysis (PCA)
#'result_pca <- detect_multivariate_outliers(df_mtcars, method = "pca")
#'head(result_pca)
#'
#' # View outliers
#' result_mahal[result_mahal$Outlier == TRUE, ]
#' result_mcd[result_mcd$Outlier == TRUE, ]
#' result_pca[result_pca$Outlier == TRUE, ]

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

    # check invertibility of covariance
    if (det(S) == 0) {
      stop("Covariance matrix is singular. Try dropping collinear columns,
           increasing sample size, or use method = 'pca'.")
    }

    S_inv <- solve(S)
    distances <- mahalanobis_cpp(data_scaled, mu, S_inv)

  } else if (method == "mcd") {
    rob <- MASS::cov.rob(data_scaled, method = "mcd")
    mu <- rob$center
    S <- rob$cov

    if (det(S) == 0) {
      stop("MCD covariance matrix is singular. Try reducing collinearity or use method = 'pca'.")
    }

    S_inv <- solve(S)
    distances <- mahalanobis_cpp(data_scaled, mu, S_inv)

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
