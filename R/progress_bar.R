progress_bar <- function(N, width = 100) {
  progress::progress_bar$new(
    format = sprintf(
      "Completed :current of %s [:bar] :percent in :elapsed | :eta left",
      N
    ),
    total = N,
    clear = FALSE,
    width = width
  )
}
