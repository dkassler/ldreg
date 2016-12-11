getfit_strat <- function(chi2, r, cat_mems, N,
                         bias_correction = TRUE, ...) {
  r_squared <- if (bias_correction) {
    r^2 - 1/N_refpop
  } else {
    r^2
  }

  ld <- lapply(cat_mems, function(.) colSums(r_squared[.,]))
  dat <- as.data.frame(ld)
  names(dat) <- paste0("ld", 1:length(ld))
  rhs <- paste(names(dat), collapse = "+")
  dat$chi2 <- chi2
  fit <- lm(data = dat, formula(paste0("chi2 ~ ", rhs)))

  tau <- coef(fit)[-1] / N
  tau
}

getfit <- function(z1, z2, r, cat_mems, N1, N2, N_refpop,
                   weighted = FALSE, bias_correction = TRUE, ...) {
  r_squared <- if (bias_correction) {
    r^2 - 1/N_refpop
  } else {
    r^2
  }

  ld <- lapply(cat_mems, function(.) colSums(r_squared[.,]))
  dat <- as.data.frame(ld)
  names(dat) <- paste0("ld", 1:length(ld))
  rhs <- paste(names(dat), collapse = "+")
  dat$zz <- z1 * z2
  wt <- if (weighted) {1 / (var(dat$zz) * colSums(r_squared))} else NULL
  fit <- lm(data = dat, formula(paste0("zz ~ ", rhs)), weights = wt)
  upsilon <- coef(fit)[-1] / sqrt(N1 * N2)

  return(upsilon)

  # tau1 <- getfit_strat(z1^2, r, cat_mems, N1)
  # tau2 <- getfit_strat(z2^2, r, cat_mems, N2)
  #
  # upsilon / sqrt(abs(tau1 * tau2))
}

getfit.list <- function(x) {
  getfit(x$z1, x$z2, x$r, x$cat_mems)
}

closest <- function(x, target) which(abs(x - target) == min(abs(x - target)))[1]

find_jblks <- function(r, blocks) {
  # subdiag <- diag(r[-1, -nrow(r)])
  # subdiag_0 <- which(subdiag == 0)
  N_snp <- dim(r)[1]
  targets <- (1:(blocks - 1)) * N_snp/blocks

  if (class(r) != "matrix") r <- as.matrix(r)

  subdiag_mean <- diagmean(r, 1, round(nrow(r)/blocks))
  browser(expr = any(is.na(subdiag_mean)))
  subdiag_min <- which(subdiag_mean <= quantile(subdiag_mean, 0.10))
  cuts <- subdiag_min[sapply(targets, closest, x = subdiag_min)]
  cuts <- unique(cuts)

  sapply(1:N_snp, function(x) sum(x > cuts)) + 1
}

jackknife <- function(z1, z2, r, cat_mems, N1, N2, N_refpop, blocks = 20,
                      weighted = FALSE, bias_correction = TRUE, ...) {
  num_jblks <- blocks
  N_snp <- dim(r)[1]
  #jblk_ind <- cut(1:N_snp, num_jblks, labels = FALSE)
  jblk_ind <- find_jblks(r, num_jblks)
  saveLSF(jblk_ind, "jblk_ind")
  num_jblks <- length(unique(jblk_ind))
  jblk_size <- tapply(jblk_ind, jblk_ind, length)

  jk_reps <- unname(lapply(1:num_jblks, function(i) {
    sel <- which(jblk_ind != i)
    unsel <- which(jblk_ind == i)
    cat_mems_sel <- lapply(cat_mems, function(.) {
      x <- .[. %in% sel]
      sapply(x, function(y) y - sum(unsel < y))
    })
    getfit(z1[sel], z2[sel], r[sel, sel], cat_mems_sel, N1, N2, N_refpop,
           weighted = weighted, bias_correction = bias_correction)
  }))
  upsilon_hat <- getfit(z1, z2, r, cat_mems, N1, N2, N_refpop,
                        weighted = weighted, bias_correction = bias_correction)
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
