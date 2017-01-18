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
  Matrix::bdiag(blocks)
}

matheat <- function(r, ...) {
  pal <- plotrix::smoothColors(scales::muted("red"), 100, "white", 100, scales::muted("blue"))
  rg <- range(r, na.rm = T)
  rg <- round((rg + 1) * 101 + 1)
  pal <- pal[(rg[1]):(rg[2])]
  heatmap(r, ..., Rowv = NA, symm = TRUE, scale = "none", col = pal, labRow = NA, labCol = NA)
}

cov2x2 <- function(var1, var2, covar) matrix(c(var1, covar, covar, var2), nrow = 2)
