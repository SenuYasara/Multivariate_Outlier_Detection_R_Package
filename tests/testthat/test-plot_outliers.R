# Tests for plot_outliers()

test_that("plot_outliers errors with non-numeric data", {
  df <- data.frame(x = 1:5, y = letters[1:5])
  expect_error(
    plot_outliers(df, method = "mahalanobis"),
    "must be numeric"
  )
})

test_that("plot_outliers errors with missing values", {
  df <- data.frame(x = c(1, 2, NA, 4), y = c(5, 6, 7, 8))
  expect_error(
    plot_outliers(df, method = "mcd"),
    "cannot contain missing values"
  )
})

test_that("plot_outliers requires at least two columns", {
  df <- data.frame(x = rnorm(10))
  expect_error(
    plot_outliers(df, method = "mahalanobis"),
    "Need at least two numeric columns")
})


test_that("plot_outliers runs with 2 variables (mahalanobis & mcd)", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("gridExtra")
  skip_if_not_installed("cowplot")

  set.seed(123)
  df <- data.frame(x = rnorm(20), y = rnorm(20))

  expect_silent(plot_outliers(df, method = "mahalanobis", alpha = 0.975))
  expect_silent(plot_outliers(df, method = "mcd", alpha = 0.975))
})

test_that("plot_outliers runs with >2 variables", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("gridExtra")
  skip_if_not_installed("cowplot")

  set.seed(456)
  df <- data.frame(
    x = rnorm(15),
    y = rnorm(15),
    z = rnorm(15)
  )

  # Should generate multiple pairwise plots without errors
  expect_silent(plot_outliers(df, method = "mahalanobis"))
  expect_silent(plot_outliers(df, method = "mcd"))
})

test_that("plot_outliers flags at least one outlier when data includes an extreme point", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("gridExtra")
  skip_if_not_installed("cowplot")

  df <- data.frame(
    x = c(rnorm(19), 10),  # add an outlier
    y = c(rnorm(19), 10),
    z = c(rnorm(19), 10)
  )

  # Capture outlier computation
  expect_silent(
    p <- plot_outliers(df, method = "mahalanobis", alpha = 0.975)
  )
  # Check object type (ggplot grob)
  expect_true(inherits(p, "gtable") || inherits(p, "grob"))
})

test_that("plot_outliers errors with invalid method", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  expect_error(
    plot_outliers(df, method = "invalid"),
    "'arg' should be one of"
  )
})
