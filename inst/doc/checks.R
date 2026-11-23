## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(getaca)

.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-checks"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

reg <- registry("yourpkg", list(
  resource("backbone", "2026-06",
           urls = "https://host.invalid/backbone-2026-06.zip",
           sha256 = strrep("9f", 32), license = "CC-BY-4.0")
))

## ----eval = FALSE-------------------------------------------------------------
# install.packages("pak")
# pak::pak("gcol33/getaca")

## -----------------------------------------------------------------------------
getaca_policy()

## ----eval = FALSE-------------------------------------------------------------
# test_that("the backbone parses", {
#   getaca_skip_if_unavailable("backbone", package = "yourpkg")
# 
#   path <- getaca("backbone", package = "yourpkg")
#   expect_s3_class(read_backbone(path), "backbone")
# })

## ----eval = FALSE-------------------------------------------------------------
# #' @examples
# #' path <- getaca_optional("backbone", package = "yourpkg")
# #' if (!is.null(path)) {
# #'   summarise_backbone(path)
# #' }

## -----------------------------------------------------------------------------
path <- getaca_optional("backbone", registry = reg)
is.null(path)

## ----eval = FALSE-------------------------------------------------------------
# #' @examples
# #' \donttest{
# #' path <- getaca_optional("backbone", package = "yourpkg")
# #' if (!is.null(path)) summarise_backbone(path)
# #' }

## ----eval = FALSE-------------------------------------------------------------
# # data-raw/make-fixture.R
# full  <- read_backbone(getaca::getaca("backbone", package = "yourpkg"))
# small <- head(full[full$group %in% c("a", "b"), ], 200)
# saveRDS(small, "inst/extdata/backbone-extract.rds", version = 3)

## ----eval = FALSE-------------------------------------------------------------
# # in the vignette
# backbone <- readRDS(system.file("extdata", "backbone-extract.rds",
#                                 package = "yourpkg"))

## ----eval = getaca::getaca_available("backbone", package = "yourpkg")---------
# summarise_backbone(getaca::getaca("backbone", package = "yourpkg"))

## -----------------------------------------------------------------------------
getaca_available("backbone", registry = reg)

## -----------------------------------------------------------------------------
getaca_available("nothing-here", package = "getaca")

## ----eval = FALSE-------------------------------------------------------------
# getaca_prefetch("backbone", package = "yourpkg")   # one resource
# getaca_prefetch(package = "yourpkg")               # everything yourpkg declares
# getaca_prefetch(c("backbone", "grid"), package = "yourpkg")

## ----eval = FALSE-------------------------------------------------------------
# Sys.setenv(GETACA_CACHE = "/mnt/shared/getaca")

## ----eval = FALSE-------------------------------------------------------------
# test_that("the backbone test skips cleanly on a bare machine", {
#   withr::local_envvar(c(GETACA_OFFLINE = "true"))
#   withr::local_options(list(getaca.cache = withr::local_tempdir()))
# 
#   expect_false(getaca_available("backbone", package = "yourpkg"))
# })

## ----eval = FALSE-------------------------------------------------------------
# test_that("the shipped registry resolves the version we think it does", {
#   reg <- registry_for("yourpkg")
#   expect_equal(format(resolve_resource("backbone", registry = reg)),
#                "yourpkg/backbone@2026-06")
# })

## ----eval = FALSE-------------------------------------------------------------
# withr::with_envvar(
#   c(GETACA_CACHE = tempfile(), NOT_CRAN = ""),
#   devtools::check()
# )

## ----eval = FALSE-------------------------------------------------------------
# withr::with_envvar(
#   c(GETACA_CACHE = "~/getaca-cache", NOT_CRAN = "true"),
#   devtools::check()
# )

## -----------------------------------------------------------------------------
err <- tryCatch(getaca("backbone", registry = reg), getaca_error = function(e) e)
cat(conditionMessage(err))

## -----------------------------------------------------------------------------
class(err)

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

