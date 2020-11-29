test_that("Ark object can be created", {
  ark <- Ark$new()
  expect_s3_class(ark, "Ark")
  expect_s3_class(ark, "R6")
})

test_that("Ark object can be initialized with custom name parts", {
  ark <- Ark$new(parts = list(
    foo = sample(name_parts[[1]], 42),
    bar = sample(name_parts[[2]], 42)
  ))
  max_total <- ark$.__enclos_env__$private$max_total
  expect_s3_class(ark, "Ark")
  expect_s3_class(ark, "R6")
  expect_equal(max_total, 42*42)
})

test_that("custom name parts can have more than two dimensions", {
  ark <- Ark$new(parts = list(
    foo = sample(name_parts[[1]], 42),
    bar = sample(name_parts[[1]], 42),
    baz = sample(name_parts[[2]], 42)
  ))
  max_total <- ark$.__enclos_env__$private$max_total
  expect_s3_class(ark, "Ark")
  expect_s3_class(ark, "R6")
  expect_equal(max_total, 42*42*42)
})

test_that("A single value can be pseudonymized", {
  res <- pseudonymize("Mata Hari")
  expect_true(res != "Mata Hari")
  expect_type(res, "character")
})

test_that("Ark length method works", {
  ark <- Ark$new()
  expect_equal(ark$length(), 0)
  expect_equal(length(ark), 0)

  ark$pseudonymize("Mata Hari")
  expect_equal(ark$length(), 1)
  expect_equal(length(ark), 1)
})

test_that("Creating pseudonyms from index works", {
  ark <- Ark$new()
  max_total <- ark$.__enclos_env__$private$max_total
  f <- ark$.__enclos_env__$private$index_to_pseudonym  # shortcut
  expect_type(f(1), "character")
  expect_vector(f(c(1,2,3)))
  expect_length(f(c(1,2,3)), 3)
  expect_length(f(1:max_total), max_total)
  expect_type(f(1:max_total), "character")
})

test_that("Fail when requesting more pseudonyms than available", {
  ark <- Ark$new(parts = list(
    foo = sample(name_parts[[1]], 10),
    bar = sample(name_parts[[2]], 10)
  ))
  max_total <- 10 * 10
  expect_vector(ark$pseudonymize(1:max_total))
  expect_error(ark$pseudonymize(1:(max_total + 1)))
  expect_error(ark$pseudonymize("foo"))
})

test_that("Multiple values can be pseudonymized", {
  res <- pseudonymize(c("Mata Hari", "James Bond", "Lewis Carroll"))
  expect_equal(length(res), 3)
})

test_that("same pseudonym for same input", {
  ark <- Ark$new()
  a <- 1:10
  expect_equal(
    pseudonymize(a, .ark = ark), pseudonymize(a, .ark = ark)
  )
})

test_that("Different pseudonym for different input", {
  ark <- Ark$new()
  a <- 1:10
  b <- letters[1:10]
  expect_true(
    all(pseudonymize(a, .ark = ark) != pseudonymize(b, .ark = ark))
  )
})

test_that("same pseudonym for same input when using integers", {
  ark <- Ark$new()
  ark$pseudonymize(1:5)
  ark$pseudonymize(5L)
  # ark$pseudonymize(5)  # This is treated as float and gets it's own pseudonym!

  expect_equal(length(ark), 5)
})

test_that("Multiple vectors can be pseudonymized", {
  ark <- Ark$new()
  a <- 1:10
  b <- letters[1:10]
  c <- letters[11:20]
  expect_true(
    all(pseudonymize(a, b, .ark = ark) != pseudonymize(a, c, .ark = ark))
  )
})

test_that("Fail when input vectors have different lengths", {
  expect_error(pseudonymize(1:3, 4:5))
  expect_error(pseudonymize(mtcars, 1:(nrow(mtcars)-1)))
})

test_that("Data frame columns can be pseudonymized", {
  ark <- Ark$new()
  df <- data.frame(
    a = 1:10,
    b = letters[1:10],
    c = letters[11:20]
  )
  df <- dplyr::mutate(
    df,
    ab = pseudonymize(a, b, .ark = ark),
    bc = pseudonymize(b, c, .ark = ark),
    ca = pseudonymize(c, a, .ark = ark)
  )
  expect_true(all(df$ab != df$bc))
  expect_true(all(df$bc != df$ca))
  expect_true(all(df$ca != df$ab))
})


test_that("Data frame can be pseudonymized", {
  ark <- Ark$new()
  df <- data.frame(
    a = 1:10,
    b = letters[1:10]
  )
  res1 <- pseudonymize(df, .ark = ark)
  expect_length(res1, nrow(df))
  df$b <- letters[11:20]
  res2 <- pseudonymize(df, .ark = ark)
  expect_length(res2, nrow(df))
  expect_true(all(res1 != res2))
})

test_that("pseudonymize() fails when .ark is not an Ark", {
  expect_error(pseudonymize("foo", .ark = data.frame()))
})

test_that("add_pseudonyms() adds column with pseudonyms", {
  res <- add_pseudonyms(mtcars)
  expect_type(res$pseudonym, "character")
})

test_that("add_pseudonyms() column name can be changed", {
  res <- add_pseudonyms(mtcars, .name = "foo")
  expect_type(res$foo, "character")
})

test_that("add_pseudonyms() can use ark", {
  ark <- Ark$new()
  df <- mtcars
  res1 <- add_pseudonyms(df, .ark = ark)
  res2 <- add_pseudonyms(df, .ark = ark)
  expect_equal(res1$pseudonym, res2$pseudonym)
})

test_that("add_pseudonyms() column selection works", {
  ark <- Ark$new()
  res <- mtcars
  res <- add_pseudonyms(res, mpg, cyl, .name = "foo", .ark = ark)
  res <- add_pseudonyms(res, cyl, mpg, .name = "bar", .ark = ark)
  res <- add_pseudonyms(res, cyl, mpg, .name = "baz", .ark = ark)

  expect_false(all(res$foo == res$bar))
  expect_equal(res$bar, res$baz)
})

test_that("add_pseudonyms() supports tidyselect syntax", {
  ark <- Ark$new()
  res1 <- add_pseudonyms(mtcars, where(is.numeric), .ark = ark)
  res2 <- add_pseudonyms(mtcars, everything(), .ark = ark)
  res3 <- add_pseudonyms(mtcars, mpg, cyl:gear, carb, .ark = ark)
  res4 <- add_pseudonyms(mtcars, mpg, dplyr::ends_with("t"), carb, .ark = ark)

  expect_equal(res1$pseudonym, res2$pseudonym)
  expect_equal(res2$pseudonym, res3$pseudonym)
  expect_false(all(res3$pseudonym == res4$pseudonym))
})

test_that("add_pseudonyms() fails when no columns are selected", {
  expect_error(add_pseudonyms(mtcars, matches("foo")))
})

test_that("Ark print function prints something", {
  ark <- Ark$new()
  expect_that(
    print(ark),
    prints_text("An Ark.+The Ark is empty.")
  )
  pseudonymize(1:20, .ark = ark)
  expect_that(
    print(ark),
    prints_text("An Ark.+key\\s*pseudonym.+with 10 more entries")
  )
})

test_that("Ark print n argument works", {
  ark <- Ark$new()
  pseudonymize(1:20, .ark = ark)
  expect_that(
    print(ark),
    prints_text("\\.\\.\\.with 10 more entries")
  )
  expect_that(
    print(ark, n = 15),
    prints_text("\\.\\.\\.with 5 more entries")
  )
})

test_that("Alliterations work with alliterating Ark", {
  ark <- Ark$new(alliterate = TRUE)
  res <- pseudonymize(1:10, .ark = ark)
  res <- strsplit(res, " ")
  res <- lapply(res, function(x) substr(x, 1, 1))
  res <- sapply(res, function(x) length(unique(x)) == 1)
  expect_true(all(res))
})

test_that("Alliterations work with `pseudonymize()`", {
  ark <- Ark$new(alliterate = TRUE)
  res <- ark$pseudonymize(1:10, .alliterate = TRUE)
  res <- strsplit(res, " ")
  res <- lapply(res, function(x) substr(x, 1, 1))
  res <- sapply(res, function(x) length(unique(x)) == 1)
  expect_true(all(res))
})

test_that("Alliterations work with custom name parts and more than two
          dimensions", {
  set.seed(1234)
  ark <- Ark$new(parts = list(
    foo = sample(name_parts[[1]], 100),
    bar = sample(name_parts[[1]], 100),
    baz = sample(name_parts[[2]], 100)
  ))
  res <- pseudonymize(1:10, .ark = ark, .alliterate = TRUE)
  res <- strsplit(res, " ")
  res <- lapply(res, function(x) substr(x, 1, 1))
  res <- sapply(res, function(x) length(unique(x)) == 1)
  expect_true(all(res))
})

test_that("ark can produce max_total unique pseudonyms using custom name
          parts", {
  ark <- Ark$new(parts = list(
    foo = sample(name_parts[[1]], 10),
    bar = sample(name_parts[[2]], 10)
  ))
  max_total <- ark$.__enclos_env__$private$max_total
  res <- ark$pseudonymize(1:max_total)
  expect_length(unique(res), max_total)
  expect_length(res, max_total)
})

test_that("ark can produce max_total unique pseudonyms", {
  skip("Long-running test skipped. Using shorter version.")
  skip_on_cran()
  ark <- Ark$new()
  max_total <- ark$.__enclos_env__$private$max_total
  res <- ark$pseudonymize(1:max_total)
  expect_length(unique(res), max_total)
  expect_length(res, max_total)
})

test_that("alliterate TRUE/FALSE can be mixed without pseudonyms repeating when
          using custom name parts", {
  ark <- Ark$new(parts = list(
    foo = sample(name_parts[[1]], 100),
    bar = sample(name_parts[[2]], 100)
  ))
  n <- ark$.__enclos_env__$private$max_total
  k <- 100
  x <- pseudonymize(1:k, .alliterate = TRUE, .ark = ark)
  y <- pseudonymize((k+1):n, .alliterate = FALSE, .ark = ark)
  expect_true(length(union(x,y)) == n)
})

test_that("alliterate TRUE/FALSE can be mixed without pseudonyms repeating", {
  skip("Long-running test skipped. Using shorter version.")
  skip_on_cran()
  ark <- Ark$new()
  n <- ark$.__enclos_env__$private$max_total
  k <- 1000
  x <- pseudonymize(1:k, .alliterate = TRUE, .ark = ark)
  y <- pseudonymize((k+1):n, .alliterate = FALSE, .ark = ark)
  expect_true(length(union(x,y)) == n)
})
