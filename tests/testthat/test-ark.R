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

test_that("Multiple values can be pseudonymized", {
  res <- pseudonymize(c("Mata Hari", "James Bond", "Lewis Carroll"))
  expect_equal(length(res), 3)
})
