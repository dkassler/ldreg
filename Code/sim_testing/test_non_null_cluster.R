# For this process, you need to allocate at least 800 MB of RAM per worker.

script_args <- commandArgs(trailingOnly = TRUE)

library(methods)
library(ldreg)
library(magrittr)

size <- 10000

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

x2 <- do.call(sim1, x1)
jack <- do.call(jackknife, c(x2, x1, list(blocks = 20)))
jack_wt <- do.call(jackknife, c(x2, x1, list(weighted = TRUE, blocks = 20)))

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

if (length(script_args) > 0) {
  filenum <- script_args[1]
} else {
  filenum <- sample.int(1E10, 1)
}
formstr <- "test_non_null.output.%s.%s.rds"
saveRDS(jack, file.path("output", sprintf(formstr, "jack", filenum)))
saveRDS(jack_wt, file.path("output", sprintf(formstr, "jack_wt", filenum)))
