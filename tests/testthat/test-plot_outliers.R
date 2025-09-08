
# Tests for plot_outliers()

test_that("plot_outliers errors if plotly not installed", {
  if (requireNamespace("plotly", quietly = TRUE)) {
    skip("plotly is installed, so test skipped")
  } else {
    expect_error(plot_outliers(mtcars, "mpg", "disp"),
                 "Package 'plotly' needed")
  }
})


test_that("plot_outliers returns a plotly object for 2D", {
  skip_if_not_installed("plotly")
  df <- data.frame(x = rnorm(20), y = rnorm(20))
  fig <- plot_outliers(df)
  expect_s3_class(fig, "plotly")
})


test_that("plot_outliers returns a plotly object for 3D", {
  skip_if_not_installed("plotly")
  df <- data.frame(x = rnorm(20), y = rnorm(20), z = rnorm(20))
  fig <- plot_outliers(df)
  expect_s3_class(fig, "plotly")
})


test_that("plot_outliers errors with wrong dimensionality", {
  df <- as.data.frame(matrix(rnorm(200), ncol = 4))
  expect_error(plot_outliers(df), "supports only 2 or 3 variables")
})



