script_args <- commandArgs(trailingOnly = TRUE)

library(methods)
library(foreach)

if (length(script_args) < 1) stop("Script run without any arguments")
path_arg <- script_args[[1]]

dir_filenames <- dir(dirname(path_arg))
filenames <- grep(glob2rx(basename(path_arg)), dir_filenames, value = T)

out <- foreach(name = filenames) %do% {
  filename <- file.path(dirname(path_arg), name)
  out <- readRDS(filename)
  file.remove(filename)
  out
}

outname <- if (length(script_args) > 1) {
  script_args[[2]]
} else {
  gsub("\\*", "all", path_arg)
}

saveRDS(out, outname)
