library(foreach)

formstr <- "output/test_non_null.output.%s.%s.rds"
jacks <- foreach(i = 1:100) %do% readRDS(sprintf(formstr, "jack", i))
jack_wts <- foreach(i = 1:100) %do% readRDS(sprintf(formstr, "jack_wt", i))

saveRDS(jacks, sprintf(formstr, "jack", "all"))
saveRDS(jack_wts, sprintf(formstr, "jack_wt", "all"))
