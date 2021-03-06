library(ldreg)

size <- 10000
jack_args <- list(
  blocks = 200,
  find_blocks = TRUE
)

x1_seed <- if (size == 100) {
  938 #/1000
} else if (size == 10000) {
  180 #/1000
} else NULL
set.seed(x1_seed)
x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
set.seed(NULL)

#saveLSF_rng("seed")
restore_rng(sprintf("output/test_non_null/2016-12-11b/out/seed.%s", getopts()$jobindex))

x2 <- do.call(sim1, x1)
#jack <- do.call(jackknife, c(x2, x1, jack_args))
jack_wt <- do.call(jackknife, c(x2, x1, weighted = TRUE, jack_args))

#saveLSF(jack, "jack")
saveLSF(jack_wt, "jack_wt")
