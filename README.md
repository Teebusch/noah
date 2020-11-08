
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noah <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/noah)](https://CRAN.R-project.org/package=noah)
[![R build
status](https://github.com/Teebusch/noah/workflows/R-CMD-check/badge.svg)](https://github.com/Teebusch/noah/actions)
[![Codecov test
coverage](https://codecov.io/gh/Teebusch/noah/branch/master/graph/badge.svg)](https://codecov.io/gh/Teebusch/noah?branch=master)

<!-- badges: end -->

noah (*no animals were harmed*) generates pseudonyms that are delightful
and easy to remember. It creates adorable anonymous animals like the
*Likeable Leech* and the *Proud Chickadee*.

## Installation

You can install noah from [Github](/https://github.com/teebusch/noah)
with:

``` r
# install.packages("remotes")
remotes::install_github("teebusch/noah")
```

## Usage

### Generating pseudonyms

Use `pseudonymize()` to generate a unique pseudonyms for every unique
element / row in a vectors or data frame. `pseudonymize()` accepts
multiple vectors and data frames as arguments, and will pseudonymize
them row by row.

``` r
library(noah)

pseudonymize(1:9)
#> [1] "Satisfying Roadrunner" "Belligerent Cat"       "Parallel Koala"       
#> [4] "Ripe Leopard"          "Elated Pony"           "Unbecoming Condor"    
#> [7] "Tacit Heron"           "Grandiose Peacock"     "Organic Roadrunner"

pseudonymize(
  c("🐰", "🐰", "🐰"), 
  c("🥕", "🥕", "🍰")
)
#> [1] "Curious Gull"     "Curious Gull"     "Extra-Large Wasp"
```

### Adding pseudonyms to data frames

In this example we use the diabetic retinopathy dataset from the package
`survival` and add a new column with a pseudonym for each unique id.
There are two ways to do this with noah:

#### Using `pseudonymize()`

Here we use `pseudonymize()` with `dplyr::mutate()`. We also use
relocate to move the pseudonyms to the first column:

``` r
library(dplyr)
diabetic <- as_tibble(survival::diabetic)

diabetic %>% 
  mutate(pseudonym = pseudonymize(id)) %>% 
  relocate(pseudonym)
#> # A tibble: 394 x 9
#>    pseudonym             id laser   age eye     trt  risk  time status
#>    <chr>              <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Waggish Caribou        5 argon    28 left      0     9  46.2      0
#>  2 Waggish Caribou        5 argon    28 right     1     9  46.2      0
#>  3 Furtive Capybara      14 xenon    12 left      1     8  42.5      0
#>  4 Furtive Capybara      14 xenon    12 right     0     6  31.3      1
#>  5 Weary Alligator       16 xenon     9 left      1    11  42.3      0
#>  6 Weary Alligator       16 xenon     9 right     0    11  42.3      0
#>  7 Aggressive Fox        25 xenon     9 left      0    11  20.6      0
#>  8 Aggressive Fox        25 xenon     9 right     1    11  20.6      0
#>  9 Utopian Parrotfish    29 xenon    13 left      0    10   0.3      1
#> 10 Utopian Parrotfish    29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

#### Using `add_pseudonyms()`

`add_pseudonyms()` wraps `mutate()` and `relocate()`. It also supports
[tidyselect](https://tidyselect.r-lib.org/reference/language.html)
syntax for selecting the key columns:

``` r
diabetic %>% 
  add_pseudonyms(id, where(is.factor))
#> # A tibble: 394 x 9
#>    pseudonym                   id laser   age eye     trt  risk  time status
#>    <chr>                    <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Yummy Ocelot                 5 argon    28 left      0     9  46.2      0
#>  2 Tidy Swift                   5 argon    28 right     1     9  46.2      0
#>  3 Exotic Aardvark             14 xenon    12 left      1     8  42.5      0
#>  4 Tasty Tern                  14 xenon    12 right     0     6  31.3      1
#>  5 Exciting Barracuda          16 xenon     9 left      1    11  42.3      0
#>  6 Astonishing Rat             16 xenon     9 right     0    11  42.3      0
#>  7 Holistic Sawfish            25 xenon     9 left      0    11  20.6      0
#>  8 Healthy Porcupine           25 xenon     9 right     1    11  20.6      0
#>  9 Cooperative Hippopotamus    29 xenon    13 left      0    10   0.3      1
#> 10 Utter Constrictor           29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

### Keeping track of pseudonyms with an `Ark`

To make sure that all pseudonyms are unique and consistent,
`pseudonymize()` and `add_pseudonyms()` use an object of class `Ark` (a
pseudonym archive) By default, a new `Ark` gets created implicitly for
each function call, but we can also provide an `Ark` ourselves, to keep
track of the pseudonyms that have been used and make sure that the same
keys always get assigned the same pseudonym:

``` r
ark <- Ark$new()

# split dataset into left and right eye and pseudonymize separately
diabetic_left <- diabetic %>% 
  filter(eye == "left") %>% 
  add_pseudonyms(id, .ark = ark)

diabetic_right <- diabetic %>% 
  filter(eye == "right") %>% 
  add_pseudonyms(id, .ark = ark)

# reunite the data sets again
bind_rows(diabetic_left, diabetic_right) %>% 
  arrange(id)
#> # A tibble: 394 x 9
#>    pseudonym              id laser   age eye     trt  risk  time status
#>    <chr>               <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Nauseating Basilisk     5 argon    28 left      0     9  46.2      0
#>  2 Nauseating Basilisk     5 argon    28 right     1     9  46.2      0
#>  3 Discreet Marlin        14 xenon    12 left      1     8  42.5      0
#>  4 Discreet Marlin        14 xenon    12 right     0     6  31.3      1
#>  5 Violent Guan           16 xenon     9 left      1    11  42.3      0
#>  6 Violent Guan           16 xenon     9 right     0    11  42.3      0
#>  7 Abashed Loris          25 xenon     9 left      0    11  20.6      0
#>  8 Abashed Loris          25 xenon     9 right     1    11  20.6      0
#>  9 Illustrious Leech      29 xenon    13 left      0    10   0.3      1
#> 10 Illustrious Leech      29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

The ark now contains 197 pseudonyms – as many as there are unique id’s
in the dataset.

``` r
length(unique(diabetic$id))
#> [1] 197
length(ark)
#> [1] 197
```

### Making an alliterating Ark

For extra delight, we can also configure an `Ark` so that it generates
only alliterations:

``` r
ark <- Ark$new(alliterate = TRUE)

pseudonymize(1:12, .ark = ark)
#>  [1] "Crazy Cobra"           "Whimsical Waterbuck"   "Enchanted Egret"      
#>  [4] "Damaging Dragonfly"    "Taboo Toad"            "Material Marmoset"    
#>  [7] "Rabid Roundworm"       "Oval Ox"               "Venomous Voalavoanala"
#> [10] "Average Ant"           "Frightening Ferret"    "Educated Elephant"
```

## Related R packages

There are multiple R packages that generate fake data, including fake
names, phone numbers, addresses, credit card numbers, gene sequences and
more:

  - [`charlatan`](https://docs.ropensci.org/charlatan/)
  - [`randomNames`](https://centerforassessment.github.io/randomNames/)
  - [`randNames`](https://github.com/karthik/randNames)
  - [`generator`](https://github.com/paulhendricks/generator)

If you need watertight anonymization you should check out these packages
for anonymizing personal identifiable information in data sets:

  - [`sdcMicro`](http://sdctools.github.io/sdcMicro/index.html)
  - [`sdcTable`](https://sdctools.github.io/sdcTable/index.html)
  - [`anonymizer`](http://paulhendricks.io/anonymizer/)
