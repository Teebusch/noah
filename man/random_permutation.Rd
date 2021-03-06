% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/random_permutation.R
\name{random_permutation}
\alias{random_permutation}
\title{Generate a lazy non-repeating random number generator}
\usage{
random_permutation(n)
}
\arguments{
\item{n}{Upper limit for random numbers (inclusive)}
}
\value{
A function \code{f(m)} that returns \code{m} random numbers from the random
permutation of integers 1 to n without repetition,. If all available
numbers 1 to n have been returned but more are requested, the function throws
an error.
}
\description{
Generates a function that provides lazy number generation from
a random permutation of integers 1 to n without repetition. The numbers are
generated using the Fisher-Yates algorithm and run length encoding (RLE) is
used to keep memory use for the storage of used/available numbers minimal.
}
\keyword{internal}
