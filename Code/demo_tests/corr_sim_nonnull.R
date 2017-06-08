# This script is a demonstration of the power of the method, testing non-null
# versions

library(ldreg)

# Control -----------------------------------------------------------------

local <- FALSE

jack_args <- list(
  blocks = 200,
  bias_correction = TRUE,
  find_blocks = TRUE,
  weighted = TRUE
)

N_snp <- 1E4
if (N_snp > 1E4) stop("No support for more than 10,000 SNPs.")

if (!local) saveLSF_rng()

# Simulation --------------------------------------------------------------

sim_param <- rand_sim_data(
  N_snp = N_snp,
  #  .cov = w10ks,
  .cov = make_cov.bdiag(N_snp, size = 3),
  N1 = 1E4,
  Ns = 3E3,
  N_refpop = 1E3,
  cat_props = c(1, 0.6, 0.3),
  cat_mats = list(
    cov2x2(.8, .8, .1),
    cov2x2(.8, .8, .7),
    cov2x2(.8, .8, .4)
  )
)
if (!local) saveLSF(sim_param, "param")

sim_data <- do.call(sim_2trait, sim_param)
est <- do.call(jk_stratx_corr, c(sim_param, sim_data, jack_args))

if (!local) saveLSF(est, "est")
