# Grab command line arguments as character vect
script_args <- commandArgs(T)

# Set defaults
job_index <- sample.int(1E10, 1)

# Loop through arguments checking for flags
prev_arg <- NULL
for (arg in script_args) {
  if (identical(prev_arg, "-o")) {
    out_name <- arg
  } else if (identical(prev_arg, "-i")) {
    job_index <- arg
  } else if (identical(prev_arg, "-d")) {
    save_dir <- arg
  }

  prev_arg <- arg
}
rm("prev_arg", "arg")
