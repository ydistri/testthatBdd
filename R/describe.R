get_parent_env_values <- function(name, envs) {
    rev(unlist(sapply(envs, function(e) {
        rlang::env_get(e, name, default = NULL)
    })))
}

#' @export
before_each <- function(code) {
    rlang::env_poke(rlang::caller_env(), ".before_each_quoted", substitute(code))
}

#' describe: a BDD testing language
#'
#' A simple BDD DSL for writing tests. The language is similiar to RSpec for
#' Ruby or Mocha for JavaScript. BDD tests read like sentences and it should
#' thus be easier to understand what the specification of a function/component
#' is.
#'
#' Tests using the `describe` syntax not only verify the tested code, but
#' also document its intended behaviour. Each `describe` block specifies a
#' larger component or function and contains a set of specifications. A
#' specification is definied by an `it` block. Each `it` block
#' functions as a test and is evaluated in its own environment. You
#' can also have nested `describe` blocks.
#'
#' This test syntax helps to test the intented behaviour of your code. For
#' example: you want to write a new function for your package. Try to describe
#' the specification first using `describe`, before your write any code.
#' After that, you start to implement the tests for each specification (i.e.
#' the `it` block).
#'
#' To quickly disable tests you can use `xdescribe` to skip an entire
#' group or `xit` to skip a specific test.
#'
#' @param description description of the feature
#' @param code test code containing the specs
#' @export
describe <- function(description, code) {
    describe_environment <- rlang::env(
                                       rlang::caller_env(),
                                       .description = description
                                   )
    parent_descriptions <- get_parent_env_values(".description", rlang::env_parents(describe_environment))
    all_before_each <- get_parent_env_values(".before_each_quoted", rlang::env_parents(describe_environment))

    describe_environment$it <- function(it_description, it_code) {
        current_before_each <- rlang::env_get(describe_environment, ".before_each_quoted", NULL)
        before_each <- c(all_before_each, current_before_each)
        sapply(before_each, function(block) { eval(block, describe_environment) })

        test_description <- paste0(c(parent_descriptions, description, it_description), collapse = ": ")
        testthat:::test_code(
                       test_description,
                       substitute(it_code),
                       env = describe_environment,
                       skip_on_empty = FALSE
                   )
    }

    describe_environment$xit <- function(it_description, it_code) {
        test_description <- paste0(c(parent_descriptions, description, it_description), collapse = ": ")
        testthat:::test_code(
                       test_description,
                       substitute(testthat::skip("Test skipped with xit")),
                       env = describe_environment,
                       skip_on_empty = FALSE
                   )
    }

    if (rlang::env_get(describe_environment, ".skip_all", FALSE, inherit = TRUE)) {
        describe_environment$it <- describe_environment$xit
    }

    eval(substitute(code), describe_environment)
    invisible()
}

#' @export
xdescribe <- function(description, code) {
    describe_environment <- rlang::env(rlang::caller_env(), .description = description, .skip_all = T)
    parent_descriptions <- get_parent_env_values(".description", rlang::env_parents(describe_environment))

    describe_environment$xit <- function(it_description, it_code) {
        test_description <- paste0(c(parent_descriptions, description, it_description), collapse = ": ")
        testthat:::test_code(
                       test_description,
                       substitute(testthat::skip("Test skipped with xit")),
                       env = describe_environment,
                       skip_on_empty = FALSE
                   )
    }
    describe_environment$it <- describe_environment$xit

    eval(substitute(code), describe_environment)
    invisible()
}
