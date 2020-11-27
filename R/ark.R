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
    #' @param alliterate Logical. Should the Ark return alliterations by
    #' default?
    #' @param parts List of character vectors with name parts to be used for the
    #' pseudonyms. Defaults to adjectives and animals.
    #' @return A new `Ark` object.
    initialize = function(alliterate = FALSE, parts = NULL) {
      private$parts <- if (is.null(parts)) {
        name_parts[c("adjectives", "animals")]
      } else {
        clean_name_parts(parts)
      }

      private$max_total  <- prod(lengths(private$parts))
      private$index_perm  <- random_permutation(private$max_total)

      index_allit         <- private$find_alliterations()
      private$max_allit   <- length(index_allit)
      private$index_allit <- random_permutation(index_allit)
      private$alliterate  <- alliterate

      self$log            <- hash::hash()
    },

    #' @description Create Pseudonyms for input.
    #' @param ... One or more R objects.
    #' @param .alliterate Logical. Return only pseudonyms that are
    #' alliterations. Defaults to TRUE if the Ark was created with
    #' `Ark$new(alliterate = TRUE)`, FALSE otherwise. If FALSE, pseudonyms
    #' may still be alliterations by coincidence.
    #' @return Character vector of pseudonyms with same length as input.
    pseudonymize = function(..., .alliterate = NULL) {
      .alliterate <- .alliterate %||% private$alliterate
      assertthat::is.flag(.alliterate)

      keys       <- suppressMessages(dplyr::bind_cols(...))
      keys       <- purrr::pmap_chr(keys,
                                    function(...) digest::digest(list(...)))
      n_keys     <- length(keys)
      is_in      <- hash::has.key(keys, self$log)
      n_new      <- sum(!is_in)

      if (n_new > 0) {
        if (.alliterate) {
          i <- private$index_allit(n_new)
          private$index_perm <- remove_remaining(private$index_perm, i)
        } else {
          i <- private$index_perm(n_new)
          private$index_allit <- remove_remaining(private$index_allit, i)
        }
        self$log[keys[!is_in]] <- private$index_to_pseudonym(i)
      }

      out <- hash::values(self$log, keys, USE.NAMES = FALSE)
      out
    },

    #' @description Pretty-print an Ark object.
    #' @param n A positive integer. The number of example pseudonyms to print.
    print = function(n = NULL) {

      subtle <- crayon::make_style("grey60")

      # summary
      used_total <- self$length()
      used_allit <- self$length_allit()
      perc_total <- (used_total / private$max_total) * 100
      perc_allit <- (used_allit / private$max_allit) * 100

      cat(
        subtle(
          sprintf(
            "# An%sArk",
            if(private$alliterate) " alliterating " else " "
          )
        ),
        subtle(
          sprintf(
            "# %i / %i pseudonyms used (%0.0f%%)",
            used_total, private$max_total, perc_total
          )
        ),
        subtle(
          sprintf(
            "# %i / %i alliterations used (%0.0f%%)\n",
            used_allit, private$max_allit, perc_allit
          )
        ),
        sep = "\n"
      )

      # entries
      if (self$length() == 0) {
        cat("The Ark is empty.")
      } else if (self$length() >= private$max_total) {
        cat("The Ark is full")
      } else {
        if (is.null(n)) {
          n <- 10
        } else {
          assertthat::assert_that(is.numeric(n))
          assertthat::assert_that(n > 0)
        }
        n_max <- length(self$log)
        i_max <- min(n, n_max)
        i <- 1:i_max
        k <- hash::keys(self$log)[1:i_max]
        v <- hash::values(self$log)[1:i_max]

        cat(sprintf(
          "%*s key %*s pseudonym\n",
          nchar(i_max), " ", 7, " "
        ))
        cat(
          subtle(
            crayon::italic(
              sprintf(
                "%*s <md5> %*s <Attribute Animal>\n",
                nchar(i_max), " ", 5, " "
              )
            )
          )
        )
        cat(sprintf(
          "%*s %.8s... %s",
          nchar(i_max), i, k, v
        ), sep = "\n")

        if (i_max < n_max) {
          cat(
            subtle(
              sprintf("# ...with %i more entries", n_max - i_max)
            )
          )
        }
      }
      invisible(self)
    },

    #' @description Number of used pseudonyms in an Ark.
    length = function() {
      length(self$log)
    },


    #' @description Number of used alliterations in an Ark.
    length_allit = function() {
      private$max_allit - get_n_remaining(private$index_allit)
    }
  ),

  private = list(

    #' @field parts Words that will be combined to form pseudonyms.
    parts = NULL,

    #' @field max_total Maximum number of possible pseudonyms in the Ark.
    max_total = NULL,

    #' @field max_allit Maximum number of possible alliterations in the Ark.
    max_allit = NULL,

    #' @field alliterate Logical, generate alliterations by default?
    alliterate = NULL,

    #' @field index_allit a random permutation of indices of alliterations
    index_allit = NULL,

    #' @field index_perm a random permutation of the index
    index_perm = NULL,

    #' @description Returns the pseudonym corresponding to an index.
    #' @param index An integer or a vector of integers between 1 and the Ark's
    #' max_total.
    #' @return A character vector of pseudonyms with the same length as the
    #' input
    index_to_pseudonym = function(index) {
      subs <- ind2subs(index, lengths(private$parts))

      purrr::pmap_chr(
        purrr::map2(private$parts, subs, ~ .x[.y]), paste
      )
    },

    #' @description Find all pseudonyms that are alliterations.
    #' @return Numerical vector containing indexes of all pseudonyms that are
    #' alliterations.
    find_alliterations = function() {
      first_letters <- purrr::map(private$parts, ~ substr(.x, 1, 1))

      # get subscripts of all name parts with matching first letter
      subs <- purrr::map_dfr(LETTERS, function(ltr) {
          purrr::map(first_letters, ~ which(.x == ltr)) %>%
            expand.grid()
      })

      subs2ind(subs, lengths(private$parts))
    }
  )
)


#' @export
length.Ark <- function(x) x$length()


#' Cleans name parts for use by an Ark.
#'
#' @keywords internal
clean_name_parts <- function(parts) {
  purrr::map(parts, ~
   .x %>%
   stringr::str_squish() %>%
   stringr::str_to_title() %>%
   unique()
  )
}
