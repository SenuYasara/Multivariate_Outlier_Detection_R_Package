# Tests for detect_multivariate_outliers()

test_that("detect_multivariate_outliers rejects non-numeric data", {
  df <- data.frame(x = 1:5, y = letters[1:5])
  expect_error(
    detect_multivariate_outliers(df, method = "mahalanobis"),
    "must be numeric"
  )
})

test_that("detect_multivariate_outliers rejects datasets with NA values", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  df[1, 1] <- NA
  expect_error(
    detect_multivariate_outliers(df, method = "mahalanobis"),
    "missing values"
  )
})

test_that("detect_multivariate_outliers works with mahalanobis method", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = rnorm(50))
  result <- detect_multivariate_outliers(df, method = "mahalanobis")

  expect_s3_class(result, "data.frame")
  expect_true(all(c("Distance", "Outlier") %in% names(result)))
  expect_equal(nrow(result), nrow(df))
})

test_that("detect_multivariate_outliers works with mcd method", {
  set.seed(123)
  df <- data.frame(x = rnorm(30), y = rnorm(30))
  result <- detect_multivariate_outliers(df, method = "mcd")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), nrow(df))
})

test_that("detect_multivariate_outliers works with pca method", {
  set.seed(123)
  df <- data.frame(x = rnorm(40), y = rnorm(40), z = rnorm(40))
  result <- detect_multivariate_outliers(df, method = "pca")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), nrow(df))
})

test_that("detect_multivariate_outliers throws error for invalid method", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  expect_error(detect_multivariate_outliers(df, method = "invalid"), "Invalid method")
})

test_that("detect_multivariate_outliers errors with singular covariance matrix", {
  df <- data.frame(x = rnorm(20), y = rnorm(20))
  df$dup <- df$x + 2 * df$y
  expect_error(
    detect_multivariate_outliers(df, method = "mahalanobis"),
    "Covariance matrix is singular"
  )
})





























#
# test_that("The package gives helpful errors for invalid inputs", {
#   # non-numeric columns
#   df <- data.frame(x = 1:5, y = letters[1:5])
#   expect_error(
#     detect_multivariate_outliers(df, method = "mahalanobis"),
#     "All columns in data must be numeric")
#
#   # missing values
#   df <- data.frame(x = rnorm(10), y = rnorm(10))
#   df[1, 1] <- NA
#   expect_error(
#     detect_multivariate_outliers(df, method = "mahalanobis"),
#     "Dataset cannot contain missing values")
#
#
#
#
#
#
#
#
#
# })
#
# test_that("detect_multivariate_outliers works with mahalanobis method", {
#   set.seed(123)
#   df <- data.frame(x = rnorm(50), y = rnorm(50))
#   result <- detect_multivariate_outliers(df, method = "mahalanobis")
#
#   expect_s3_class(result, "data.frame")
#   expect_true(all(c("Distance", "Outlier") %in% names(result)))
#   expect_equal(nrow(result), nrow(df))
# })
#
# test_that("detect_multivariate_outliers works with mcd method", {
#   set.seed(123)
#   df <- data.frame(x = rnorm(30), y = rnorm(30))
#   result <- detect_multivariate_outliers(df, method = "mcd")
#
#   expect_s3_class(result, "data.frame")
#   expect_equal(nrow(result), nrow(df))
# })
#
# test_that("detect_multivariate_outliers works with pca method", {
#   set.seed(123)
#   df <- data.frame(x = rnorm(40), y = rnorm(40), z = rnorm(40))
#   result <- detect_multivariate_outliers(df, method = "pca")
#
#   expect_s3_class(result, "data.frame")
#   expect_equal(nrow(result), nrow(df))
# })
#
# test_that("detect_multivariate_outliers throws error for invalid method", {
#   df <- data.frame(x = rnorm(10), y = rnorm(10))
#   expect_error(detect_multivariate_outliers(df, method = "invalid"), "Invalid method")
# })
#
# test_that("detect_multivariate_outliers errors with singular covariance matrix", {
#   df <- data.frame(x = rnorm(20), y = rnorm(20))
#   df$dup <- df$x + 2 * df$y
#   expect_error(
#     detect_multivariate_outliers(df, method = "mahalanobis"),
#     "Covariance matrix is singular"
#   )
# })
#
