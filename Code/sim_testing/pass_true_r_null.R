library(ldreg)

size <- 10000
jack_args <- list(
  blocks = 200,
  bias_correction = TRUE
)

saveLSF(.Random.seed, "seed")

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
x1$cat_mats[[1]] <- matrix(c(0.7, 0, 0, 0.7), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[2]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[3]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))

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
