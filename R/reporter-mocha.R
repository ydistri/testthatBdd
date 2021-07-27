#' @importFrom testthat Reporter
NULL

expectation_type <- function(exp) {
    stopifnot(is.expectation(exp))
    gsub("^expectation_", "", class(exp)[[1]])
}

testthat_style <- function(type = c("success", "skip", "warning", "failure", "error")) {
    type <- match.arg(type)

    c(
        success = "green",
        skip = "blue",
        warning = "magenta",
        failure = "red",
        error = "red"
    )[[type]]
}

#' Test reporter: mocha
#'
#' Present test results of a BDD test suite in a hierarchical way.
#'
#' @importFrom R6 R6Class
#' @export
MochaReporter <- R6::R6Class("MochaReporter",
    inherit = Reporter,
    public = list(

        number_of_tests = 0,
        number_of_failed = 0,
        number_of_skipped = 0,
        number_of_ok = 0,

        con = NULL,
        failure = F,
        skipped = F,
        test_badge = "",
        indent = 0,
        describes = c(),
        seconds = NULL,
        assertions_processed = 0,

        start_reporter = function() {
            self$seconds <- Sys.time()
        },

        start_test = function(context, test) {
            describes <- unlist(strsplit(test, ": *"))
            indent <- 2
            for (i in 1:(length(describes) - 1)) {
               if (!is.null(self$describes[i]) && describes[i] == self$describes[i]) {
                   indent <- indent + 2
               } else {
                   for (j in i:(length(describes) - 1)) {
                       self$cat_line(paste(rep(" ", indent), collapse = ""), describes[j])
                       indent <- indent + 2
                   }
                   break;
               }
            }
            self$describes <- describes
            self$indent <- indent

            self$failure <- F
            self$skipped <- F
            self$test_badge <- ""
            self$assertions_processed <- 1
            self$con <- textConnection(NULL, "w")
            sink(self$con)
        },

        add_result = function(context, test, result) {
            sink() # closes the capture from start_test
            self$number_of_tests <- self$number_of_tests + 1
            ref <- result$srcref
            if (is.null(ref)) {
                location <- "?#?:?"
            } else {
                location <- paste0(attr(ref, "srcfile")$filename, "#", ref[1], ":1")
            }

            status <- expectation_type(result)
            test_badge_style <- testthat_style(status)
            if (status == "failure" || status == "error" || status == "warning") {
                self$test_badge <- crayon::style("✖ ", test_badge_style)
                private$print_description()
                self$cat_line(
                         paste(rep(" ", self$indent), collapse = ""),
                         location,
                         "\n"
                     )
                self$cat_line(result)
                self$failure <- T
                self$number_of_failed <- self$number_of_failed + 1
            } else if (status == "skip") {
                self$test_badge <- crayon::style("? ", test_badge_style)
                private$print_description()
                self$skipped <- T
                self$number_of_skipped <- self$number_of_skipped + 1
            } else {
                self$test_badge <- crayon::style("✓ ", test_badge_style)
                private$print_description()
                self$number_of_ok <- self$number_of_ok + 1
            }
            self$assertions_processed <- self$assertions_processed + 1
            sink(self$con)
        },

        end_test = function(context, test) {
            sink() # closes the capture from add_result

            if (self$test_badge == "") {
                self$test_badge <- crayon::style("? ", testthat_style("skip"))
                self$number_of_skipped <- self$number_of_skipped + 1
                private$print_description()
            }

            if (self$failure) {
                self$cat_line(textConnectionValue(self$con))
            }

            close(self$con)
        },

        end_reporter = function() {
            duration <- difftime(Sys.time(), self$seconds, units = "sec")

            self$cat_line(
                     "\n",
                     self$number_of_ok + self$number_of_skipped + self$number_of_failed,
                     " tests, ",
                     crayon::style(self$number_of_failed, if (self$number_of_failed > 0) "red" else "green"),
                     " failures, ",
                     crayon::style(self$number_of_skipped, "blue"),
                     " skipped, ",
                     round(duration, 2), " seconds",
                     "\n"
                 )
        }
    ),
    private = list(
        print_description = function() {
            assertion_number <- if (self$assertions_processed > 1) {
                sprintf(" (%d)", self$assertions_processed)
            } else {
                ""
            }

            self$cat_line(
                     paste(rep(" ", self$indent), collapse = ""),
                     self$test_badge,
                     tail(self$describes, n = 1),
                     assertion_number
                 )
        }
    )
)
