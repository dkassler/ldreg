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

saveLSF <- function(x, name) {
  attempt <- try(saveRDS(x, file.path(outdir, sprintf("%s.%s.rds", name, jobindex))))
  if ("try-error" %in% attempt) {
    #safe error handling to ensure we don't lose output
  }
}

library(ldreg)

size <- 10000
jack_args <- list(blocks = 200)

saveLSF(.Random.seed, "seed")

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
x1$cat_mats[[1]] <- matrix(c(0.7, 0, 0, 0.7), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[2]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[3]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))

x2 <- do.call(sim1, x1)
jack <- do.call(jackknife, c(x2, x1, jack_args))
jack_wt <- do.call(jackknife, c(x2, x1, weighted = TRUE, jack_args))

saveLSF(jack, "jack")
saveLSF(jack_wt, "jack_wt")
