## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(getaca)

# The session temp directory carries the account name of whoever knits, so
# printing a cache path would put it in the built article. Redact it.
local({
  roots <- unique(c(tempdir(),
                    normalizePath(tempdir(), winslash = "\\", mustWork = FALSE),
                    normalizePath(tempdir(), winslash = "/", mustWork = FALSE)))
  roots <- unique(c(gsub("\\", "\\\\", roots, fixed = TRUE), roots))
  roots <- roots[order(nchar(roots), decreasing = TRUE)]
  render <- knitr::knit_hooks$get("output")
  knitr::knit_hooks$set(output = function(x, options) {
    for (root in roots) x <- gsub(root, "<tempdir>", x, fixed = TRUE)
    render(x, options)
  })
})

.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-cache-vignette"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

reg <- registry("yourpkg", list(
  resource("backbone", "2026-06",
           urls = "https://host.invalid/backbone-2026-06.zip",
           sha256 = strrep("9f", 32), size = 797e6, license = "CC-BY-4.0")
))

## ----eval = FALSE-------------------------------------------------------------
# install.packages("pak")
# pak::pak("gcol33/getaca")

## -----------------------------------------------------------------------------
getaca_cache_dir()

## ----eval = FALSE-------------------------------------------------------------
# options(getaca.cache = "/mnt/fast/getaca")   # this session
# Sys.setenv(GETACA_CACHE = "/mnt/fast/getaca") # this process and its children

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")                 # cheap check
# getaca("backbone", package = "yourpkg", verify = TRUE)  # full re-hash first
# options(getaca.verify_days = 30)                  # re-hash more often

## ----eval = FALSE-------------------------------------------------------------
# getaca_info("backbone", package = "yourpkg")
# #> <getaca cache entry> yourpkg/backbone@2026-06
# #>   path        ~/.cache/R/getaca/yourpkg/backbone/2026-06/raw/backbone-2026-06.zip
# #>   sha256      9f9f9f...
# #>   size        797,000,000 bytes
# #>   license     CC-BY-4.0
# #>   built from  source_release: 2026-06
# #>   resolved by current registry sha256:8b31e0da54cf (published 2026-07-22)
# #>   source url  https://host.invalid/backbone-2026-06.zip
# #>   getaca      0.0.0.9000
# #>   fetched     2026-07-26 11:02:13
# #>   verified    2026-07-26 11:09:44 (full re-hash)
# #>   checked     2026-07-26 15:31:02 (size and mtime)

## ----eval = FALSE-------------------------------------------------------------
# #>   source url  NA
# #>   composed    3 parts via 'concat'
# #>     part      919191919191
# #>     part      4e4e4e4e4e4e
# #>     part      777777777777

## -----------------------------------------------------------------------------
is.null(getaca_info("backbone", registry = reg))

## -----------------------------------------------------------------------------
getaca_catalogue(registry = reg)[, c("package", "name", "version",
                                     "current", "declared", "cached")]

## -----------------------------------------------------------------------------
str(getaca_catalogue(), max.level = 1)

## ----eval = FALSE-------------------------------------------------------------
# options(getaca.lock_wait_seconds = 600)

## ----eval = FALSE-------------------------------------------------------------
# getaca_progress("bar")    # redraws one line, the default when interactive
# getaca_progress("line")   # one line to start and one to finish, for a log
# getaca_progress("none")   # nothing

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg", quiet = TRUE)

## -----------------------------------------------------------------------------
counter <- reporter("counter", function(event) {
  if (identical(event$type, "end") && identical(event$status, "ok")) {
    message(format(event$id), ": ", event$bytes, " bytes")
  }
})
counter

## -----------------------------------------------------------------------------
getaca_clean(dry_run = TRUE)

## ----eval = FALSE-------------------------------------------------------------
# getaca_clean(dry_run = TRUE)
# #>   package                 resource                     reason    bytes
# #> 1 yourpkg yourpkg/backbone@2026-03 superseded version past... 7.97e+08
# #> 2    <NA>                     <NA>         abandoned transfer 1.20e+07
# 
# getaca_clean()                                 # run every sweep
# getaca_clean(what = "temp")                    # just the abandoned transfers
# getaca_clean(package = "yourpkg")              # one package
# getaca_clean("backbone", package = "yourpkg")  # one resource name
# 
# # Everything cached for one resource, or for one version of it, healthy or not:
# getaca_clean("backbone", package = "yourpkg", what = "cached")
# getaca_clean("backbone", package = "yourpkg", version = "2026-03", what = "cached")

## ----eval = FALSE-------------------------------------------------------------
# getaca_keep("backbone", package = "yourpkg")                  # pin it
# getaca_keep("backbone", package = "yourpkg", pinned = FALSE)  # release the pin

## ----eval = FALSE-------------------------------------------------------------
# options(
#   getaca.cache        = "/mnt/data/getaca",
#   getaca.max_bytes    = 200 * 1024^3,
#   getaca.verify_days  = 30
# )

## ----eval = FALSE-------------------------------------------------------------
# # on a connected machine
# Sys.setenv(GETACA_CACHE = "/tmp/seed")
# getaca_prefetch(package = "yourpkg")
# 
# # then, on the machine that has no network
# Sys.setenv(GETACA_CACHE = "/opt/getaca")
# getaca_catalogue()   # everything already there

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

