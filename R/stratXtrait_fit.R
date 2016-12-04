getfit_strat <- function(chi2, r, cat_mems, N, ...) {
  ld <- lapply(cat_mems, function(.) colSums((r^2)[.,]))
  dat <- as.data.frame(ld)
  names(dat) <- paste0("ld", 1:length(ld))
  rhs <- paste(names(dat), collapse = "+")
  dat$chi2 <- chi2
  fit <- lm(data = dat, formula(paste0("chi2 ~ ", rhs)))

  tau <- coef(fit)[-1] / N
  tau
}

getfit <- function(z1, z2, r, cat_mems, N1, N2, weighted = FALSE, ...) {
  ld <- lapply(cat_mems, function(.) colSums((r^2)[.,]))
  dat <- as.data.frame(ld)
  names(dat) <- paste0("ld", 1:length(ld))
  rhs <- paste(names(dat), collapse = "+")
  dat$zz <- z1 * z2
  wt <- if (weighted) {1 / (var(dat$zz) * colSums(r^2))} else NULL
  fit <- lm(data = dat, formula(paste0("zz ~ ", rhs)), weights = wt)
  upsilon <- coef(fit)[-1] / sqrt(N1 * N2)

  tau1 <- getfit_strat(z1^2, r, cat_mems, N1)
  tau2 <- getfit_strat(z2^2, r, cat_mems, N2)

  upsilon / sqrt(abs(tau1 * tau2))
}

getfit.list <- function(x) {
  getfit(x$z1, x$z2, x$r, x$cat_mems)
}

jackknife <- function(z1, z2, r, cat_mems, N1, N2, blocks = 20,
                      weighted = FALSE, ...) {
  num_jblks <- blocks
  N_snp <- dim(r)[1]
  jblk_ind <- cut(1:N_snp, num_jblks, labels = FALSE)
  jblk_size <- tapply(jblk_ind, jblk_ind, length)

  jk_reps <- unname(lapply(1:num_jblks, function(i) {
    sel <- which(jblk_ind != i)
    unsel <- which(jblk_ind == i)
    cat_mems_sel <- lapply(cat_mems, function(.) {
      x <- .[. %in% sel]
      sapply(x, function(y) y - sum(unsel < y))
    })
    getfit(z1[sel], z2[sel], r[sel, sel], cat_mems_sel, N1, N2,
           weighted = weighted)
  }))
  upsilon_hat <- getfit(z1, z2, r, cat_mems, N1, N2, weighted = weighted)
  #jk_est <- sum(upsilon_hat - jk_reps + (jblk_size * jk_reps) / N_snp)
  jk_est <- rowSums(mapply(jk_reps, jblk_size, FUN = function(jk_rep, size) {
    upsilon_hat - jk_rep + (size * jk_rep) / N_snp
  }))

  hj <- N_snp / jblk_size
  jk_var <- rowSums(mapply(jk_reps, hj, FUN = function(jk_rep, hj) {
    psval <- hj * upsilon_hat - (hj - 1) * jk_rep
    (psval - jk_est)^2 / (hj - 1)
  }))/ num_jblks
  #jk_var <- sum((psvals - jk_est)^2 / (hj - 1)) / num_jblks

  return(list(
    estim = jk_est,
    se = sqrt(jk_var),
    upsilon_hat = upsilon_hat
  ))
}
