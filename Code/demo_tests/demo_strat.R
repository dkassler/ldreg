# This is a demonstration of the code's ability to recreate stratified ld score
# regression and recover the orginal parameters of simulated data.

library(ldreg)
w10ks <- readRDS("data/w10ks.rds")

saveLSF_rng()

N_snp <- 1E4
if (N_snp > 1E4) stop("No support for more than 10,000 SNPs.")

sim_param <- list(
  .cov = w10ks,
  N = 1E4,
  N_refpop = 1000,
  cat_mems = make_cat_mems(N_snp, N_snp * c(1, 0.4)),
  cat_mats = c(0, 0.8 / (N_snp * 0.4))
)
sim_data <- do.call(sim_1trait, sim_param)

fit <- do.call(getfit_strat, c(sim_param, sim_data))

saveLSF(fit, "fit")
