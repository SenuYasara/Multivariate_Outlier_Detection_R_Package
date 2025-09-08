# Tests for plot_outliers_pairwise()

test_that("plot_outliers_pairwise rejects non-numeric data", {
  df <- data.frame(x = 1:5, y = letters[1:5])
  expect_error(
    plot_outliers_pairwise(df),"must be numeric")
})

test_that("plot_outliers_pairwise rejects datasets with NA values", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  df[1, 1] <- NA
  expect_error(
    plot_outliers_pairwise(df),"missing values")
})

test_that("plot_outliers_pairwise requires at least two columns", {
  df <- data.frame(x = rnorm(10))
  expect_error(
    plot_outliers_pairwise(df, method = "mahalanobis"),
    "Need at least two numeric columns")
})

# test_that("plot_outliers_pairwise errors for invalid method", {
#   df <- data.frame(x = rnorm(10), y = rnorm(10))
#   expect_error(plot_outliers_pairwise(df, method = "invalid"), "Invalid method")
# })

test_that("plot_outliers_pairwise errors for invalid method", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  expect_error(
    plot_outliers_pairwise(df, method = "pca"),
    regexp = "should be one of")
})


test_that("plot_outliers_pairwise returns a gtable for 2D data (mahalanobis)", {
  set.seed(123)
  df <- data.frame(x = rnorm(40), y = rnorm(40))
  p <- plot_outliers_pairwise(df, method = "mahalanobis")
  expect_s3_class(p, "gtable")
  # should not warn
  expect_warning(plot_outliers_pairwise(df, method = "mahalanobis"), NA)
})

test_that("plot_outliers_pairwise returns a gtable for >2D data (mahalanobis)", {
  set.seed(123)
  df <- data.frame(x = rnorm(30), y = rnorm(30), z = rnorm(30))
  p <- plot_outliers_pairwise(df, method = "mahalanobis")
  expect_s3_class(p, "gtable")
})

# test_that("plot_outliers_pairwise works with 'mcd' method", {
#   set.seed(123)
#   df <- data.frame(x = rnorm(30), y = rnorm(30))
#   p <- plot_outliers_pairwise(df, method = "mcd")
#   expect_s3_class(p, "gtable")
# })

