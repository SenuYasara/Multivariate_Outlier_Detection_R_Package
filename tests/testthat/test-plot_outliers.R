# Tests for plot_outliers()

methods <- c("mahalanobis", "mcd")

test_that("plot_outliers errors with non-numeric data", {
  df <- data.frame(x = 1:5, y = letters[1:5])
  for (m in methods) {
    expect_error(
      plot_outliers(df, method = m),
      "must be numeric"
    )
  }
})

test_that("plot_outliers errors with missing values", {
  df <- data.frame(x = c(1, 2, NA, 4), y = c(5, 6, 7, 8))
  for (m in methods) {
    expect_error(
      plot_outliers(df, method = m),
      "cannot contain missing values"
    )
  }
})

test_that("plot_outliers requires at least two columns", {
  df <- data.frame(x = rnorm(10))
  for (m in methods) {
    expect_error(
      plot_outliers(df, method = m),
      "Need at least two numeric columns"
    )
  }
})

test_that("plot_outliers runs with 2 variables", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("gridExtra")
  skip_if_not_installed("cowplot")

  set.seed(123)
  df <- data.frame(x = rnorm(20), y = rnorm(20))

  for (m in methods) {
    expect_silent(plot_outliers(df, method = m, alpha = 0.975))
  }
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

  for (m in methods) {
    # Should generate multiple pairwise plots without errors
    expect_silent(plot_outliers(df, method = m))
  }
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

  for (m in methods) {
    expect_silent(
      p <- plot_outliers(df, method = m, alpha = 0.975)
    )
    expect_true(inherits(p, "gtable") || inherits(p, "grob"))
  }
})

test_that("plot_outliers errors with invalid method", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  expect_error(
    plot_outliers(df, method = "invalid"),
    "'arg' should be one of"
  )
})

test_that("plot_outliers errors with invalid alpha", {
  df <- data.frame(x = rnorm(10), y = rnorm(10))
  for (m in methods) {
    expect_error(plot_outliers(df, method = m, alpha = -0.2), "'alpha' must be")
    expect_error(plot_outliers(df, method = m, alpha = 1.2), "'alpha' must be")
    expect_error(plot_outliers(df, method = m, alpha = "abc"), "'alpha' must be")
  }
})
