save_rng <- function(savefile=tempfile()) {
  if (exists(".Random.seed"))  {
    oldseed <- get(".Random.seed", .GlobalEnv)
  } else {
    #stop("don't know how to save before set.seed() or r*** call")
    warning(".Random.seed does not yet exist. Creating seed to save.")
    invisible(runif(1))
    oldseed <- get(".Random.seed", .GlobalEnv)
  }
  oldRNGkind <- RNGkind()
  save("oldseed","oldRNGkind",file=savefile)
  invisible(savefile)
}

restore_rng <- function(savefile) {
  load(savefile)
  do.call("RNGkind",as.list(oldRNGkind))  ## must be first!
  assign(".Random.seed", oldseed, .GlobalEnv)
}

saveLSF <- function(x, name) {
  opts <- getopts()
  path <- file.path(opts$outdir, sprintf("%s.%s.rds", name, opts$jobindex))
  attempt <- try(saveRDS(x, path))
  if ("try-error" %in% attempt) {
    #safe error handling to ensure we don't lose output
    stop("Unable to save.")
  }
}

saveLSF_rng <- function(name = "seed") {
  invisible(runif(1)) # make sure RNG is initialized
  opts <- getopts()
  path <- file.path(opts$outdir, sprintf("%s.%s", name, opts$jobindex))
  save_rng(path)
}
