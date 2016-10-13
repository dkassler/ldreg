library(ldreg)
library(doParallel)

x1s <- pblapply(1:1000, function(i) {
  set.seed(i)
  rand_sim_data(N_snp = 10000, N1 = 10000, N_refpop = 10000, Ns = 3000)
})

tus <- sapply(x1s, function(.) sapply(.[["cat_mats"]], `[`, 1, 2))
sel1 <- which.max(colSums(abs(tus)[-1,]))
x1 <- x1s[[sel1]]

x2s <- pbreplicate(100, simplify = FALSE, do.call(sim1, x1))
jack <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1)))
jack_wt <- lapply(x2s, function(x2) do.call(jackknife, c(x2, x1, list(weighted = TRUE))))
fits <- sapply(jack, `[[`, "upsilon_hat")
fits_wt <- sapply(jack_wt, `[[`, "upsilon_hat")

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
