jack <- readRDS("Code/sim_testing/test_null.output.jack.all.rds")

library(dplyr)

jack <- jack[sapply(jack, . %>% class %>% identical("list"))]

jack %>%
  sapply(function(x) {
    (0 < x$estim + 2 * x$se) & (0 > x$estim - 2 * x$se)
  }) %>%
  rowMeans()
