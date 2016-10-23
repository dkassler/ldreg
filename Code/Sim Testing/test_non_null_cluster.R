# For this process, you need to allocate at least 800 MB of RAM per worker.

library(ldreg)
library(magrittr)

size <- 100
x1_test <- 10

#938 (/1000) for size 100
set.seed(938)

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size, Ns = round(0.3 * size))
x2 <- do.call(sim1, x1)
jack <- do.call(jackknife, c(x2, x1))
jack_wt <- do.call(jackknife, c(x2, x1, list(weighted = TRUE)))

# x2s <- pbreplicate(100, simplify = FALSE, do.call(sim1, x1))
# jack <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1)))
# jack_wt <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1, list(weighted = TRUE))))
# fits <- sapply(jack, `[[`, "upsilon_hat")
# fits_wt <- sapply(jack_wt, `[[`, "upsilon_hat")

library(dplyr)

bind_rows(
  F = as.data.frame(jack) %>% {tibble::rownames_to_column(.)},
  T = as.data.frame(jack_wt) %>% {tibble::rownames_to_column(.)},
  .id = "wt"
)
