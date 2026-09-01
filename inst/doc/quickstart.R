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

# Everything below runs against a throwaway cache with the network switched
# off, so this vignette builds identically on a machine that has never seen
# these resources and on one that has them all.
.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-quickstart"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

## -----------------------------------------------------------------------------
backbone <- resource(
  name    = "backbone",
  version = "2026-06",
  urls    = c("https://primary.invalid/backbone-2026-06.zip",
              "https://mirror.invalid/backbone-2026-06.zip"),
  sha256  = strrep("9f", 32),
  size    = 4.1e9,
  license = "CC-BY-4.0"
)

backbone

## -----------------------------------------------------------------------------
reg <- registry(package = "yourpkg", resources = list(backbone))
reg

## -----------------------------------------------------------------------------
format(resource_id("yourpkg", "backbone", "2026-06"))

## ----eval = FALSE-------------------------------------------------------------
# registry_write(reg, "inst/getaca/registry.rds")

## ----eval = FALSE-------------------------------------------------------------
# path <- getaca("backbone", package = "yourpkg")

## -----------------------------------------------------------------------------
multi <- registry(
  package = "yourpkg",
  current = c(backbone = "2026-09"),
  resources = list(
    resource("backbone", "2026-06",
             urls = "https://primary.invalid/backbone-2026-06.zip",
             sha256 = strrep("9f", 32), license = "CC-BY-4.0"),
    resource("backbone", "2026-09",
             urls = "https://primary.invalid/backbone-2026-09.zip",
             sha256 = strrep("ab", 32), license = "CC-BY-4.0")
  )
)

resolve_resource("backbone", registry = multi)$id

## -----------------------------------------------------------------------------
resolve_resource("backbone", registry = multi, version = "2026-06")$id

## ----error = TRUE-------------------------------------------------------------
try({
registry(
  package = "yourpkg",
  resources = list(
    resource("backbone", "2026-09",
             urls = "https://primary.invalid/a",
             sha256 = strrep("ab", 32)),
    resource("backbone", "2026-03",
             urls = "https://primary.invalid/b",
             sha256 = strrep("cd", 32))
  )
)
})

## ----eval = FALSE-------------------------------------------------------------
# test_that("the backbone parses", {
#   getaca_skip_if_unavailable("backbone", package = "yourpkg")
#   expect_s3_class(read_backbone(getaca("backbone", package = "yourpkg")), "backbone")
# })

## -----------------------------------------------------------------------------
path <- getaca_optional("backbone", registry = reg)
is.null(path)

## -----------------------------------------------------------------------------
getaca_available("backbone", registry = reg)

## ----eval = FALSE-------------------------------------------------------------
# getaca_prefetch("backbone", package = "yourpkg")
# getaca_prefetch(package = "yourpkg")   # everything the package declares

## -----------------------------------------------------------------------------
err <- tryCatch(getaca("backbone", registry = reg), getaca_error = function(e) e)
class(err)

## -----------------------------------------------------------------------------
cat(conditionMessage(err))

## -----------------------------------------------------------------------------
err$actor

## ----eval = FALSE-------------------------------------------------------------
# install_backbone <- function(name = "backbone") {
#   path <- tryCatch(
#     getaca(name, package = "yourpkg"),
#     getaca_error_unavailable = function(e) {
#       stop("The backbone is not installed and no network is available.\n",
#            "Connect, then run: yourpkg::install_backbone(\"backbone\")", call. = FALSE)
#     }
#   )
#   open_backbone(path)
# }

## ----eval = FALSE-------------------------------------------------------------
# getaca_info("backbone", package = "yourpkg")
# #> <getaca cache entry> yourpkg/backbone@2026-06
# #>   path        ~/.cache/R/getaca/yourpkg/backbone/2026-06/raw/backbone-2026-06.zip
# #>   sha256      9f9f9f...
# #>   size        4,100,000,000 bytes
# #>   license     CC-BY-4.0
# #>   resolved by bundled registry sha256:1c4d7a90f2be (published 2026-07-20)
# #>   source url  https://primary.invalid/backbone-2026-06.zip
# #>   getaca      0.0.0.9000
# #>   fetched     2026-07-26 11:02:13
# #>   verified    2026-07-26 11:09:44 (full re-hash)
# #>   checked     2026-07-26 15:31:02 (size and mtime)

## -----------------------------------------------------------------------------
is.null(getaca_info("backbone", registry = reg))

## -----------------------------------------------------------------------------
getaca_catalogue(registry = multi)[, c("name", "version", "current",
                                       "declared", "cached")]

## -----------------------------------------------------------------------------
getaca_cache_dir()

## -----------------------------------------------------------------------------
getaca_clean(dry_run = TRUE)

## -----------------------------------------------------------------------------
getaca_policy()

## ----eval = FALSE-------------------------------------------------------------
# getaca_policy("current")                                     # for this session
# getaca("backbone", package = "yourpkg", policy = "bundled")  # for this call

## ----eval = FALSE-------------------------------------------------------------
# getaca_pin(c("yourpkg", "otherpkg"))   # writes getaca.pins.rds in the project

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

