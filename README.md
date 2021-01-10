
<!-- README.md is generated from README.Rmd. Please edit that file -->

# noah <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
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

Noah is not yet on CRAN, but you can install it from
[Github](/https://github.com/teebusch/noah) with:

``` r
# install.packages("remotes")
remotes::install_github("teebusch/noah")
```

## Usage

### Generate pseudonyms

Use `pseudonymize()` to generate a unique pseudonym for every unique
element / row in a vector or data frame. `pseudonymize()` accepts
multiple vectors and data frames as arguments, and will pseudonymize
them row by row.

``` r
library(noah)

pseudonymize(1:9)
#> [1] "Impartial Rat"       "Superficial Bird"    "Royal Orca"         
#> [4] "Earsplitting Python" "Fascinated Donkey"   "Defeated Trout"     
#> [7] "Encouraging Stoat"   "Null Grouse"         "Axiomatic Octopus"

pseudonymize(
  c("🐰", "🐰", "🐰"), 
  c("🥕", "🥕", "🍰")
)
#> [1] "Bloody Clam"     "Bloody Clam"     "Depressed Egret"
```

For extra delight, we can ask noah to generate only alliterations:

``` r
pseudonymize(1:9, .alliterate = TRUE)
#> [1] "Safe Sole"             "Callous Clownfish"     "Polite Panda"         
#> [4] "Best Badger"           "Like Leopard"          "Many Mole"            
#> [7] "Smiling Slug"          "Sweltering Silverfish" "Sick Sloth"
```

### Add pseudonyms to a data frame

You can use `pseudonymize()` with `dplyr::mutate()` to add a column with
pseudonyms to a data frame. In this example we use the diabetic
retinopathy dataset from the package `survival` and add a new column
with a pseudonym for each unique id. We also use `dplyr::relocate()` to
move the pseudonyms to the first column:

``` r
library(dplyr)
diabetic <- as_tibble(survival::diabetic)

diabetic %>% 
  mutate(pseudonym = pseudonymize(id)) %>% 
  relocate(pseudonym)
#> # A tibble: 394 x 9
#>    pseudonym               id laser   age eye     trt  risk  time status
#>    <chr>                <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Possessive Armadillo     5 argon    28 left      0     9  46.2      0
#>  2 Possessive Armadillo     5 argon    28 right     1     9  46.2      0
#>  3 Crowded Vole            14 xenon    12 left      1     8  42.5      0
#>  4 Crowded Vole            14 xenon    12 right     0     6  31.3      1
#>  5 Productive Heron        16 xenon     9 left      1    11  42.3      0
#>  6 Productive Heron        16 xenon     9 right     0    11  42.3      0
#>  7 Frequent Okapi          25 xenon     9 left      0    11  20.6      0
#>  8 Frequent Okapi          25 xenon     9 right     1    11  20.6      0
#>  9 Giant Lobster           29 xenon    13 left      0    10   0.3      1
#> 10 Giant Lobster           29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

For your convenience, noah also provides `add_pseudonyms()`, which wraps
`mutate()` and `relocate()` and supports
[tidyselect](https://tidyselect.r-lib.org/reference/language.html)
syntax for selecting the key columns:

``` r
diabetic %>% 
  add_pseudonyms(id, where(is.factor))
#> # A tibble: 394 x 9
#>    pseudonym                id laser   age eye     trt  risk  time status
#>    <chr>                 <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Doubtful Horse            5 argon    28 left      0     9  46.2      0
#>  2 Caring Heron              5 argon    28 right     1     9  46.2      0
#>  3 Grey Chicken             14 xenon    12 left      1     8  42.5      0
#>  4 Giddy Vole               14 xenon    12 right     0     6  31.3      1
#>  5 Overrated Caterpillar    16 xenon     9 left      1    11  42.3      0
#>  6 Angry Oribi              16 xenon     9 right     0    11  42.3      0
#>  7 Roasted Sawfish          25 xenon     9 left      0    11  20.6      0
#>  8 Spectacular Lion         25 xenon     9 right     1    11  20.6      0
#>  9 Panoramic Owl            29 xenon    13 left      0    10   0.3      1
#> 10 Orange Bear              29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

### Keeping track of pseudonyms with an Ark

To make sure that all pseudonyms are unique and consistent,
`pseudonymize()` and `add_pseudonyms()` use an object of class `Ark` (a
pseudonym archive). By default, a new `Ark` is created for each function
call, but you can also provide an `Ark` yourself. This allows you to
keep track of the pseudonyms that have been used and make sure that the
same keys always get assigned the same pseudonym:

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
#>    pseudonym          id laser   age eye     trt  risk  time status
#>    <chr>           <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Faulty Swift        5 argon    28 left      0     9  46.2      0
#>  2 Faulty Swift        5 argon    28 right     1     9  46.2      0
#>  3 Tart Crab          14 xenon    12 left      1     8  42.5      0
#>  4 Tart Crab          14 xenon    12 right     0     6  31.3      1
#>  5 Sticky Barnacle    16 xenon     9 left      1    11  42.3      0
#>  6 Sticky Barnacle    16 xenon     9 right     0    11  42.3      0
#>  7 Brainy Moth        25 xenon     9 left      0    11  20.6      0
#>  8 Brainy Moth        25 xenon     9 right     1    11  20.6      0
#>  9 Poised Urial       29 xenon    13 left      0    10   0.3      1
#> 10 Poised Urial       29 xenon    13 right     1     9  38.8      0
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

### Customizing an Ark

Building your own Ark allows you to customize the name parts that are
used to create pseudonyms (by default, adjectives and animals). It also
allow you to use names with more than two parts:

``` r
ark <- Ark$new(parts = list(
  c("Charles", "Louis", "Henry", "George"),
  c("I", "II", "III", "IV"),
  c("The Good", "The Wise", "The Brave", "The Mad", "The Beloved")
))

pseudonymize(1:8, .ark = ark)
#> [1] "Louis IV The Brave"   "George II The Good"   "Louis I The Good"    
#> [4] "Charles IV The Wise"  "Charles IV The Brave" "Louis II The Mad"    
#> [7] "Charles I The Brave"  "George I The Beloved"
```

You can also configure an `Ark` so that it generates only alliterations.
Note that this behavior can still be overridden temporarily by using
`.alliterate = FALSE` when you call `pseudonymize()`.

``` r
ark <- Ark$new(alliterate = TRUE)

pseudonymize(1:12, .ark = ark)
#>  [1] "Hard-To-Find Hyena" "Well-Made Whippet"  "Momentous Mosquito"
#>  [4] "Mushy Macaw"        "Complete Clownfish" "Three Tahr"        
#>  [7] "Phobic Pheasant"    "Squealing Swallow"  "Subdued Swan"      
#> [10] "Mundane Marsupial"  "Complex Centipede"  "Cruel Crane"
```

## Gotchas

Noah will treat numerically identical whole numbers of type `double` and
`integer` as different and give them different pseudonyms. This can
cause some unexpected behavior. Consider this example:

``` r
ark <- Ark$new()

pseudonymize(1:2, .ark = ark)  # creates a vector of integers c(1L, 2L)
pseudonymize(1, .ark = ark)    # creates a double
#> Note. All of your numerical keys are integer numbers but have type double. `pseudonymize()` will treat numerically equivalent double and integer keys as different and assign them different pseudonyms. Use explicit coercion to avoid unexpected behavior.
```

You might expect to get 2 different pseudonyms, because in the second
`pseudonymize()` you are requesting a pseudonym for the number `1`,
which is already in the Ark. Instead you get three pseudonyms:

``` r
length(ark)
#> [1] 3
```

Noah will warn you when it thinks you are making this mistake, but it
might not catch it all the time. A workaround is to coerce types
explicitly, for example by using `as.double()`, `as.integer()`, or `1L`
to create integers.

## Related R packages

There are multiple R packages that generate fake data, including fake
names, phone numbers, addresses, credit card numbers, gene sequences and
more:

-   [`charlatan`](https://docs.ropensci.org/charlatan/)
-   [`randomNames`](https://centerforassessment.github.io/randomNames/)
-   [`randNames`](https://github.com/karthik/randNames)
-   [`generator`](https://github.com/paulhendricks/generator)

If you need watertight anonymization you should check out these packages
for anonymizing personal identifiable information in data sets:

-   [`sdcMicro`](http://sdctools.github.io/sdcMicro/index.html)
-   [`sdcTable`](https://sdctools.github.io/sdcTable/index.html)
-   [`anonymizer`](http://paulhendricks.io/anonymizer/)
