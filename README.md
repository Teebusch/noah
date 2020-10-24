
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

`noah` (**no** **a**nimals were **h**armed) generates pseudonyms that
are delightful and easy to remember. Instead of cryptic alphanumeric
IDs, it creates anonymous animals like the *Likeable Leech* and the
*Proud Chickadee*.

## Installation

You can install `noah` from [Github](/https://github.com/teebusch/noah)
with:

``` r
# install.packages("remotes")
remotes::install_github("teebusch/noah")
```

## Usage

### Generating pseudonyms

The `pseudonymize()` function generates pseudonyms for every element in
a vector or every row in a data frame, whereby repeated elements receive
the same pseudonym. If you need 100 pseudonyms, call
`pseudonymize(1:100)`.

``` r
library(noah)

pseudonymize(rep(1:4, times = 2))
#> [1] "Sad Roadrunner"  "Belligerent Cat" "Pale Koala"      "Rich Leopard"   
#> [5] "Sad Roadrunner"  "Belligerent Cat" "Pale Koala"      "Rich Leopard"
```

`pseudonymize()` accepts any number of input vectors as arguments, as
long as they have the same length. It will treat elements in the same
position as being from the same subject.

``` r
pseudonymize(c("🐰", "🐰", "🐰"), c("🥕", "🥕", "🍰"))
#> [1] "Alike Clam"       "Alike Clam"       "Coherent Ladybug"
```

### Adding pseudonyms to data frames

Often we want to add a column with pseudonyms to a data frame, using one
or more columns as identifiers. In this example we use the diabetic
retinopathy dataset from the `survival` There are two was to do add
pseudonyms to a data frame with `noah`:

#### Using `mutate()` and `pseudonymize()`

We can add pseudonyms using `pseudonymize()` and `dplyr::mutate()`. Here
we add a new column with a pseudonym for each unique id:

``` r
library(dplyr)
diabetic <- as_tibble(survival::diabetic)

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

#### Using `add_pseudonyms()`

We can also use the `add_pseudonyms()` function, which wraps the mutate
and relocate step and supports `tidyselect` syntax for the selection of
the identifier columns:

``` r
diabetic %>% 
  add_pseudonyms(where(is.factor))
#> # A tibble: 394 x 9
#>    pseudonym           id laser   age eye     trt  risk  time status
#>    <chr>            <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Flaky Shrimp         5 argon    28 left      0     9  46.2      0
#>  2 Green Stingray       5 argon    28 right     1     9  46.2      0
#>  3 Spectacular Newt    14 xenon    12 left      1     8  42.5      0
#>  4 Moldy Lionfish      14 xenon    12 right     0     6  31.3      1
#>  5 Spectacular Newt    16 xenon     9 left      1    11  42.3      0
#>  6 Moldy Lionfish      16 xenon     9 right     0    11  42.3      0
#>  7 Spectacular Newt    25 xenon     9 left      0    11  20.6      0
#>  8 Moldy Lionfish      25 xenon     9 right     1    11  20.6      0
#>  9 Spectacular Newt    29 xenon    13 left      0    10   0.3      1
#> 10 Moldy Lionfish      29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

### Keeping track of pseudonyms

Internally, `pseudonymize()` and `add_pseudonyms()` use an object of
class `Ark` (a pseudonym archive) to keeps track of the pseudonyms that
have been used. By default, a new `Ark` is created for each call of the
`pseudonymize()` function, but we can provide an `Ark` to ensure that
the same input is always assigned the same pseudonym across multiple
function calls:

``` r
ark <- Ark$new()
```

    #> # An Ark: 0 / 430540 pseudonyms used (0%)
    #> The Ark is empty.

``` r
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
#>    pseudonym           id laser   age eye     trt  risk  time status
#>    <chr>            <int> <fct> <int> <fct> <int> <int> <dbl>  <int>
#>  1 Phobic Planarian     5 argon    28 left      0     9  46.2      0
#>  2 Phobic Planarian     5 argon    28 right     1     9  46.2      0
#>  3 Tasteless Tiglon    14 xenon    12 left      1     8  42.5      0
#>  4 Tasteless Tiglon    14 xenon    12 right     0     6  31.3      1
#>  5 Melted Butterfly    16 xenon     9 left      1    11  42.3      0
#>  6 Melted Butterfly    16 xenon     9 right     0    11  42.3      0
#>  7 Fumbling Locust     25 xenon     9 left      0    11  20.6      0
#>  8 Fumbling Locust     25 xenon     9 right     1    11  20.6      0
#>  9 Right Peacock       29 xenon    13 left      0    10   0.3      1
#> 10 Right Peacock       29 xenon    13 right     1     9  38.8      0
#> # ... with 384 more rows
```

If we have a look at the ark now, we can see that it contains 197
pseudonyms – just as many as there are unique id’s in the dataset.

    #> # An Ark: 197 / 430540 pseudonyms used (0%)
    #>    key         pseudonym
    #>    <md5>       <Attribute Animal>
    #>  1 00b7223a... False Axolotl
    #>  2 00da2109... Enchanted Monkey
    #>  3 0239d665... Imported Crow
    #>  4 03637783... Yummy Bedbug
    #>  5 03e58e4f... Drab Jacana
    #>  6 04d5d5e6... Uninterested Frog
    #>  7 04dbc7a5... Uppity Gibbon
    #>  8 05cb4662... Defective Lynx
    #>  9 07c3d75b... Descriptive Fox
    #> 10 07c5d050... Adamant Cat
    #> # ...with 187 more entries

## Related R packages

There are multiple R packages that generate fake data, including fake
names, phone numbers, addresses, credit card numbers, gene sequences and
more:

  - [`charlatan`](https://docs.ropensci.org/charlatan/)
  - [`randomNames`](https://centerforassessment.github.io/randomNames/)
  - [`randNames`](https://github.com/karthik/randNames)
  - [`generator`](https://github.com/paulhendricks/generator).

There are also packages for anonymizing personal identifiable
information in data sets. If you need reliable, watertight
anonymization, `noah` is likely not the right tool for you and you
should check out these packages instead:

  - [`sdcMicro`](http://sdctools.github.io/sdcMicro/index.html)
  - [`sdcTable`](https://sdctools.github.io/sdcTable/index.html)
  - [`anonymizer`](http://paulhendricks.io/anonymizer/)
