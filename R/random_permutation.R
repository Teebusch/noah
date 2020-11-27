#' Generates a function that provides lazy number generation from a random
#' permutation of integers 1 to n without repetition. The numbers are generated
#' using the Fisher-Yates algorithm and run length encoding (RLE) is used to
#' keep memory use for the storage of used/available numbers minimal.
#'
#' @param n Upper limit for random numbers (inclusive)
#'
#' @return A function `f(m)` that returns `m` random numbers from the random
#' permutation of integers 1 to n without repetition,. If all available
#' numbers 1 to n have been returned but more are requested, the function throws
#' an error.
random_permutation <- function(n) {
  if (length(n) == 1) {
    # manual RLE
    remaining <- structure(
      list(lengths = n, values = 1),
      class = "rle"
    )
  } else {
    remaining <- rle_encode(n)
  }

  # Fisher-Yates: To sample a number from the permutation, choose an element
  # >0 at random, swap it with the last entry, and return it.
  function(m = 1) {
    out <- rep.int(NA_integer_, m)
    remaining <- rle_decode(remaining)
    nleft <- length(remaining)

    if(nleft < m) {
      stop("Error. Not enough numbers left in the permutation.")
    }

    for (i in seq_len(m)) {
      swap <- sample(nleft, 1)
      out[i] <- remaining[swap]
      remaining[swap] <- remaining[nleft]
      nleft <- nleft - 1
    }
    length(remaining) <- nleft
    remaining <<- rle_encode(remaining)
    out
  }
}


#' Modify the random permutation function f in order to remove numbers i from
#' the numbers that are available in the random permutation
#'
#' @param f Function created by `random_permutation()`
#' @param i Integer vector of numbers that should  be removed from remaining
#' numbers in the random permutation that is produced by f
#'
#' @return A random permutation function which will not produce the numbers in
#' i anymore.
remove_remaining <- function(f, i) {
  assertthat::assert_that(is.function(f))
  assertthat::assert_that(is.numeric(i))

  remaining <- rle_decode(environment(f)$remaining)
  environment(f)$remaining <- rle_encode(setdiff(remaining, i))
  f
}


#' Get the number of unused elements left in a random permutation
#'
#' @param f Function created by `random_permutation()`
#'
#' @return Integer, number of elements left in the permutation
#'
#' @keywords internal
get_n_remaining <- function(f) {
  length(rle_decode(environment(f)$remaining))
}


# convert sequence of unused numbers to run length encoding (RLE)
rle_encode <- function(seq) {
  rle(diff(c(0, seq)))
}


# convert sequence of unused numbers from run length encoding (RLE)
rle_decode <- function(enc) {
  cumsum(inverse.rle(enc))
}
