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
