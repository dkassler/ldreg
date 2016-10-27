blkmean <- function(mat, k, d, r) {
  j <- k + d
  kbd <- max(1, k - r)
  jbd <- min(j + r, nrow(mat))
  ksel <- between(1:ncol(mat), kbd, k)
  jsel <- between(1:nrow(mat), j, jbd)
  submat <- mat[jsel, ksel]
  submat <- abs(submat)
  mean(submat)
}

diagmean <- function(mat, d, r) {
  N <- min(nrow(mat), ncol(mat))
  sapply(1:(N - d), function(.) blkmean(mat, ., d, r))
}
