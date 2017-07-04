# This script is a demonstration of the power of the method, testing non-null
# versions

library(ldreg)

# Control -----------------------------------------------------------------

..cluster <- TRUE
..load <- FALSE
..save <- FALSE

jack_args <- list(
  blocks = 200,
  bias_correction = TRUE,
  find_blocks = TRUE,
  weighted = TRUE
)

N_snp <- 1E4
if (N_snp > 1E4) stop("No support for more than 10,000 SNPs.")

if (..cluster) saveLSF_rng()

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
    cov2x2(.7, .7, 0),
    cov2x2(.9, .6, 0),
    cov2x2(.7, .7, 0)
  )
)
if (..cluster) saveLSF(sim_param, "param")

sim_data <- do.call(sim_2trait, sim_param)

if (..cluster & ..save) saveLSF(sim_data, "data")
if (..load) {
  opts <- getopts()
  sim_param <- readRDS(sprintf("output/corr_sim_null/2017-06-08a/out/param.%s.rds", opts$jobindex))
  sim_data  <- readRDS(sprintf("output/corr_sim_null/2017-06-08a/out/data.%s.rds",  opts$jobindex))
}

est <- do.call(jk_stratx_corr, c(sim_param, sim_data, jack_args))

if (..cluster) saveLSF(est, "est")
