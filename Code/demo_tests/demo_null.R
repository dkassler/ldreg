# This script is a demonstration that the ldreg package does not produce false
# positives when estimating covariance. It is a cleaned version of
# test_null.R in sim_testing.

library(ldreg)
#w10ks <- readRDS("data/w10ks.rds")

saveLSF_rng()

jack_args <- list(
  blocks = 200,
  bias_correction = TRUE,
  find_blocks = TRUE,
  weighted = TRUE
)

N_snp <- 1E4
if (N_snp > 1E4) stop("No support for more than 10,000 SNPs.")

# sim_param <- rand_sim_data(
#   N_snp = N_snp,
# #  .cov = w10ks,
#   .cov = make_cov.bdiag(N_snp, size = 3),
#   N1 = 1E4,
#   Ns = 3E3,
#   N_refpop = 1E3,
#   cat_props = c(1, 0.6, 0.3, 0.1),
#   cat_mats = rep(list(matrix(c(0.8, 0, 0, 0.5), nrow = 2)), 4)
# )
#
# sim_data <- do.call(sim_2trait, sim_param)
# jack <- do.call(jackknife, c(sim_param, sim_data, jack_args))

size <- N_snp
x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
x1$cat_mats[[1]] <- matrix(c(0.7, 0, 0, 0.7), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[2]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[3]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))

x2 <- do.call(sim1, x1)
jack <- do.call(jackknife, c(x2, x1, jack_args))

saveLSF(jack, "jack")
