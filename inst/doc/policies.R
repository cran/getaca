## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(getaca)

.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-policies"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

## -----------------------------------------------------------------------------
rec <- resource("backbone", "2026-06",
                urls = "https://host.invalid/backbone-2026-06.zip",
                sha256 = strrep("9f", 32), license = "CC-BY-4.0")
format(rec)

## -----------------------------------------------------------------------------
reg <- registry(
  package = "yourpkg",
  resources = list(rec)
)

res <- resolve_resource("backbone", registry = reg, policy = "bundled")
res$id
res$source
res$digest

## -----------------------------------------------------------------------------
remote_reg <- registry(
  package = "yourpkg",
  policy  = "current",
  remote  = "https://yourpkg.invalid/getaca-registry.rds",
  resources = list(rec)
)
remote_reg

## ----eval = FALSE-------------------------------------------------------------
# resolve_resource("backbone", registry = remote_reg, policy = "current")
# #> getaca: could not reach the remote registry for 'yourpkg'; using the bundled
# #> registry.

## -----------------------------------------------------------------------------
getaca_refresh()

## -----------------------------------------------------------------------------
rewritten <- file.path(tempdir(), "rewritten.rds")
saveRDS(
  list(yourpkg = registry("yourpkg", list(
    resource("backbone", "2026-06",
             urls = "https://host.invalid/backbone-2026-06.zip",
             sha256 = strrep("ab", 32), license = "CC-BY-4.0")
  ))),
  rewritten
)
options(getaca.pin_file = rewritten)

## ----error = TRUE-------------------------------------------------------------
try({
resolve_resource("backbone", registry = reg, policy = "pinned")
})

## ----include = FALSE----------------------------------------------------------
options(getaca.pin_file = NULL)

## -----------------------------------------------------------------------------
ahead <- registry(
  package = "yourpkg",
  current = c(backbone = "2026-09"),
  resources = list(
    resource("backbone", "2026-06",
             urls = "https://host.invalid/backbone-2026-06.zip",
             sha256 = strrep("9f", 32), license = "CC-BY-4.0"),
    resource("backbone", "2026-09",
             urls = "https://host.invalid/backbone-2026-09.zip",
             sha256 = strrep("ab", 32), license = "CC-BY-4.0")
  )
)

resolve_resource("backbone", registry = ahead)$id
resolve_resource("backbone", registry = ahead, version = "2026-06")$id

## -----------------------------------------------------------------------------
secret <- file.path(tempdir(), "yourpkg-signing.key")
public <- registry_keygen(secret)
substr(public, 1, 24)

## -----------------------------------------------------------------------------
signed <- registry(
  package = "yourpkg",
  remote = "https://host.invalid/yourpkg.rds",
  keys = public,
  resources = list(
    resource("backbone", "2026-06",
             urls = "https://host.invalid/backbone-2026-06.zip",
             sha256 = strrep("9f", 32), license = "CC-BY-4.0")
  )
)

## -----------------------------------------------------------------------------
path <- file.path(tempdir(), "yourpkg.rds")
registry_write(signed, path)
registry_sign(path, key = secret)

cat(readLines(paste0(path, ".sig"))[1:4], sep = "\n")

## -----------------------------------------------------------------------------
registry_verify(path)

## ----error = TRUE-------------------------------------------------------------
try({
moved <- signed
moved$resources[[1]]$urls <- "https://elsewhere.invalid/backbone-2026-06.zip"
saveRDS(moved, path, version = 3)
registry_verify(path)
})

## -----------------------------------------------------------------------------
pins <- file.path(tempdir(), "getaca.pins.rds")
saveRDS(list(yourpkg = registry("yourpkg", list(rec))), pins)
options(getaca.pin_file = pins)

## -----------------------------------------------------------------------------
moved_on <- registry(
  package = "yourpkg",
  current = c(backbone = "2026-09"),
  resources = list(
    rec,
    resource("backbone", "2026-09",
             urls = "https://host.invalid/backbone-2026-09.zip",
             sha256 = strrep("ab", 32), license = "CC-BY-4.0")
  )
)

resolve_resource("backbone", registry = moved_on)$id
resolve_resource("backbone", registry = moved_on, policy = "pinned")$id

## ----eval = FALSE-------------------------------------------------------------
# getaca_pin(c("yourpkg", "otherpkg"))

## -----------------------------------------------------------------------------
getaca_pin("stats", path = file.path(tempdir(), "pins.rds"))

## ----include = FALSE----------------------------------------------------------
options(getaca.pin_file = NULL)

## -----------------------------------------------------------------------------
err <- tryCatch(getaca("backbone", registry = reg, policy = "offline"),
                getaca_error = function(e) e)
class(err)[1]

## -----------------------------------------------------------------------------
cat(conditionMessage(err))

## -----------------------------------------------------------------------------
getaca_policy()

## ----eval = FALSE-------------------------------------------------------------
# getaca_policy("current")                                     # this session
# getaca("backbone", package = "yourpkg", policy = "bundled")  # this call
# Sys.setenv(GETACA_POLICY = "pinned")                         # this process

## ----eval = FALSE-------------------------------------------------------------
# getaca_info("backbone", package = "yourpkg")
# #> <getaca cache entry> yourpkg/backbone@2026-06
# #>   ...
# #>   resolved by current registry sha256:8b31e0da54cf (published 2026-07-22)
# #>   source url  https://host.invalid/backbone-2026-06.zip

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

