library(ldreg)

size <- 10000
jack_args <- list(
  blocks = 200,
  bias_correction = TRUE
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

saveLSF_rng()

# x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
#                     Ns = round(0.3 * size))
x2 <- do.call(sim1, x1)
jack_emp <- do.call(jackknife, c(x2, x1, jack_args))
jack_wt_emp <- do.call(jackknife, c(x2, x1, jack_args, weighted = TRUE))

saveLSF(jack_emp, "jack.nowt.emp")
saveLSF(jack_wt_emp, "jack.wt.emp")

jack_args$bias_correction <- FALSE

x2$r <- as.matrix(x1$.cov)
jack_true <- do.call(jackknife, c(x2, x1, jack_args))
jack_wt_true <- do.call(jackknife, c(x2, x1, jack_args, weighted = TRUE))

saveLSF(jack_true, "jack.nowt.true")
saveLSF(jack_wt_true, "jack.wt.true")
