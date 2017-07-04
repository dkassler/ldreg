#' Imitate the functions found in ldsc package, somewhat

ldsr <- function(ss, r, cat_mems, N_refpop, weighted = FALSE,
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
  dat$ss <- ss

  if (weighted) {
    wt <- 1 / (var(dat$ss) * colSums(r_squared))
    wt <- pmin(wt, 0)
  } else {
    wt <- NULL
  }

  fit <- lm(data = dat, formula(paste0("ss ~ ", rhs)), weights = wt)
  return(fit)
}

ldsr_strat <- function(chi2, r, cat_mems, N, N_refpop, ...) {
  fit <- ldsr(ss = chi2, r = r, cat_mems = cat_mems, N_refpop = N_refpop, ...)
  tau <- coef(fit)[-1] / N
  return(tau)
}

ldsr_stratX <- function(z1, z2, r, cat_mems, N1, N2, N_refpop, ...) {
  fit <- ldsr(ss = z1 * z2, r = r, cat_mems = cat_mems, N_refpop = N_refpop, ...)
  upsilon <- coef(fit)[-1] / sqrt(N1 * N2)
  return(upsilon)
}

stratx_corr <- function(z1, z2, r, cat_mems, N1, N2, N_refpop, ...) {
  upsilon <- ldsr_stratX(z1, z2, r, cat_mems, N1, N2, N_refpop, ...)
  tau1 <- ldsr_strat(z1^2, r, cat_mems, N1, N_refpop, ...)
  tau2 <- ldsr_strat(z2^2, r, cat_mems, N2, N_refpop, ...)

  overlap <- sapply(cat_mems, function(x) sapply(cat_mems, function(y) {
    length(intersect(x, y))
  }))
  numerator <- overlap %*% upsilon
  denominator <- sqrt((overlap %*% tau1) * (overlap %*% tau2))
  #browser(expr = any(is.nan(denominator)))
  return(drop(numerator/denominator))
}

jk_stratx_corr <- function(z1, z2, r, cat_mems, N1, N2, N_refpop, blocks = 20,
                           weighted = FALSE, bias_correction = TRUE,
                           find_blocks = TRUE, ...) {
  #N.B. this is a weighted jackknife. weighted argument only controls whether
  #ldreg is weighted
  num_jblks <- blocks
  N_snp <- dim(r)[1]
  if (!find_blocks) {
    jblk_ind <- cut(1:N_snp, num_jblks, labels = FALSE)
  } else {
    jblk_ind <- find_jblks(r, num_jblks)
    #saveLSF(jblk_ind, "jblk_ind")
    num_jblks <- length(unique(jblk_ind))
  }
  jblk_size <- tapply(jblk_ind, jblk_ind, length)
  jk_reps <- unname(lapply(1:num_jblks, function(i) {
    sel <- which(jblk_ind != i)
    unsel <- which(jblk_ind == i)
    cat_mems_sel <- lapply(cat_mems, function(.) {
      x <- .[. %in% sel]
      sapply(x, function(y) y - sum(unsel < y))
    })
    stratx_corr(z1[sel], z2[sel], r[sel, sel], cat_mems_sel, N1, N2, N_refpop,
           weighted = weighted, bias_correction = bias_correction)
  }))

  est_hat <- stratx_corr(z1, z2, r, cat_mems, N1, N2, N_refpop,
                        weighted = weighted, bias_correction = bias_correction)
  jk_est <- rowSums(mapply(jk_reps, jblk_size, FUN = function(jk_rep, size) {
    est_hat - jk_rep + (size * jk_rep) / N_snp
  }))

  hj <- N_snp / jblk_size
  jk_var <- rowSums(mapply(jk_reps, hj, FUN = function(jk_rep, hj) {
    psval <- hj * est_hat - (hj - 1) * jk_rep
    (psval - jk_est)^2 / (hj - 1)
  }))/ num_jblks
  return(list(
    estim = jk_est,
    se = sqrt(jk_var),
    estim_hat = est_hat
  ))
}
