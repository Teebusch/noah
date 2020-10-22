#' A Class to represent an ark.
#'
#' @description
#' An Ark object can create unique pseudonyms.
#' Given the same input, it will always return the same psuedonym.
#' No pseudonym will repeat.
#'
#' @export

Ark <- R6::R6Class("Ark",
  public = list(

    #' @field log Hashtable for all used pseudonyms. Inputs (keys) are stored
    #' as hashes.
    log = NULL,

    #' @description Create new arc object.
    #' @return A new `Ark` object.
    initialize = function() {
      private$parts <- name_parts
      private$max_length <- prod(lengths(private$parts))
      private$index_shuffled <- sample(1:private$max_length)
      self$log <- hash::hash()
    },

    #' @description Create Pseudonyms for input.
    #' @param ... One or more R objects.
    #' @return Character vector of pseudonyms with same length as input.
    pseudonymize = function(...) {
      dots <- list(...)
      if(inherits(dots[[1]], "data.frame")) {
        # pseudonymize data frame columns rowwise
        dots <- dots[[1]]
      }
      purrr::pmap_chr(dots, function(...) {
        uid <- digest::digest(list(...))
        if (!hash::has.key(uid, self$log)) {
          index <- self$length() + 1
          self$log[uid] <- private$index_to_pseudonym(index)
        }
        self$log[[uid]]
      })
    },

    #' @description Pretty-print an Ark object.
    print = function() {
      cat("Ark with maximum size ", private$max_length, "\n", sep = "")
      if (self$length() > 0) {
        log_entries <- paste(
          hash::keys(self$log), ">>",
          hash::values(self$log)
        )
        cat("Logbook:\n--------\n")
        cat(log_entries, sep = "\n")
      } else {
        cat("The Ark is empty. Use `Ark$pseudomymize(...) to add entries.`")
      }
      invisible(self)
    },

    #' @description Number of used pseudonyms in an Ark.
    length = function() {
      length(self$log)
    }
  ),

  private = list(

    #' @field parts Words that will be combined to form pseudonyms.
    parts = NULL,

    #' @field max_length Maximum number of possible pseudonyms in the Ark.
    max_length = NULL,

    #' @field index_shuffled a random permutation of the index
    index_shuffled = NULL,

    #' @description Returns the pseudonym corresponding to an index.
    #' @param index An integer or a vector of integers between 1 and the Ark's
    #' max_length.
    #' @return A character vector of pseudomyms with the same length as the
    #' input
    index_to_pseudonym = function(index) {
      assertthat::assert_that(
        all(dplyr::between(index, 1, private$max_length))
      )
      k <- private$index_shuffled[index] - 1
      n <- lengths(private$parts)[2]
      i <- (k %/% n) + 1
      j <- (k %% n) + 1
      paste(private$parts[[1]][i], private$parts[[2]][j])
    }
  )
)


#' @export
length.Ark <- function(x) x$length()


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


#' Add column with pseudonyms to a data frame
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
