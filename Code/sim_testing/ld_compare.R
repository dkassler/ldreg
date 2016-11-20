script_args <- commandArgs(trailingOnly = TRUE)

library(methods)
library(ldreg)
library(magrittr)

size <- 10000

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size,
                    Ns = round(0.3 * size))
x2 <- do.call(sim1, x1)

ld_emp <- colSums(x2$r^2)
ld_bias <- colSums(x2$r^2 - 1/(x1$N_refpop))
ld_true <- colSums(as.matrix(x1$.cov)^2)

ld_out <- list(
  ld_emp = ld_emp,
  ld_bias = ld_bias,
  ld_true = ld_true
)

if (length(script_args) > 0) {
  filenum <- script_args[1]
} else {
  filenum <- sample.int(1E10, 1)
}
saveRDS(ld_out, sprintf("ld_compare.%s.rds", filenum))
