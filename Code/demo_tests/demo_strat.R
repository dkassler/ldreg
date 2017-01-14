# This is a demonstration of the code's ability to recreate stratified ld score
# regression and recover the orginal parameters of simulated data.

library(ldreg)

saveLSF_rng()

N_snp <- 10000
sim_param <- list(
  .cov = make_cov.bdiag(N_snp, size = 3),
  N = 10000,
  N_refpop = 1000,
  cat_mems = make_cat_mems(N_snp, N_snp * c(1, 0.4)),
  cat_mats = c(0, 0.8 / (N_snp * 0.4))
)
sim_data <- do.call(sim_1trait, sim_param)

fit <- do.call(getfit_strat, c(sim_param, sim_data))

saveLSF(fit, "fit")
