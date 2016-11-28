script_args <- commandArgs(trailingOnly = TRUE)

library(methods)
library(ldreg)
library(magrittr)

size <- 10000
jack_args <- list(
  blocks = 10,
  bias_correction = FALSE
)

#938 (/1000) for size 100
x1_seed <- if (size == 100) {
  938 #/1000
} else if (size == 10000) {
  180 #/1000
} else NULL
set.seed(x1_seed)
x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
set.seed(NULL)

if (length(script_args) > 0) {
  filenum <- script_args[1]
} else {
  filenum <- sample.int(1E10, 1)
}

formstr <- "pass_true_r.output.%s.%s.rds"
saveRDS(.Random.seed, sprintf(formstr, "seed", filenum))

x2 <- do.call(sim1, x1)
x2$r <- as.matrix(x1$.cov)
jack <- do.call(jackknife, c(x2, x1, jack_args))
jack_wt <- do.call(jackknife, c(x2, x1, jack_args, weighted = TRUE))

saveRDS(jack, file.path("output", sprintf(formstr, "non_null.jack", filenum)))
saveRDS(jack_wt, file.path("output", sprintf(formstr, "non_null.jack_wt", filenum)))

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
x1$cat_mats[[1]] <- matrix(c(0.7, 0, 0, 0.7), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[2]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[3]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))

x2 <- do.call(sim1, x1)
x2$r <- as.matrix(x1$.cov)
jack <- do.call(jackknife, c(x2, x1, jack_args))
jack_wt <- do.call(jackknife, c(x2, x1, weighted = TRUE, jack_args))

saveRDS(jack, file.path("output", sprintf(formstr, "null.jack", filenum)))
saveRDS(jack_wt, file.path("output", sprintf(formstr, "null.jack_wt", filenum)))

