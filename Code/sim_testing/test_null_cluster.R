# For this process, you need to allocate at least 800 MB of RAM per worker.

script_args <- commandArgs(trailingOnly = TRUE)

library(methods)
library(ldreg)
library(magrittr)

size <- 10000

if (length(script_args) > 0) {
  filenum <- script_args[1]
} else {
  filenum <- sample.int(1E10, 1)
}
formstr <- "output/test_null.output.%s.%s.rds"
saveRDS(.Random.seed, sprintf(formstr, "seed", filenum))

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
x1$cat_mats[[1]] <- matrix(c(0.7, 0, 0, 0.7), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[2]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))
x1$cat_mats[[3]] <- matrix(c(0.9, 0, 0, 0.6), nrow = 2) / sum(sapply(x1$cat_mems, length))

x2 <- do.call(sim1, x1)
jack <- do.call(jackknife, c(x2, x1, blocks = 200))
jack_wt <- do.call(jackknife, c(x2, x1, weighted = TRUE, blocks = 200))

# x2s <- pbreplicate(100, simplify = FALSE, do.call(sim1, x1))
# jack <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1)))
# jack_wt <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1, list(weighted = TRUE))))
# fits <- sapply(jack, `[[`, "upsilon_hat")
# fits_wt <- sapply(jack_wt, `[[`, "upsilon_hat")

library(dplyr)

# output <- bind_rows(
#   F = as.data.frame(jack) %>% {tibble::rownames_to_column(.)},
#   T = as.data.frame(jack_wt) %>% {tibble::rownames_to_column(.)},
#   .id = "wt"
# )
#
# print(output)

saveRDS(jack, sprintf(formstr, "jack", filenum))
saveRDS(jack_wt, sprintf(formstr, "jack_wt", filenum))
