blkmean <- function(mat, k, d, r) {
  j <- k + d
  kbd <- max(1, k - r)
  jbd <- min(j + r, nrow(mat))
  ksel <- dplyr::between(1:ncol(mat), kbd, k)
  jsel <- dplyr::between(1:nrow(mat), j, jbd)
  submat <- mat[jsel, ksel]
  submat <- abs(submat)
  mean(submat)
}

diagmean <- function(mat, d, r) {
  N <- min(nrow(mat), ncol(mat))
  sapply(1:(N - d), function(.) blkmean(mat, ., d, r))
}

zero_out <- function(mat, kvec) {
  if (is.logical(kvec)) {
    len <- min(nrow(mat), ncol(mat)) - 1
    kvec <- rep(kvec, length = len)
    kvec <- which(kvec)
  }
  for (k in kvec) {
    j <- k + 1
    mat[1:nrow(mat) >= j, 1:ncol(mat) <= k] <- 0
    mat[1:nrow(mat) <= k, 1:ncol(mat) >= j] <- 0
  }
  mat
}

weed <- function(mat, diag = 1, blk = 100, thresh = NULL, quant = NULL) {
  dm <- diagmean(mat, diag, blk)
  if (!is.null(quant)) thresh <- quantile(dm, quant)
  sel <- dm < thresh
  message(sprintf("%s of possible blocks set to zero.",
                  scales::percent(mean(sel))))
  zero_out(mat, sel)
}
