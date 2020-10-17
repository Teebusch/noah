## code to prepare `name_parts` dataset

name_parts <- readRDS("data-raw/words.rds")
name_parts <- purrr::map(name_parts, stringr::str_to_title)

usethis::use_data(name_parts, internal = TRUE, overwrite = TRUE)

