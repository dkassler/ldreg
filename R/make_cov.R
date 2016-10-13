library(Matrix)

make_cov.bdiag <- function(N, size, blk = 1) {
  dblock <- function(n, fill = blk) {
    m <- matrix(fill, nrow = n, ncol = n)
    diag(m) <- 1
    m
  }
  blocksize <- function(n, blocks) {
    x <- sort(sample(n-1, blocks-1))
    y <- c(0, x, n)
    z <- y - dplyr::lag(y)
    z[-1]
  }
  blocks <- lapply(blocksize(N, round(N / size)), dblock)
  bdiag(blocks)
}

