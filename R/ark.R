#' A Class to represent an ark.
#'
#' An Ark object can create unique pseudonyms.
#' Given the same input, it will always return the same psuedonym.
#' No pseudonym will repeat.
Ark <- R6::R6Class("Ark",
  public = list(
    #' @description
    #' Create new arc object.
    #' @return A new `Ark` object.
    initialize = function() {
      private$pseudonym_parts <- list(
        c("Alert", "Brazen", "Clever", "Docile", "Eager"),
        c("Ant", "Bear", "Cat", "Dog", "Eagle", "Friendly")
      )
      private$max_length <- prod(lengths(private$pseudonym_parts))
      self$log <- hash::hash()
    },

    #' @description
    #' Print Ark object.
    #' @examples
    #' ark <- Ark()
    #' print(ark)
    print = function() {
      cat("Ark of size ", private$max_length, "\n", sep = "")
      if (self$length() > 0) {
        log_entries <- paste(hash::keys(private$log), '→',
                             hash::values(private$log))
        cat("Logbook:\n--------\n")
        cat(log_entries, sep = "\n")
      } else {
        cat("no one on board")
      }
      invisible(self)
    },

    length = function(...) {
      length(self$log)
    },

    as.list = function() {
      list(1,2,3)
    },

    pseudonymize = function(...) {
      dots <- list(...)
      uid <- digest::digest(dots)
      pseudonym <- "foo bar"
      self$log[[uid]] <- pseudonym
    },

    log = NULL
  ),
  private = list(
    pseudonym_parts = NULL,
    max_length = NULL
  )
)


#' Length of an Ark
#'
#' @param x
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
length.Ark <- function(obj, ...) {
  obj$length()
}

#' Create unique pseudonyms
#'
#' This is a pipe-friendly function.
#'
#' @param ... One or multiple objects for which pseudonyms should be created,
#' usually one or more columns of a data frame. All objects must be of the same
#' length.
#' @param .ark An Ark object. By default a new Ark is created. Using an existing
#' Ark makes sure that the same input returns the same pseudonym.
#'
#' @return
#' @export
#'
#' @examples
pseudonymize <- function(..., .ark = Ark$new()){
  .ark$pseudonymize(...)
}
