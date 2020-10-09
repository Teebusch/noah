test_that("Ark object can be created", {
  ark <- Ark$new()
  expect_s3_class(ark, "Ark")
  expect_s3_class(ark, "R6")
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
  max_length <- ark$.__enclos_env__$private$max_length
  f <- ark$.__enclos_env__$private$index_to_pseudonym  # shortcut
  expect_equal(f(1), "Alert Ant")
  expect_equal(f(c(1,2,3)), c("Alert Ant", "Alert Bear", "Alert Cat"))
  expect_length(f(1:max_length), max_length)
  expect_type(f(1:max_length), "character")
})

test_that("Fail when requesting more pseudonyms than available", {
  ark <- Ark$new()
  max_length <- ark$.__enclos_env__$private$max_length
  f <- ark$.__enclos_env__$private$index_to_pseudonym  # shortcut
  expect_error(f(max_length+1))
  expect_error(f(1:(max_length+1)))
})

test_that("Multiple values can be pseudonymized", {
  res <- pseudonymize(c("Mata Hari", "James Bond", "Lewis Carroll"))
  expect_equal(length(res), 3)
})

