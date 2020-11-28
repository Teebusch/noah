## code to prepare `name_parts` dataset

library(noah)

clean_name_parts <- utils::getFromNamespace("clean_name_parts", "noah")

name_parts <- readRDS("data-raw/name_parts.rds")
name_parts <- clean_name_parts(name_parts)
name_parts <- purrr::map(name_parts, stringr::str_to_title)

usethis::use_data(name_parts, internal = TRUE, overwrite = TRUE)
