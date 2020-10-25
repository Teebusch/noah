
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

<!-- badges: end -->

noah (*no animals were harmed*) generates pseudonyms that are delightful
and easy to remember. Instead of cryptic alphanumeric IDs, it creates
adorable anonymous animals like the *Likeable Leech* and the *Proud
Chickadee*.

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
element / row in a vectors or data frame. `pseudonymize()` accepts any
number of vectors and data frames as arguments, and will pseudonomize
elements row by row.

``` r
library(noah)

pseudonymize(1:10)
#>  [1] "Sad Roadrunner"      "Belligerent Cat"     "Pale Koala"         
#>  [4] "Rich Leopard"        "Efficient Pony"      "Typical Condor"     
#>  [7] "Swanky Heron"        "Goofy Peacock"       "Opposite Roadrunner"
#> [10] "Full Junglefowl"

pseudonymize(rep(c("🐄", "🦎", "🐅"), times = 2))
#> [1] "Alike Clam"          "Coherent Ladybug"    "Disastrous Dinosaur"
#> [4] "Alike Clam"          "Coherent Ladybug"    "Disastrous Dinosaur"

pseudonymize(c("🐰", "🐰", "🐰"), c("🥕", "🥕", "🍰"))
#> [1] "Eight Swordfish" "Eight Swordfish" "Standing Serval"
```

### Adding pseudonyms to data frames

There are two ways to do add pseudonyms to a data frame with noah: In
this example we use the diabetic retinopathy dataset from the
`{survival}` package.

#### Using `mutate()` and `pseudonymize()`

Here we use `pseudonymize()` and `dplyr::mutate()` to a new column with
a pseudonym for each unique id:

``` r
library(dplyr)
diabetic <- as_tibble(survival::diabetic)

diabetic %>% 
  mutate(pseudonym = pseudonymize(id)) %>% 
  relocate(pseudonym)
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

#### Using `add_pseudonyms()`

`add_pseudonyms()` wraps mutate relocate. It also supports `tidyselect`
syntax for the selection of the key columns:

``` r
diabetic %>% 
  add_pseudonyms(where(is.factor))
#> # A tibble: 394 x 9
#>    pseudonym           id laser   age eye     trt  risk  time status
#>    <chr>            <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Phobic Planarian     5 argon    28 left      0     9  46.2      0
#>  2 Tasteless Tiglon     5 argon    28 right     1     9  46.2      0
#>  3 Melted Butterfly    14 xenon    12 left      1     8  42.5      0
#>  4 Fumbling Locust     14 xenon    12 right     0     6  31.3      1
#>  5 Melted Butterfly    16 xenon     9 left      1    11  42.3      0
#>  6 Fumbling Locust     16 xenon     9 right     0    11  42.3      0
#>  7 Melted Butterfly    25 xenon     9 left      0    11  20.6      0
#>  8 Fumbling Locust     25 xenon     9 right     1    11  20.6      0
#>  9 Melted Butterfly    29 xenon    13 left      0    10   0.3      1
#> 10 Fumbling Locust     29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

### Keeping track of pseudonyms

Internally, `pseudonymize()` and `add_pseudonyms()` use an object of
class `Ark` (a pseudonym archive) to keeps track of the pseudonyms that
have been used. We can provide an `Ark` to keep track of pseudonyms
across multiple function calls:

``` r
ark <- Ark$new()
ark
#> # An Ark: 0 / 430540 pseudonyms used (0%)
#> The Ark is empty.

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
#>    pseudonym            id laser   age eye     trt  risk  time status
#>    <chr>             <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Unwieldy Gull         5 argon    28 left      0     9  46.2      0
#>  2 Unwieldy Gull         5 argon    28 right     1     9  46.2      0
#>  3 Knotty Cardinal      14 xenon    12 left      1     8  42.5      0
#>  4 Knotty Cardinal      14 xenon    12 right     0     6  31.3      1
#>  5 Fallacious Parrot    16 xenon     9 left      1    11  42.3      0
#>  6 Fallacious Parrot    16 xenon     9 right     0    11  42.3      0
#>  7 Chunky Olingo        25 xenon     9 left      0    11  20.6      0
#>  8 Chunky Olingo        25 xenon     9 right     1    11  20.6      0
#>  9 Moaning Herring      29 xenon    13 left      0    10   0.3      1
#> 10 Moaning Herring      29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

The ark now contains 197 pseudonyms – as many as there are unique id’s
in the dataset.

``` r
ark
#> # An Ark: 197 / 430540 pseudonyms used (0%)
#>    key         pseudonym
#>    <md5>       <Attribute Animal>
#>  1 00b7223a... Luxuriant Raven
#>  2 00da2109... Glossy Ant
#>  3 0239d665... Rustic Skunk
#>  4 03637783... Wide-Eyed Pigeon
#>  5 03e58e4f... Ambiguous Meerkat
#>  6 04d5d5e6... Crooked Gull
#>  7 04dbc7a5... Aloof Dragon
#>  8 05cb4662... Godly Viper
#>  9 07c3d75b... Abstracted Lynx
#> 10 07c5d050... Anxious Dodo
#> # ...with 187 more entries
```

### Making an Alliterating Ark

We can also configure an Ark to generate only alliterations:

``` r
ark <- Ark$new(alliterate = TRUE)
pseudonymize(1:12, .ark = ark)
#>  [1] "Real Roadrunner"         "Condemned Centipede"    
#>  [3] "Smart Salamander"        "Ludicrous Lamprey"      
#>  [5] "Ripe Rabbit"             "Feeble Fowl"            
#>  [7] "Condemned Crawdad"       "Harmonious Hippopotamus"
#>  [9] "Smiling Squirrel"        "Sulky Swan"             
#> [11] "Absorbing Anglerfish"    "General Guan"
```

## Related R packages

There are multiple R packages that generate fake data, including fake
names, phone numbers, addresses, credit card numbers, gene sequences and
more:

  - [`charlatan`](https://docs.ropensci.org/charlatan/)
  - [`randomNames`](https://centerforassessment.github.io/randomNames/)
  - [`randNames`](https://github.com/karthik/randNames)
  - [`generator`](https://github.com/paulhendricks/generator)

There are also packages for anonymizing personal identifiable
information in data sets. If you need watertight anonymization, noah is
likely not the right tool for the job and you should check out these
packages instead:

  - [`sdcMicro`](http://sdctools.github.io/sdcMicro/index.html)
  - [`sdcTable`](https://sdctools.github.io/sdcTable/index.html)
  - [`anonymizer`](http://paulhendricks.io/anonymizer/)
