
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noah

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/noah)](https://CRAN.R-project.org/package=noah)
[![R build
status](https://github.com/Teebusch/noah/workflows/R-CMD-check/badge.svg)](https://github.com/Teebusch/noah/actions)
[![Codecov test
coverage](https://codecov.io/gh/Teebusch/noah/branch/master/graph/badge.svg)](https://codecov.io/gh/Teebusch/noah?branch=master)

[![R build
status](https://github.com/Teebusch/noah/workflows/R-CMD-check/badge.svg)](https://github.com/Teebusch/noah/actions)
<!-- badges: end -->

`noah` (**no** **a**nimals were **h**armed) generates pseudonyms that
are delightful and easy to remember. Instead of cryptic alphanumeric
IDs, `noah` generates anonymous animals like the *Likeable Leech* and
the *Proud Chickadee*.

## Installation

You can install the development version of noah from
[Github](/https://github.com/teebusch/noah) with:

``` r
# install.packages("remotes")
remotes::install_github("teebusch/noah")
```

## Usage

### Generating pseudonyms

A quick way to create pseudonyms with `noah` is to use the
`pseudonymize()` function. It will generate pseudonyms for every element
in a vector. Note that repeated elements will receive the same
pseudonym:

``` r
library(noah)

pseudonymize(rep(1:6, each = 2))
#>  [1] "Sad Roadrunner"  "Sad Roadrunner"  "Belligerent Cat" "Belligerent Cat"
#>  [5] "Pale Koala"      "Pale Koala"      "Rich Leopard"    "Rich Leopard"   
#>  [9] "Efficient Pony"  "Efficient Pony"  "Typical Condor"  "Typical Condor"
```

`pseudonymize()` takes any number of input vectors, as long as they are
the same length. It will treat the elements in the same position as
being from the same subject.

``` r
pseudonymize(
  c("😙", "😙", "😙"), 
  c("🥕", "🥕", "🍰")
)
#> [1] "Alike Clam"       "Alike Clam"       "Coherent Ladybug"
```

### Adding pseudonyms to a data frame

Often we may want to add a column with pseudonyms to a data frame, using
one or more of the columns as identifiers. We can do this with
`pseudonymize()` and `dplyr::mutate()`.

Here we use the diabetic retinopathy dataset from the `survival` package
and add a new column with a pseudonym for each unique `id`:

``` r
library(dplyr)
diabetic <- dplyr::as_tibble(survival::diabetic)

diabetic %>% 
  mutate(pseudonym = pseudonymize(id)) %>% 
  relocate(pseudonym)
#> # A tibble: 394 x 9
#>    pseudonym          id laser   age eye     trt  risk  time status
#>    <chr>           <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Eight Swordfish     5 argon    28 left      0     9  46.2      0
#>  2 Eight Swordfish     5 argon    28 right     1     9  46.2      0
#>  3 Standing Serval    14 xenon    12 left      1     8  42.5      0
#>  4 Standing Serval    14 xenon    12 right     0     6  31.3      1
#>  5 Silent Krill       16 xenon     9 left      1    11  42.3      0
#>  6 Silent Krill       16 xenon     9 right     0    11  42.3      0
#>  7 Graceful Bull      25 xenon     9 left      0    11  20.6      0
#>  8 Graceful Bull      25 xenon     9 right     1    11  20.6      0
#>  9 Lame Giraffe       29 xenon    13 left      0    10   0.3      1
#> 10 Lame Giraffe       29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

\#@ Keeping track of pseudonyms

Internally, `pseudonymize()` uses an object of class `Ark` that acts
like a pseudonym dictionary and keeps track of pseudonyms that have been
used. Normally, a new `Ark` is built for each call of the
`pseudonymize()` function. However, we can use an `Ark` to ensure that
the same input is always assigned the same pseudonym across multiple
data sets:

``` r
ark <- Ark$new()

# split dataset into left and right eye and pseudonymize separately
diabetic_left <- diabetic %>% 
  filter(eye == "left") %>% 
  mutate(pseudonym = pseudonymize(id, .ark = ark))

diabetic_right <- diabetic %>% 
  filter(eye == "right") %>% 
  mutate(pseudonym = pseudonymize(id, .ark = ark))

# reunite the data sets again
bind_rows(diabetic_left, diabetic_right) %>% 
  relocate(pseudonym) %>% 
  arrange(id)
#> # A tibble: 394 x 9
#>    pseudonym           id laser   age eye     trt  risk  time status
#>    <chr>            <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Flaky Shrimp         5 argon    28 left      0     9  46.2      0
#>  2 Flaky Shrimp         5 argon    28 right     1     9  46.2      0
#>  3 Green Stingray      14 xenon    12 left      1     8  42.5      0
#>  4 Green Stingray      14 xenon    12 right     0     6  31.3      1
#>  5 Spectacular Newt    16 xenon     9 left      1    11  42.3      0
#>  6 Spectacular Newt    16 xenon     9 right     0    11  42.3      0
#>  7 Moldy Lionfish      25 xenon     9 left      0    11  20.6      0
#>  8 Moldy Lionfish      25 xenon     9 right     1    11  20.6      0
#>  9 Huge Manatee        29 xenon    13 left      0    10   0.3      1
#> 10 Huge Manatee        29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```
