# Grab command line arguments as character vect
script_args <- commandArgs(T)

# Set defaults
jobindex <- sample.int(1E10, 1)

# Loop through arguments checking for flags
prev_arg <- NULL
for (arg in script_args) {
  if (identical(prev_arg, "-o")) {
    outname <- arg
  } else if (identical(prev_arg, "-i")) {
    jobindex <- arg
  } else if (identical(prev_arg, "-d")) {
    outdir <- arg
  }

  prev_arg <- arg
}
rm("prev_arg", "arg")

library(ldreg)

size <- 100

saveRDS(.Random.seed, file.path(outdir, sprintf("seed.%s.rds", jobindex)))

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
x1$cat_mats[[1]] <- matrix(c(0.7, 0, 0, 0.7), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[2]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[3]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))

x2 <- do.call(sim1, x1)
jack <- do.call(jackknife, c(x2, x1, blocks = 5))
jack_wt <- do.call(jackknife, c(x2, x1, weighted = TRUE, blocks = 5))

saveRDS(jack, file.path(outdir, sprintf("jack.%s.rds", jobindex)))
saveRDS(jack_wt, file.path(outdir, sprintf("jack_wt.%s.rds", jobindex)))
