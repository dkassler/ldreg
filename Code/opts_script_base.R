get_script_args <- function() {
  # Grab command line arguments as character vect
  script_args <- commandArgs(T)

  # Set defaults
  jobindex <- sample.int(1E10, 1)

  # Loop through arguments checking for flags
  args <- list()
  prev_arg <- NULL
  for (arg in script_args) {
    if (identical(prev_arg, "-o")) {
      args$outname <- arg
    } else if (identical(prev_arg, "-i")) {
      args$jobindex <- arg
    } else if (identical(prev_arg, "-d")) {
      args$outdir <- arg
    }

    prev_arg <- arg
  }

  #return list of arguments
  args
}

saveLSF <- function(x, name) {
  attempt <- try(saveRDS(x, file.path(outdir, sprintf("%s.%s.rds", name, jobindex))))
  if ("try-error" %in% attempt) {
    #safe error handling to ensure we don't lose output
  }
}
