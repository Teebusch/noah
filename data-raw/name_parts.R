## code to prepare `name_parts` dataset

name_parts <- readRDS("data-raw/name_parts.rds")
name_parts <- purrr::map(name_parts, stringr::str_to_title)
name_parts <- purrr::map(name_parts, unique)

usethis::use_data(name_parts, internal = TRUE, overwrite = TRUE)

