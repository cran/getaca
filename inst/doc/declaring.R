## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(getaca)

.old_options <- options(getaca.cache = file.path(tempdir(), "getaca-declaring"))
.old_envvars <- Sys.getenv(c("GETACA_OFFLINE", "NOT_CRAN"), unset = NA)
Sys.setenv(GETACA_OFFLINE = "true", NOT_CRAN = "true")

## -----------------------------------------------------------------------------
rec <- resource(
  name        = "backbone",
  version     = "2026-06",
  urls        = c("https://zenodo.invalid/records/1234567/files/backbone-2026-06.zip",
                  "https://mirror.invalid/backbone-2026-06.zip"),
  sha256      = strrep("9f", 32),
  size        = 797e6,
  license     = "CC-BY-4.0",
  description = "Reference backbone, June 2026 release"
)
rec

## ----error = TRUE-------------------------------------------------------------
try({
resource("backbone", "2026-06",
         urls = "http://insecure.invalid/backbone.zip",
         sha256 = strrep("9f", 32))
})

## ----error = TRUE-------------------------------------------------------------
try({
resource("backbone", "2026-06",
         urls = "https://ok.invalid/backbone.zip",
         sha256 = "not-a-digest")
})

## ----eval = FALSE-------------------------------------------------------------
# reg <- registry_draft(
#   c(backbone = "https://zenodo.org/records/1234567/files/backbone-2026-06.zip"),
#   package = "yourpkg",
#   version = "2026-06"
# )

## ----eval = FALSE-------------------------------------------------------------
# registry_draft("10.5281/zenodo.4924875", package = "yourpkg")
# registry_draft("10.6084/m9.figshare.14763051.v1", package = "yourpkg")
# registry_draft("10.11588/data/TKCFEF", package = "yourpkg")

## ----eval = FALSE-------------------------------------------------------------
# reg <- registry_draft(
#   list(backbone = c("https://zenodo.org/records/1234567/files/backbone-2026-06.zip",
#                "https://mirror.invalid/backbone-2026-06.zip")),
#   package = "yourpkg",
#   version = "2026-06"
# )
# registry_write(reg, "inst/getaca/registry.rds")

## ----eval = FALSE-------------------------------------------------------------
# registry_draft(
#   c(backbone = "https://zenodo.org/records/1234567/files/backbone-2026-06.zip"),
#   package = "yourpkg", version = "2026-06",
#   local   = c(backbone = "~/build/backbone-2026-06.zip")
# )

## -----------------------------------------------------------------------------
reg <- registry(
  package   = "yourpkg",
  resources = list(rec)
)
reg

## -----------------------------------------------------------------------------
registry_digest(reg)

## -----------------------------------------------------------------------------
registry_manifest(reg)

## ----eval = FALSE-------------------------------------------------------------
# # data-raw/registry.R
# registry_write(reg, "inst/getaca/registry.rds")

## -----------------------------------------------------------------------------
path <- file.path(tempdir(), "registry.rds")
registry_write(reg, path)
identical(registry_digest(registry_read(path)), registry_digest(reg))

## -----------------------------------------------------------------------------
registry_read(path)$created

## -----------------------------------------------------------------------------
reg2 <- registry(
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
reg2

## -----------------------------------------------------------------------------
getaca_catalogue(registry = reg2)[, c("name", "version", "current", "declared")]

## ----error = TRUE-------------------------------------------------------------
try({
registry(
  package = "yourpkg",
  resources = list(
    resource("backbone", "2026-09",
             urls = "https://host.invalid/a",
             sha256 = strrep("ab", 32)),
    resource("backbone", "2026-03",
             urls = "https://host.invalid/b",
             sha256 = strrep("cd", 32))
  )
)
})

## -----------------------------------------------------------------------------
remote_reg <- registry(
  package = "yourpkg",
  policy  = "current",
  remote  = "https://yourpkg.invalid/getaca-registry.rds",
  resources = list(
    resource("backbone", "2026-06",
             urls   = "https://primary.invalid/backbone-2026-06.zip",
             sha256 = strrep("9f", 32),
             license = "CC-BY-4.0")
  )
)

## ----eval = FALSE-------------------------------------------------------------
# # In a release script, after adding the new record
# registry_write(reg2, "docs/getaca-registry.rds")   # served by GitHub Pages

## -----------------------------------------------------------------------------
resource(
  name    = "backbone-db",
  version = "source-2026-06_build-3",
  urls    = "https://example.invalid/backbone-db-3.duckdb",
  sha256  = strrep("ab", 32),
  license = "CC-BY-4.0",
  upstream = list(
    source_release    = "2026-06",
    build = "3"
  )
)

## -----------------------------------------------------------------------------
series <- resource(
  name    = "backbone",
  version = "2026-09",
  sha256  = strrep("b1", 32),
  size    = 812e6,
  file    = "backbone.parquet",
  license = "CC-BY-4.0",
  parts   = list(
    part("https://zenodo.invalid/records/456/files/backbone-base.bin",
         sha256 = strrep("91", 32), size = 797e6),
    part("https://zenodo.invalid/records/456/files/backbone-2026-06.bin",
         sha256 = strrep("4e", 32), size = 9.1e6),
    part("https://zenodo.invalid/records/456/files/backbone-2026-09.bin",
         sha256 = strrep("77", 32), size = 5.4e6)
  )
)
series

## ----eval = FALSE-------------------------------------------------------------
# getaca("backbone", package = "yourpkg")
# #> Error: The parts declared for yourpkg/backbone@2026-09 do not produce the declared bytes.
# #>   3 parts, each matching its own checksum, combined by 'concat'
# #>   declared SHA-256: b1b1b1...
# #>   composed SHA-256: 2c40f9...
# #>
# #> Every part arrived intact, so this is not a transfer problem.

## -----------------------------------------------------------------------------
apply_deltas <- combiner("bsdiff", function(parts, output) {
  current <- parts[1]
  for (delta in parts[-1]) {
    current <- bspatch(current, delta, tempfile())
  }
  file.copy(current, output)
})
apply_deltas

## ----eval = FALSE-------------------------------------------------------------
# resource(
#   name    = "backbone",
#   version = "2026-12",
#   sha256  = strrep("c2", 32),
#   file    = "backbone.parquet",
#   parts   = list(
#     # The artefact of 2026-09, at its published checksum.
#     part("https://zenodo.invalid/records/456/files/backbone-2026-09.parquet",
#          sha256 = strrep("b1", 32)),
#     part("https://zenodo.invalid/records/789/files/backbone-2026-12.bin",
#          sha256 = strrep("d3", 32))
#   ),
#   combiner = apply_deltas
# )

## -----------------------------------------------------------------------------
archive <- resource(
  name      = "backbone",
  version   = "2026-06",
  urls      = "https://host.invalid/backbone-2026-06.zip",
  sha256    = strrep("9f", 32),
  license   = "CC-BY-4.0",
  processor = unpack()
)
archive

## -----------------------------------------------------------------------------
unpack("gzip")$id

## -----------------------------------------------------------------------------
unpack(members = "tables")$id

## -----------------------------------------------------------------------------
index <- processor("index-v1", function(input, output_dir) {
  out <- file.path(output_dir, "backbone.tsv")
  write.table(read.csv(input), out, sep = "\t", row.names = FALSE)
  out
})
index$id

## ----eval = FALSE-------------------------------------------------------------
# reg <- as_registry("data-raw/resources.yml", package = "yourpkg")
# registry_write(reg, "inst/getaca/registry.rds")

## ----eval = FALSE-------------------------------------------------------------
# as_registry("data-raw/resources.yml", package = "yourpkg",
#             policy = "current",
#             remote = "https://yourpkg.invalid/getaca-registry.rds")

## ----eval = FALSE-------------------------------------------------------------
# install_backbone <- function(name = "backbone") {
#   path <- tryCatch(
#     getaca(name, package = "yourpkg"),
#     getaca_error_unavailable = function(e) {
#       stop("The backbone is not installed and cannot be downloaded ",
#            "because no network connection is available.\n",
#            "Connect to the internet and run:\n",
#            "  yourpkg::install_backbone(\"backbone\")", call. = FALSE)
#     }
#   )
#   open_backbone(path)
# }

## ----eval = FALSE-------------------------------------------------------------
# resource(
#   "backbone", "2026-06",
#   urls = "https://zenodo.org/records/1234567/files/backbone-2026-06.zip",
#   doi = "10.5281/zenodo.1234567",
#   sha256 = "...", license = "CC-BY-4.0"
# )

## ----eval = FALSE-------------------------------------------------------------
# registry(
#   package = "canopy",
#   auth = list(
#     auth_host("data.ornldaac.earthdata.nasa.gov",
#               bearer("EARTHDATA_TOKEN"),
#               register = "https://urs.earthdata.nasa.gov/users/new")
#   ),
#   resources = list(
#     resource("gedi-l4a", "2026-06",
#              urls = "https://data.ornldaac.earthdata.nasa.gov/gedi/l4a-2026-06.h5",
#              sha256 = "...", license = "CC-BY-4.0")
#   )
# )

## ----eval = FALSE-------------------------------------------------------------
# getaca_credentials(package = "canopy")

## ----eval = FALSE-------------------------------------------------------------
# test_that("the shipped registry is valid and names a head", {
#   reg <- registry_for("yourpkg")
#   expect_s3_class(reg, "getaca_registry")
#   expect_equal(resolve_resource("backbone", registry = reg)$id$version, "2026-06")
# })
# 
# test_that("the backbone parses when it is available", {
#   getaca_skip_if_unavailable("backbone", package = "yourpkg")
#   expect_s3_class(read_backbone(getaca("backbone", package = "yourpkg")), "backbone")
# })

## ----include = FALSE----------------------------------------------------------
options(.old_options)
Sys.unsetenv(names(.old_envvars)[is.na(.old_envvars)])
.restore <- .old_envvars[!is.na(.old_envvars)]
if (length(.restore)) do.call(Sys.setenv, as.list(.restore))

