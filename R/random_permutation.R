#' Generates a functions that provides lazy number generation from a random
#' permutation of integers 1 to n without repetition. The numbers are generated
#' using the Fisher-Yates algorithm and run length encoding is used to keep
#' memory use for the storage of used/available numbers minimal.
#'
#' @param n Upper limit for random numbers (inclusive).
#'
#' @return A function `f(m)` that returns `m` random numbers from the random
#' permutation of integers 1 to n without repetition, and returns `NA` if all
#' numbers 1 to n have been returned.
#'
#' @examples
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

  # To sample a number from the permutation, choose an element >0 at
  # random, swap it with the last entry, and return it.
  function(m = 1) {
    out <- rep.int(NA_integer_, m)
    remaining <- rle_decode(remaining)
    nleft <- length(remaining)
    for (i in seq_len(m)) {
      if (nleft) {
        swap <- sample(nleft, 1)
        out[i] <- remaining[swap]
        remaining[swap] <- remaining[nleft]
        nleft <- nleft - 1
      }
    }
    length(remaining) <- nleft
    remaining <<- rle_encode(remaining)
    out
  }
}

# convert sequence of unused numbers to run length encoding (RLE)
rle_encode <- function(seq) {
  rle(diff(c(0, seq)))
}

# convert sequence of unused numbers from run length encoding (RLE)
rle_decode <- function(enc) {
  cumsum(inverse.rle(enc))
}
