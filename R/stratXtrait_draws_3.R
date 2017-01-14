study <- function(N, .cov) {
  N_snp <- nrow(.cov)
  if ("dsCMatrix" %in% class(.cov)) {
    sparseMVN::rmvn.sparse(N, mu = integer(N_snp), CH = Matrix::Cholesky(.cov), prec = FALSE)
  } else {
    MASS::mvrnorm(N, mu = integer(N_snp), Sigma = .cov)
  }
}

make_cat_mats <- function(N_cat) {
  replicate(
    N_cat,
    simplify = FALSE,
    clusterGeneration::genPositiveDefMat(
      "unifcorrmat",
      dim = 2,
      rangeVar = 0:1
    )$Sigma
  )
}
make_cat_mems <- function(N_snp, cat_sizes) {
  lapply(cat_sizes, . %>% sample(N_snp, .))
}

sum_cat_mats <- function(j, cat_mems, cat_mats) {
  # Get sum of covariance matrices for SNP j
  mem <- sapply(cat_mems, function(x) j %in% x)
  Reduce(`+`, cat_mats[mem])
}
draw_snp_effs <- function(N_snp, cat_mems, cat_mats) {
  cat_mats_dim <- unique(c(sapply(cat_mats, . %>% as.matrix %>% dim)))
  if (length(cat_mats_dim) != 1) stop("Problem with dimension of cat_mats")

  t(sapply(1:N_snp, function(j) {
    snp_mat <- sum_cat_mats(j, cat_mems, cat_mats)
    MASS::mvrnorm(mu = rep(0, cat_mats_dim), Sigma = snp_mat)
  }))
}

sim_2trait <- function(.cov, N1, N2, Ns, N_refpop,
                 cat_mems, cat_mats, ...) {
  N_snp <- nrow(.cov)
  N_cat <- length(cat_mems)

  refpop <- study(N_refpop, .cov)
  tot_samp <- N1 + N2 - Ns
  sample <- study(tot_samp, .cov)
  sample1 <- sample[1:N1, ]
  if (N2 > 0) {
    sample2 <- sample[c(1:Ns, (N1 + 1):tot_samp), ]
  }

  snp_effs <- draw_snp_effs(N_snp, cat_mems, cat_mats)
  #snp_effs %<>% scale()

  eff_cov <- lapply(1:N_cat, function(.) cat_mats[[.]] * length(cat_mems[[.]]))
  eff_cov <- Reduce(`+`, eff_cov)
  y1 <- sample1 %*% snp_effs[,1] + rnorm(N1, 0, sqrt(1 - eff_cov[1,1]))
  y2 <- sample2 %*% snp_effs[,2] + rnorm(N2, 0, sqrt(1 - eff_cov[2,2]))

  z1 <- (t(sample1) %*% y1) / sqrt(N1)
  z2 <- (t(sample2) %*% y2) / sqrt(N2)
  r <- refpop %>% {t(.) %*% .} / N_refpop
  return(list(z1 = z1, z2 = z2, r = r))
}

sim1 <- function(...) {
  warning("Use of sim1 is deprecated. Use sim_2trait instead.")
  sim_2trait(...)
}

sim_1trait <- function(.cov, N, N_refpop, cat_mems, cat_mats, ...) {
  N_snp <- nrow(.cov)
  N_cat <- length(cat_mems)

  eff_cov <- lapply(1:N_cat, function(.) cat_mats[[.]] * length(cat_mems[[.]]))
  eff_cov <- Reduce(`+`, eff_cov)
  if (eff_cov >= 1) stop("True variance greater than one.")

  raw_sample <- study(N + N_refpop, .cov)
  study_pop <- raw_sample[1:N,]
  refpop <- raw_sample[(N+1):(N+N_refpop),]

  snp_effs <- draw_snp_effs(N_snp, cat_mems, cat_mats)

  y <- study_pop %*% drop(snp_effs) + rnorm(N, 0, sqrt(1 - eff_cov))
  chi2 <- (t(study_pop) %*% y)^2 / N
  r <- refpop %>% {t(.) %*% .} / N_refpop

  return(list(chi2 = chi2, r = r))
}

rand_sim_data <- function(
  N_snp,
  N1,
  N2 = NULL,
  Ns,
  N_refpop,
  .cov = NULL,
  cat_sizes = NULL,
  cat_props = c(1, .25, .4),
  cat_mems = NULL,
  cat_mats = NULL,
  shrink = TRUE
) {
  if (is.null(.cov)) {
    .cov <- make_cov.bdiag(N_snp, 3)
  } else {
    N_snp <- nrow(.cov)
  }
  if (is.null(N2)) N2 <- N1
  if (is.null(cat_sizes)) cat_sizes <- round(N_snp * cat_props)
  if (is.null(cat_mems)) cat_mems <- make_cat_mems(N_snp, cat_sizes)
  if (is.null(cat_mats)) cat_mats <- make_cat_mats(length(cat_sizes))
  if (shrink) cat_mats %<>% lapply(divide_by, sum(cat_sizes))

  list(
    .cov = .cov,
    N1 = N1,
    N2 = N2,
    Ns = Ns,
    N_refpop = N_refpop,
    cat_mems = cat_mems,
    cat_mats = cat_mats
  )
}
