## code to prepare `parts` dataset

parts = list(
  c("Alert", "Brazen", "Clever", "Docile", "Eager"),
  c("Ant", "Bear", "Cat", "Dog", "Eagle", "Fox")
)


usethis::use_data(parts, internal = TRUE, overwrite = TRUE, compress = "gzip")
