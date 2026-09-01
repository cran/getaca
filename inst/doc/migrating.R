## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(getaca)

.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-migrating"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

## ----eval = FALSE-------------------------------------------------------------
# # R/download.R, before
# BACKBONE_URLS <- c(
#   backbone = "https://host.example/backbone.zip",
#   grid     = "https://host.example/grid.zip"
# )
# 
# backbone_dir <- function() {
#   d <- tools::R_user_dir("yourpkg", "cache")
#   dir.create(d, recursive = TRUE, showWarnings = FALSE)
#   d
# }
# 
# backbone_path <- function(name) {
#   file.path(backbone_dir(), paste0(name, ".zip"))
# }
# 
# install_backbone <- function(name = "backbone", force = FALSE) {
#   dest <- backbone_path(name)
#   if (file.exists(dest) && !force) return(invisible(dest))
# 
#   url <- BACKBONE_URLS[[name]]
#   if (is.null(url)) stop("Unknown dataset: ", name)
# 
#   tmp <- tempfile()
#   ok <- tryCatch({
#     utils::download.file(url, tmp, mode = "wb", quiet = TRUE)
#     TRUE
#   }, error = function(e) FALSE)
#   if (!ok) stop("Could not download ", name, ". Check your connection.")
# 
#   file.rename(tmp, dest)
#   invisible(dest)
# }
# 
# backbone_available <- function(name = "backbone") {
#   file.exists(backbone_path(name))
# }

## ----eval = FALSE-------------------------------------------------------------
# # data-raw/registry.R
# reg <- registry_draft(
#   c(backbone = "https://host.example/backbone-2026-06.zip",
#     grid     = "https://host.example/grid-2026-06.zip"),
#   package = "yourpkg",
#   version = "2026-06"
# )

## ----eval = FALSE-------------------------------------------------------------
# registry_draft("10.5281/zenodo.1234567", package = "yourpkg")

## ----eval = FALSE-------------------------------------------------------------
# registry_draft(c(backbone = "https://zenodo.org/records/1234567/files/backbone.zip"),
#                package = "yourpkg", version = "2026-06",
#                local   = c(backbone = "~/build/backbone-2026-06.zip"),
#                sha256  = c(backbone = "9f9f..."))

## -----------------------------------------------------------------------------
backbone <- resource(
  name    = "backbone",
  version = "2026-06",
  urls    = c("https://zenodo.invalid/records/1234567/files/backbone-2026-06.zip",
              "https://releases.invalid/backbone/2026.06/backbone.zip"),
  sha256  = strrep("9f", 32),
  size    = 797e6,
  license = "CC-BY-4.0",
  description = "Reference backbone, June 2026"
)
format(backbone)

## -----------------------------------------------------------------------------
format(resource(
  name    = "backbone",
  version = "source-2026-06_build-3",
  urls    = "https://host.invalid/backbone-db-3.zip",
  sha256  = strrep("ab", 32),
  license = "CC-BY-4.0",
  upstream = list(source_release = "2026-06", build = "3")
))

## -----------------------------------------------------------------------------
grid <- resource(
  name    = "grid",
  version = "2026-06",
  urls    = "https://zenodo.invalid/records/1234567/files/grid-2026-06.zip",
  sha256  = strrep("ab", 32),
  size    = 41e6,
  license = "CC-BY-4.0",
  description = "Reference grid, June 2026"
)

reg <- registry(package = "yourpkg", resources = list(backbone, grid))
reg

## ----eval = FALSE-------------------------------------------------------------
# # data-raw/registry.R
# source("data-raw/records.R")   # returns a list of resource()s
# registry_write(
#   registry(package = "yourpkg", resources = records),
#   "inst/getaca/registry.rds"
# )

## ----eval = FALSE-------------------------------------------------------------
# # R/download.R, after
# install_backbone <- function(name = "backbone", force = FALSE) {
#   invisible(getaca::getaca(name, package = "yourpkg", verify = force))
# }
# 
# backbone_path <- function(name = "backbone") {
#   getaca::getaca(name, package = "yourpkg")
# }
# 
# backbone_available <- function(name = "backbone") {
#   getaca::getaca_available(name, package = "yourpkg")
# }

## ----eval = FALSE-------------------------------------------------------------
# # before
# test_that("the backbone parses", {
#   skip_if(!backbone_available("backbone"), "backbone not installed")
#   expect_s3_class(read_backbone(backbone_path("backbone")), "backbone")
# })
# 
# # after
# test_that("the backbone parses", {
#   getaca_skip_if_unavailable("backbone", package = "yourpkg")
#   expect_s3_class(read_backbone(getaca("backbone", package = "yourpkg")),
#                   "backbone")
# })

## ----eval = FALSE-------------------------------------------------------------
# #' @examples
# #' path <- getaca_optional("backbone", package = "yourpkg")
# #' if (!is.null(path)) summarise_backbone(path)

## ----eval = FALSE-------------------------------------------------------------
# getaca_info("backbone", package = "yourpkg")
# #> <getaca cache entry> yourpkg/backbone@2026-06
# #>   ...
# #>   built from  source_release: 2026-06
# #>   resolved by bundled registry sha256:1c4d7a90f2be (published 2026-07-20)
# #>   source url  https://zenodo.invalid/records/1234567/files/backbone-2026-06.zip
# #>   fetched     2026-07-26 11:02:13
# #>   verified    2026-07-26 11:09:44 (full re-hash)

## -----------------------------------------------------------------------------
getaca_catalogue(registry = reg)[, c("name", "version", "declared", "cached")]

## ----eval = FALSE-------------------------------------------------------------
# analyse <- function(x) {
#   info <- getaca::getaca_info("backbone", package = "yourpkg")
#   out  <- do_the_work(x, getaca::getaca("backbone", package = "yourpkg"))
#   attr(out, "backbone_version") <- info$id$version
#   attr(out, "backbone_sha256")  <- info$observed_sha256
#   out
# }

## ----eval = FALSE-------------------------------------------------------------
# .legacy_checked <- new.env(parent = emptyenv())
# 
# retire_legacy_cache <- function() {
#   if (isTRUE(.legacy_checked$done)) return(invisible(NULL))
#   .legacy_checked$done <- TRUE
# 
#   old <- tools::R_user_dir("yourpkg", "cache")
#   files <- list.files(old, pattern = "[.]zip$", full.names = TRUE)
#   if (!length(files)) return(invisible(NULL))
# 
#   message("yourpkg now stores its data through getaca, with a recorded ",
#           "version and checksum.\n",
#           "The previous downloads at ", old, " are no longer used.\n",
#           "Remove them with: unlink(\"", old, "\", recursive = TRUE)")
#   invisible(NULL)
# }

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

