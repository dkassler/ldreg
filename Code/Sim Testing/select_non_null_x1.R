library(ldreg)
library(magrittr)

pacman::p_load(doSNOW, progress)

N_cores <- parallel::detectCores()
size <- 100
x1_test <- 1000

cl <- makeCluster(N_cores)
registerDoSNOW(cl)

packs <- c("ldreg", "magrittr")

pb <- progress_bar(x1_test, width = 60)
x1s <- foreach(
  i = 1:x1_test,
  .packages = packs,
  .options.snow = list(progress = function(n) pb$tick())
) %dopar% {
  set.seed(i)
  rand_sim_data(N_snp = size, N1 = size, N_refpop = size, Ns = round(0.3 * size))
}

tus <- sapply(x1s, function(.) sapply(.[["cat_mats"]], `[`, 1, 2))
sel1 <- which.max(colSums(abs(tus)[-1,]))

sel1

stopCluster(cl)
