## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(getaca)

.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-alternatives"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

## ----eval = FALSE-------------------------------------------------------------
# install.packages("pak")
# pak::pak("gcol33/getaca")

## ----eval = FALSE-------------------------------------------------------------
# library(targets)
# 
# list(
#   tar_target(backbone_path, getaca::getaca("backbone", package = "yourpkg"),
#              format = "file"),
#   tar_target(backbone, read_backbone(backbone_path)),
#   tar_target(summary, summarise_backbone(backbone))
# )

## ----eval = FALSE-------------------------------------------------------------
# renv::snapshot()
# getaca_pin(c("yourpkg", "otherpkg"))

## -----------------------------------------------------------------------------
packageDescription("getaca")$Imports

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

