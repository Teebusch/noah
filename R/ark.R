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
      # convert  arguments to a data frame, then hash each row ans lookup or
      # create pseudonym.
      keys <- dplyr::bind_cols(...)

      purrr::pmap_chr(keys, function(...) {
        uid <- digest::digest(list(...))

        if (!hash::has.key(uid, self$log)) {
          index <- self$length() + 1
          self$log[uid] <- private$index_to_pseudonym(index)
        }

        self$log[[uid]]
      })
    },

    #' @description Pretty-print an Ark object.
    #' @param n A positive integer. The number of example pseudonyms to print.
    print = function(n = NULL) {

      subtle <- crayon::make_style("grey60")

      # summary
      perc_full <- self$length() / private$max_length
      cat(
        subtle(
          sprintf(
            "# An Ark: %i / %i pseudonyms used (%0.0f%%)\n",
            self$length(), private$max_length, perc_full
          )
        )
      )

      # entries
      if (self$length() == 0) {
        cat("The Ark is empty.")
      } else if (self$length() >= private$max_length) {
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
