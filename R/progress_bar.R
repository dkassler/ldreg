progress_bar <- function(N, width = 80) {
  progress::progress_bar$new(
    format = sprintf(
      "[:bar] :current of %s, :percent in :elapsed | :eta left",
      N
    ),
    total = N,
    clear = FALSE,
    width = width
  )
}
