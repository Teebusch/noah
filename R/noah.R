#' Create unique pseudonyms.
#'
#' Pseudonymize returns unique pseudonyms for R objects.
#' It accepts any number of vectors and data frame as arguments and will use
#' them as keys for the pseudonym creation.
#' Vectors and data frames must have identical length.
#' Elements in the same position or row are treated as part of the same key.
#' The same key is always assigned the same pseudonym. Different keys are
#' always assigned different pseudonyms.
#'
#' @param ... One or multiple objects to use as keys for which pseudonyms
#' should be created, usually one or more columns of a data frame.
#' All objects must be of the same length.
#' @param .alliterate Logical. Should only pseudonyms that are alliterations be
#' returned? Defaults to FALSE, or TRUE if set as TRUE for the Ark provided to
#' `.ark`. If set, takes precedence over the Ark's default setting.
#' @param .ark An Ark object. If NULL (default) a new Ark is created. Using an
#' existing Ark makes sure that the same input returns the same pseudonym.
#'
#' @return A character vector of pseudonyms.
#' @export
#'
#' @examples
#' pseudonymize("Mata Hari")
pseudonymize <- function(..., .alliterate = NULL, .ark = NULL) {
  if (is.null(.ark)) {
    .ark <- Ark$new()
  } else {
    assertthat::assert_that(inherits(.ark, "Ark"))
  }
  .ark$pseudonymize(...)
}


#' Add column with pseudonyms to a data frame.
#'
#' @param .data A data frame to add pseudonyms to.
#' @param ... Columns to use as keys on which pseudonyms should be based.
#' Supports tidy select. If empty, all columns will be used.
#' @param .name Name of the new column as string.
#' @inheritParams dplyr::relocate
#' @inheritParams pseudonymize
#'
#' @return A data frame with an additional column containing the pseudonyms.
#' @export
#'
#' @examples
#' add_pseudonyms(mtcars)
add_pseudonyms <- function(.data, ..., .name = "pseudonym", .before = NULL,
                           .after = NULL, .ark = NULL) {

  if (...length() > 0) {
    pn <- pseudonymize(dplyr::select(.data, ...), .ark = .ark)
    assertthat::assert_that(length(pn) == nrow(.data))
  } else {
    pn <- pseudonymize(.data, .ark = .ark)
  }

  .data %>%
    dplyr::mutate(!!.name := pn) %>%
    dplyr::relocate(!!.name, .before = !!.before, .after = !!.after)
}
