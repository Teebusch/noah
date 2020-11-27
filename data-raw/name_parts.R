## code to prepare `name_parts` dataset

library(noah)

name_parts <- readRDS("data-raw/name_parts.rds")

clean_name_parts <- utils::getFromNamespace("clean_name_parts", "noah")
name_parts <- clean_name_parts(name_parts)

usethis::use_data(name_parts, internal = TRUE, overwrite = TRUE)

