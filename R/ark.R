#' A pseudonym archive.
#'
#' @description
#' An Ark object can create and remember pseudonyms.
#' Given the same input, it will always return the same pseudonym.
#' No pseudonym will repeat.
#'
#' @export

Ark <- R6::R6Class("Ark",
  public = list(

    #' @field log Hashtable for all used pseudonyms. Inputs (keys) are stored
    #' as hashes.
    log = NULL,

    #' @description Create new ark object.
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
