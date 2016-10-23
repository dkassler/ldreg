# For this process, you need to allocate at least 800 MB of RAM per worker.

library(ldreg)
library(magrittr)
pacman::p_load(doSNOW, progress)

N_cores <- 1
size <- 100
x1_test <- 10

packs <- c("ldreg", "magrittr")

cl <- makeCluster(N_cores)
registerDoSNOW(cl)

pb <- progress_bar(x1_test)
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
x1 <- x1s[[sel1]]

# x2s <- pbreplicate(100, simplify = FALSE, do.call(sim1, x1))
# jack <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1)))
# jack_wt <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1, list(weighted = TRUE))))
# fits <- sapply(jack, `[[`, "upsilon_hat")
# fits_wt <- sapply(jack_wt, `[[`, "upsilon_hat")

pb <- progress_bar(100)
jack_res <- foreach(
  1:100,
  .packages = packs,
  .export = "x1",
  .options.snow = list(progress = function(n) pb$tick())
) %dopar% {
  x2 <- do.call(sim1, x1)
  list(
    jack = do.call(jackknife, c(x2, x1)),
    jack_wt = do.call(jackknife, c(x2, x1, list(weighted = TRUE)))
  )
}

stopCluster(cl)

saveRDS(jack_res, "jack_raw_nonnull_10K.rds")

cl <- makeCluster(N_cores)
registerDoSNOW(cl)

x1 <- rand_sim_data(N_snp = size, N1 = size, N_refpop = size, Ns = round(0.3 * size),
                    cat_props = c(1, 0.4))
x1$cat_mats[[2]] <- matrix(c(0.8, 0, 0, 0.5), nrow = 2)

pb <- progress_bar(100)
jack_res <- foreach(
  1:100,
  .packages = packs,
  .export = "x1",
  .options.snow = list(progress = function(n) pb$tick())
) %do% {
  x2 <- do.call(sim1, x1)
  list(
    jack = do.call(jackknife, c(x2, x1)),
    jack_wt = do.call(jackknife, c(x2, x1, list(weighted = TRUE)))
  )
}

stopCluster(cl)

saveRDS(jack_res, "jack_raw_null_10K.rds")

# tmp_df_1 <- t(fits) %>%
#   as.data.frame() %>%
#   gather()
# tmp_df_2 <- t(fits_wt) %>%
#   as.data.frame() %>%
#   gather()
# fits_df <- bind_rows(F = tmp_df_1, T = tmp_df_2, .id = "wt")
# true_upsilon <- sapply(x1$cat_mats, `[`, 1, 2)
#
# ggplot(data = fits_df) +
#   geom_density(aes(x = value, color = key, linetype = wt), size = 1) +
#   scale_color_manual(values = pal) +
#   geom_vline(xintercept = true_upsilon, color = pal, size = 1) +
#   labs(x = "Estimated Upsilon",
#        title = "Simple Cov. Matrix, Weighted vs. Unweighted") +
#   theme_bw()
