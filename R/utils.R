#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL


#' Default value for NULL (coalescing OR operator)
#'
#' See \code{rlang::\link[rlang::op-null-default]{\%||\%}} for details.
#'
#' @name %||%
#' @rdname op-null-default
#' @keywords internal
#' @importFrom rlang %||%
#' @usage x \%||\% y
NULL


#' Convert linear index to matrix subscripts
#'
#' Takes a vector of integers (1D linear indexed) and converts them to matrix
#' subscripts in n-dimensional matrix. Modeled after MATLAB's `ind2sub()`
#'
#' @param ind An integer vector with linear indexes
#' @param dims An n-dimensional integer vector. Each element of this vector
#' indicates the size of the corresponding dimension in the n-dimensional
#' matrixc.
#' @return A list of n lists of equal length. Each list corresponds to one of
#' the n dimensions of the matrix. Rows indicate subscripts. Suitable for
#' use with mapping functions.
#' @keywords internal
ind2subs <- function(ind, dims) {
  subs <- arrayInd(ind, .dim = dims)
  purrr::array_branch(subs, margin = 2) # convert from matrix to list of lists
}


#' Convert matrix subscripts to linear index
#'
#' Takes subscripts as list of lists or data frame and converts them to linear
#' index.
#'
#' @param subs Subscripts as list of lists of data frame.
#' @inheritParams ind2subs
#' @return In integer vector with linear indexes.
#' @keywords internal
subs2ind <- function(subs, dims) {
  ind <- rep.int(1, length(subs[[1]]))

  # "multipliers" for each dimension
  k <- cumprod(c(1, dims[-length(dims)]))

  for (i in seq_along(dims)) {
    s <- subs[,i]
    ind <- ind + (s-1) * k[i]
  }

  ind
}
