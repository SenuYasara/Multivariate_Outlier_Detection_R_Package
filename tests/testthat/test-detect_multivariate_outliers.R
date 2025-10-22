# Tests for detect_multivariate_outliers()

methods <- c("mahalanobis", "mcd", "pca")

test_that("detect_multivariate_outliers rejects non-numeric data", {
  df <- data.frame(x = 1:5, y = letters[1:5])
  for (m in methods) {
    expect_error(
      detect_multivariate_outliers(df, method = m),
      "must be numeric"
    )
  }
})

test_that("detect_multivariate_outliers rejects datasets with NA values", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  df[1, 1] <- NA
  for (m in methods) {
    expect_error(
      detect_multivariate_outliers(df, method = m),
      "missing values"
    )
  }
})

test_that("detect_multivariate_outliers rejects datasets with only one variable", {
  df <- data.frame(x = rnorm(10))
  for (m in methods) {
    expect_error(
      detect_multivariate_outliers(df, method = m),
      "at least two numeric variables"
    )
  }
})

test_that("detect_multivariate_outliers errors with singular covariance matrix (Mahalanobis only)", {
  set.seed(123)
  df <- data.frame(x = rnorm(20), y = rnorm(20))
  df$dup <- df$x + 2 * df$y  # Linear dependency

  expect_error(
    detect_multivariate_outliers(df, method = "mahalanobis"),
    "Covariance matrix is singular"
  )
})

test_that("detect_multivariate_outliers works correctly for all valid methods", {
  set.seed(123)
  df <- data.frame(x = rnorm(50), y = rnorm(50), z = rnorm(50))
  for (m in methods) {
    result <- detect_multivariate_outliers(df, method = m)
    expect_s3_class(result, "data.frame")
    expect_true(all(c("Distance", "Outlier") %in% names(result)))
    expect_equal(nrow(result), nrow(df))
  }
})

test_that("detect_multivariate_outliers throws error for invalid method", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  expect_error(
    detect_multivariate_outliers(df, method = "invalid"),
    "Invalid method"
  )
})

test_that("detect_multivariate_outliers errors with invalid alpha", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  for (m in methods) {
    expect_error(
      detect_multivariate_outliers(df, method = m, alpha = -0.1),
      "'alpha' must be"
    )
    expect_error(
      detect_multivariate_outliers(df, method = m, alpha = 1.5),
      "'alpha' must be"
    )
    expect_error(
      detect_multivariate_outliers(df, method = m, alpha = "abc"),
      "'alpha' must be"
    )
  }
})






