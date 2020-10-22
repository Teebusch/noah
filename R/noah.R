#' Create unique pseudonyms.
#'
#' Pseudonymize returns unique pseudonyms for R objects
#'
#' @param ... One or multiple objects for which pseudonyms should be created,
#' usually one or more columns of a data frame. All objects must be of the same
#' length.
#' @param .ark An Ark object. By default a new Ark is created. Using an existing
#' Ark makes sure that the same input returns the same pseudonym.
#'
#' @return A character vector of pseudonyms.
#' @export
#'
#' @examples
#' pseudonymize("Mata Hari")
pseudonymize <- function(..., .ark = NULL) {
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
#' @param ... Columns on which pseudonyms should be based. Supports tidy select.
#' If empty, all columns will be used.
#' @param .name Name of the new column as string.
#' @param .before,.after Destination of new column, passed on to
#' `dplyr::relocate()`
#' @param .ark Object of class `Ark`. If NULL (default) a new `Ark` is
#' created.
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
  } else {
    pn <- pseudonymize(.data, .ark = .ark)
  }

  .data %>%
    dplyr::mutate(!!.name := pn) %>%
    dplyr::relocate(!!.name, .before = !!.before, .after = !!.after)
}
