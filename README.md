# testthatBdd

Mocha-style BDD framework for testthat.

# Motivation

While testthat includes a basic `describe`/`it` framework, it does not
work very well with the provided reporters and does not support the
setup blocks (`before_each`).  This package tries to solve these
problems by adding setup blocks and providing a new `MochaReporter`
which prints results in the familiar mocha-like style.

# Installation

For now, the package is not uploaded to CRAN so you have to install it
manually or using `renv` or `devtools`:

``` R
devtools::install_github("ydistri/testthatBdd")

## or

renv::install("ydistri/testthatBdd")
```

# Usage

In general the usage is the same as [mochajs](https://mochajs.org/) so
feel free to refer to their documentation.  Here we recount briefly
the main features.

Create a test file as usual for `testthat`, but instead of using
`test_that`, use a combination of `describe` and `it` blocks:

``` R
library(testthat)
library(testthatBdd)

test_that("addition works", {
  expect_equal(1 + 1, 2)
  expect_equal(10 + 10, 20)
})

## becomes

describe("addition", {

  it("works with small numbers", {
    expect_equal(1 + 1, 2)
  })

  it("works with big numbers", {
    expect_equal(10 + 10, 2)
  })

})
```

The describe blocks can be nested to further specify the parts of the
program.

You can write a common setup block for each `it` expectation using a
`before_each`.  They can be written inside a `describe` section on any
level and run in order from the most general to the most specific
before the `it` code is executed.

``` R
library(testthat)
library(testthatBdd)

describe("addition", {

  before_each({
    a <- 1
  })

  describe("with small numbers", {

    it("works", {
      expect_equal(a + a, 2)
    })

  })

  describe("with big numbers", {

    before_each({
      ## make the number bigger!
      a <- a * 10
    })

    it("works", {
      expect_equal(a + a, 20)
    })

  })

})
```

To use the mocha-style reporter, set the reporter to `MochaReporter`:

``` shell
$ Rscript -e 'devtools::test(reporter = MochaReporter$new())'

  addition
    with small numbers
      ✓ works
    with big numbers
      ✓ works

2 tests, 0 failures, 0 skipped, 0.1 seconds
```

The reporter might or might not work nicely with the standard
`test_that` style tests, so use at your own risk.

# Limitations

Currently, only the `before_each` setup section is implemented.
`before`, `after` and `after_each` are not implemented.
