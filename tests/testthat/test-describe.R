describe("before_each", {

    before_each({
        x <- 1
    })

    it("should run in the it clause on the same level", {
        expect_equal(x, 1)
    })

    describe("with nested describe", {

        it("should use the before_each from higher level", {
            expect_equal(x, 1)
        })

    })

    describe("with nested describe", {

        before_each({
            x <- x + 1
            y <- 1
        })

        it("should run before_each code blocks in order of nesting", {
            expect_equal(x, 2)
            expect_equal(y, 1)
        })

    })

})

describe("it", {

    it("should not leak state from one evaluateion to another", {
        a <- 1
        expect_true(T)
    })

    it("should not leak state from one evaluateion to another", {
        expect_error(a, "object 'a' not found")
    })

})

.test_function_from_top_env <- function() { "hello" }
.variable_from_top_env <- "world"

describe("environment", {

    it("should see variables from outside the describe environment", {
        expect_equal(.test_function_from_top_env(), "hello")
        expect_equal(.variable_from_top_env, "world")
    })

    it("should not be able to change variables from outside the describe environment", {
        .variable_from_top_env <- "Prague" # this is set in its own environment
        expect_true(T) # to not count as skipped test
    })

    it("should not be able to change variables from outside the describe environment", {
        expect_equal(.variable_from_top_env, "world") # not Prague
    })

    .should_be_visible <- function() { "visible" }

    it("should be able to use functions defined in the describe block", {
        expect_equal(.should_be_visible(), "visible")
    })

})
