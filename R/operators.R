#' @name operators
#'
#' @title arithmetic, logical and relational operators for greta arrays
#'
#' @description This is a list of currently implemented arithmetic, logical and
#'   relational operators to combine greta arrays into probabilistic models.
#'   Also see \link{functions} and \link{transforms}.
#'
#' @section Usage: \preformatted{
#'  # arithmetic operators
#'  -x
#'  x + y
#'  x - y
#'  x * y
#'  x / y
#'  x ^ y
#'  x \%\% y
#'  x \%/\% y
#'  x \%*\% y
#'
#'  # logical operators
#'  !x
#'  x & y
#'  x | y
#'
#'  # relational operators
#'  x < y
#'  x > y
#'  x <= y
#'  x >= y
#'  x == y
#'  x != y
#'  }
#'
#' @details greta's operators are used just like R's the standard arithmetic,
#'   logical and relational operators, but they return other greta arrays. Since
#'   the operations are only carried during sampling, the greta array objects
#'   have unknown values.
#'
#' @examples
#' \dontrun{
#'
#' x <- as_data(-1:12)
#'
#' # arithmetic
#' a <- x + 1
#' b <- 2 * x + 3
#' c <- x %% 2
#' d <- x %/% 5
#'
#' # logical
#' e <- (x > 1) | (x < 1)
#' f <- e & (x < 2)
#' g <- !f
#'
#' # relational
#' h <- x < 1
#' i <- (-x) >= x
#' j <- h == x
#' }
NULL

# use S3 dispatch to apply the operators
#' @export
`+.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("add", e1, e2,
     tf_operation = "tf$add")
}

#' @export
`-.greta_array` <- function(e1, e2) {
  # handle unary minus
  if (missing(e2)) {
    op("minus", e1,
       tf_operation = "tf$negative")
  } else {
    check_dims(e1, e2)
    op("subtract", e1, e2,
       tf_operation = "tf$subtract")
  }
}

#' @export
`*.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("multiply", e1, e2,
     tf_operation = "tf$multiply")
}

#' @export
`/.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("divide", e1, e2,
     tf_operation = "tf$truediv")
}

#' @export
`^.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("power", e1, e2,
     tf_operation = "tf$pow")
}

#' @export
`%%.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("`modulo`", e1, e2,
     tf_operation = "tf$mod")
}

#' @export
`%/%.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("`integer divide`", e1, e2,
     tf_operation = "tf$floordiv")
}

# overload %*% as an S3 generic
# would rather get S4 version working properly, but uuurgh S4.

#' @export
`%*%.default` <- function(x, y)
  .Primitive("%*%")(x, y)

#' @rdname overloaded
#' @export
`%*%` <- function(x, y) {

  # if y is a greta array, coerce x before dispatch
  if (inherits(y, "greta_array") & !inherits(x, "greta_array"))
    as_data(x) %*% y
  else
    UseMethod ("%*%", x)

}

#' @export
`%*%.greta_array` <- function(x, y) {

  # check they're matrices
  if (length(dim(x)) != 2 | length(dim(y)) != 2) {
    stop("only two-dimensional greta arrays can be matrix-multiplied",
         call. = FALSE)
  }

  # check the dimensions match
  if (dim(x)[2] != dim(y)[1]) {
    msg <- sprintf("incompatible dimensions: %s vs %s",
                   paste0(dim(x), collapse = "x"),
                   paste0(dim(y), collapse = "x"))
    stop(msg)
  }

  op("matrix multiply", x, y,
     dim = c(nrow(x), ncol(y)),
     tf_operation = "tf$matmul")

}

# logical operators
#' @export
`!.greta_array` <- function(e1) {
  op("not", e1,
     tf_operation = "tf_not")
}

#' @export
`&.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("and", e1, e2,
     tf_operation = "tf_and")
}

#' @export
`|.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("or", e1, e2,
     tf_operation = "tf_or")
}

# relational operators

#' @export
`<.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("less", e1, e2,
     tf_operation = "tf_lt")
}

#' @export
`>.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("greater", e1, e2,
     tf_operation = "tf_gt")
}

#' @export
`<=.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("less/equal", e1, e2,
     tf_operation = "tf_lte")
}

#' @export
`>=.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("greater/equal", e1, e2,
     tf_operation = "tf_gte")
}

#' @export
`==.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("equal", e1, e2,
     tf_operation = "tf_eq")
}

#' @export
`!=.greta_array` <- function(e1, e2) {
  check_dims(e1, e2)
  op("not equal", e1, e2,
     tf_operation = "tf_neq")
}
