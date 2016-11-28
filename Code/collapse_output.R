script_args <- commandArgs(trailingOnly = TRUE)

library(methods)
#library(foreach)

if (length(script_args) < 1) stop("Script run without any arguments")
path_arg <- script_args[[1]]

dir_filenames <- dir(dirname(path_arg))
filenames <- grep(glob2rx(basename(path_arg)), dir_filenames, value = T)

if (length(filenames) == 0) stop("No matching files found")
# print(filenames)

# out <- foreach(name = filenames,
#                .errorhandling = "pass") %do% {
#   filename <- file.path(dirname(path_arg), name)
#   out <- readRDS(filename)
#   print(sprintf("read %s", filename))
#   file.remove(filename)
#   out
# }

out <- list()
for (name in filenames) {
  filename <- file.path(dirname(path_arg), name)
  out[[name]] <- readRDS(filename)
}

outname <- if (length(script_args) > 1) {
  script_args[[2]]
} else {
  gsub("\\*", "all", path_arg)
}

saveRDS(out, outname)

for (name in filenames) {
  filename <- file.path(dirname(path_arg), name)
  file.remove(filename)
}
