#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]

NumericVector mahalanobis_cpp(NumericMatrix X, NumericVector mu, NumericMatrix Sinv) {
  int n = X.nrow();// number of observations
  int p = X.ncol();// number of variables
  NumericVector result(n);// output vector of distances

  for (int i = 0; i < n; ++i) {
    NumericVector row = X(i, _) - mu; // subtract mean vector from the ith row
    NumericVector tmp(p); // to store intermediate result: Sinv * (X[i,] - mu)

    for (int j = 0; j < p; ++j) {
      for (int k = 0; k < p; ++k) {
        tmp[j] += Sinv(j, k) * row[k];
      }
    }

    double dist = 0.0;
    for (int j = 0; j < p; ++j) {
      dist += row[j] * tmp[j]; // (X[i,]-mu)^T * Sinv * (X[i,]-mu)
    }

    result[i] = dist;
  }

  return result;
}

// [[Rcpp::export]]
NumericVector pca_distances_cpp(NumericMatrix scores, NumericVector center) {
  int n = scores.nrow();
  int k = scores.ncol();
  NumericVector result(n);

  for (int i = 0; i < n; ++i) {
    double dist = 0.0;
    for (int j = 0; j < k; ++j) {
      double diff = scores(i, j) - center[j];
      dist += diff * diff;
    }
    result[i] = dist;
  }

  return result;
}
