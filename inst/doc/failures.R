## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(getaca)

.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-failures"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

reg <- registry("yourpkg", list(
  resource("backbone", "2026-06",
           urls = c("https://primary.invalid/backbone-2026-06.zip",
                    "https://mirror.invalid/backbone-2026-06.zip"),
           sha256 = strrep("9f", 32), size = 797e6, license = "CC-BY-4.0")
))

## -----------------------------------------------------------------------------
err <- tryCatch(getaca("backbone", registry = reg), getaca_error = function(e) e)
class(err)

## -----------------------------------------------------------------------------
err$actor

## -----------------------------------------------------------------------------
cat(conditionMessage(err))

## -----------------------------------------------------------------------------
names(err)

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: Cannot reach any source for yourpkg/backbone@2026-06.
# #>   https://primary.invalid/backbone-2026-06.zip: HTTP 503
# #>   https://mirror.invalid/backbone-2026-06.zip: Could not resolve host
# #>
# #> Actions: connect to a network; or run getaca_prefetch() on a connected
# #> machine and copy the cache directory; or set the resource optional here
# #> with getaca_available() before calling.
# #>
# #> Fix: see the actions listed above.

## ----eval = FALSE-------------------------------------------------------------
# tryCatch(
#   getaca("backbone", package = "yourpkg"),
#   getaca_error_unavailable = function(e) {
#     stop(sprintf(
#       "Could not download the backbone from %d source(s).\nTried:\n%s",
#       length(e$urls), paste0("  ", e$urls, " (", e$reasons, ")", collapse = "\n")
#     ), call. = FALSE)
#   }
# )

## -----------------------------------------------------------------------------
cat(conditionMessage(err))

## -----------------------------------------------------------------------------
inherits(err, "getaca_error_unavailable")

## ----eval = FALSE-------------------------------------------------------------
# tryCatch(
#   getaca("backbone", package = "yourpkg"),
#   getaca_error_offline = function(e) {
#     message("Running without network access. Prefetch first:\n",
#             "  getaca_prefetch(\"backbone\", package = \"yourpkg\")")
#     NULL
#   },
#   getaca_error_unavailable = function(e) {
#     message("The download sources are not responding. Try again later.")
#     NULL
#   }
# )

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: Transfer of yourpkg/backbone@2026-06 ended early.
# #>   expected 797000000 bytes, received 412300000 bytes
# #>
# #> Action: retry. Any previously cached copy was left untouched.
# #>
# #> Fix: see the actions listed above.

## ----eval = FALSE-------------------------------------------------------------
# getaca("gedi-l4a", package = "canopy")
# #> Error: Access to canopy/gedi-l4a@2026-06 was refused.
# #>   data.ornldaac.earthdata.nasa.gov: bearer credential from EARTHDATA_TOKEN (not set: EARTHDATA_TOKEN)
# #>     obtain one at https://urs.earthdata.nasa.gov/users/new
# #>
# #> Actions: set the variables named above and retry; or, if a credential is
# #> already set, check that it is current and carries access to this resource.
# #>
# #> Fix: see the actions listed above.

## ----eval = FALSE-------------------------------------------------------------
# getaca_credentials(package = "canopy")
# #>   package                             host scheme        variable   set
# #> 1  canopy data.ornldaac.earthdata.nasa.gov bearer EARTHDATA_TOKEN FALSE
# #>                                   register
# #> 1 https://urs.earthdata.nasa.gov/users/new

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: The remote file no longer matches yourpkg/backbone@2026-06.
# #>   declared SHA-256: 9f9f9f...
# #>   observed SHA-256: 3c1a77...
# #>   source: https://primary.invalid/backbone-2026-06.zip
# #>
# #> The publisher appears to have replaced the contents without issuing a
# #> new version. getaca will not accept the substitution, and any copy
# #> already verified in the cache has been left untouched.
# #>
# #> Fix: the publisher changed the file. The declaring package needs a new
# #> registry entry.

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: The declared checksum for yourpkg/backbone@2026-06 looks wrong.
# #>   2 independent sources agreed on SHA-256 3c1a77...
# #>   the registry declares 9f9f9f...
# #>
# #> When every mirror agrees with the others and disagrees with the
# #> registry, the registry is the likely error.
# #>
# #> Fix: the declaring package needs a correction. Report it to its maintainer.

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: The parts declared for yourpkg/backbone@2026-09 do not produce the declared bytes.
# #>   3 parts, each matching its own checksum, combined by 'concat'
# #>   declared SHA-256: b1b1b1...
# #>   composed SHA-256: 2c40f9...
# #>
# #> Every part arrived intact, so this is not a transfer problem. Either the
# #> series is not the one this version is made of, or it is put together by
# #> something other than what the registry names.
# #>
# #> Fix: the declaring package needs a correction. Report it to its maintainer.

## ----eval = FALSE-------------------------------------------------------------
# #> Error: Cannot reach any source for yourpkg/backbone@2026-09 (part 2 of 3).

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: The cached copy of yourpkg/backbone@2026-06 is damaged.
# #>   path: ~/.cache/R/getaca/yourpkg/backbone/2026-06/raw/backbone-2026-06.zip
# #>   declared SHA-256: 9f9f9f...
# #>   observed SHA-256: 71b0c2...
# #>
# #> Action: getaca_clean("backbone", package = "yourpkg"), then retry.
# #>
# #> Fix: see the actions listed above.

## ----eval = FALSE-------------------------------------------------------------
# tryCatch(
#   getaca("backbone", package = "yourpkg"),
#   getaca_error_cache_corrupt = function(e) {
#     warning("The cached backbone was damaged; refetching.", call. = FALSE)
#     getaca_clean("backbone", package = "yourpkg")
#     getaca("backbone", package = "yourpkg")
#   }
# )

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: The declaration for yourpkg/backbone@2026-06 no longer names the bytes already held.
# #>   cached SHA-256:   9f9f9f...
# #>   declared SHA-256: 71b0c2...
# #>
# #> A version identifies exact bytes, so these cannot both be that version.
# #> The cached copy was verified against the earlier declaration and has
# #> been left untouched. Publish a new version instead of redefining this
# #> one.
# #>
# #> Action: if the new declaration is the correct one, drop the old copy
# #> with getaca_clean("backbone", package = "yourpkg") and retry.
# #>
# #> Fix: the declaring package needs a correction. Report it to its maintainer.

## ----error = TRUE-------------------------------------------------------------
try({
registry("yourpkg", list(
  resource("backbone", "2026-09",
           urls = "https://host.invalid/a",
           sha256 = strrep("ab", 32)),
  resource("backbone", "2026-03",
           urls = "https://host.invalid/b",
           sha256 = strrep("cd", 32))
))
})

## ----error = TRUE-------------------------------------------------------------
try({
resource("backbone", "2026-06",
         urls = "ftp://host.invalid/a", sha256 = "abc")
})

## ----error = TRUE-------------------------------------------------------------
try({
resolve_resource("no-such-resource", registry = reg)
})

## ----error = TRUE-------------------------------------------------------------
try({
resolve_resource("backbone", package = "stats")
})

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: The registry for 'yourpkg' could not be established as authentic.
# #>   no signature could be fetched and read
# #>   source: https://yourpkg.invalid/getaca-registry.rds.sig
# #>
# #> This package declares signing keys, so a remote registry that cannot be
# #> checked against one is refused rather than used. The bundled declaration
# #> the package ships is unaffected and still resolves.
# #>
# #> Action: getaca_policy("bundled") resolves through it for this session.
# #>
# #> Fix: the declaring package needs a correction. Report it to its maintainer.

## ----eval = FALSE-------------------------------------------------------------
# install_backbone <- function(name = "backbone") {
#   tryCatch(
#     open_backbone(getaca(name, package = "yourpkg")),
# 
#     getaca_error_offline = function(e) {
#       stop("The ", name, " backbone is not installed and this session cannot ",
#            "download it.\n",
#            "On a connected machine run:\n",
#            "  yourpkg::install_backbone(\"", name, "\")\n",
#            "or point GETACA_CACHE at a directory that already holds it.",
#            call. = FALSE)
#     },
# 
#     getaca_error_unavailable = function(e) {
#       stop("The ", name, " backbone could not be downloaded from any of its ",
#            length(e$urls), " sources.\n",
#            "This is usually temporary. Try again, or use a smaller reference:\n",
#            "  yourpkg::analyse(x, backbone = \"grid\")", call. = FALSE)
#     },
# 
#     getaca_error_cache_corrupt = function(e) {
#       stop("The cached ", name, " backbone is damaged.\n",
#            "Repair it with:\n",
#            "  getaca::getaca_clean(\"", name, "\", package = \"yourpkg\")",
#            call. = FALSE)
#     }
#   )
# }

## -----------------------------------------------------------------------------
offline_error <- tryCatch(
  getaca("backbone", registry = reg, policy = "offline"),
  getaca_error = function(e) e
)
class(offline_error)[1]

## ----eval = FALSE-------------------------------------------------------------
# test_that("a missing backbone gets a yourpkg-flavoured message", {
#   withr::local_envvar(c(GETACA_OFFLINE = "true"))
#   withr::local_options(list(getaca.cache = withr::local_tempdir()))
# 
#   expect_error(install_backbone("backbone"), "On a connected machine run")
# })

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

