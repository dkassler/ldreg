# Grab command line arguments as character vect
script_args <- commandArgs(T)

# Set defaults
jobindex <- sample.int(1E10, 1)

# Loop through arguments checking for flags
prev_arg <- NULL
for (arg in script_args) {
  if (identical(prev_arg, "-o")) {
    outname <- arg
  } else if (identical(prev_arg, "-i")) {
    jobindex <- arg
  } else if (identical(prev_arg, "-d")) {
    savedir <- arg
  }

  prev_arg <- arg
}
rm("prev_arg", "arg")

saveLSF <- function(x, name) {
  attempt <- try(saveRDS(x, file.path(outdir, sprintf(name, jobindex))))
  if ("try-error" %in% attempt) {
    #safe error handling to ensure we don't lose output
  }
}
