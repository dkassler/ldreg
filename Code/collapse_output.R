script_args <- commandArgs(trailingOnly = TRUE)

library(methods)
library(foreach)

if (length(script_args) < 1) stop("Script run without any arguments")
formstr <- script_args[[1]]

out <- foreach(i = 1:100) %do% {
  filename <- sprintf(formstr, i)
  out <- readRDS(filename)
  file.remove(filename)
  out
}

saveRDS(out, sprintf(formstr, "all"))
