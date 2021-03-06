getopts <- function() {
  # Grab command line arguments as character vect
  script_args <- commandArgs(T)

  # Set defaults
  # jobindex <- sample.int(1E10, 1)

  # Loop through arguments checking for flags
  opts <- list()
  prev_arg <- NULL
  for (arg in script_args) {
    if (identical(prev_arg, "-o")) {
      opts$outname <- arg
    } else if (identical(prev_arg, "-i")) {
      opts$jobindex <- arg
    } else if (identical(prev_arg, "-d")) {
      opts$outdir <- arg
    }

    prev_arg <- arg
  }

  #return list of arguments
  opts
}
