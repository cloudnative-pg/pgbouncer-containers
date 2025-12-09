variable "environment" {
  default = "testing"
  validation {
    condition = contains(["testing", "production"], environment)
    error_message = "environment must be either testing or production"
  }
}

variable "registry" {
  default = "localhost:5000"
}

// Use the revision variable to identify the commit that generated the image
variable "revision" {
  default = ""
}

fullname = ( environment == "testing") ? "${registry}/pgbouncer-testing" : "${registry}/pgbouncer"
now = timestamp()
authors = "The CloudNativePG Contributors"
url = "https://github.com/cloudnative-pg/pgbouncer-containers"

// PgBouncer version to install
// renovate: suite=trixie-pgdg depName=pgbouncer
pgBouncerVersion = "1.25.1-1.pgdg13+1"

// Debian base version
// renovate: datasource=docker versioning=loose
base = "debian:trixie-slim@sha256:e711a7b30ec1261130d0a121050b4ed81d7fb28aeabcf4ea0c7876d4e9f5aca2"

target "default" {
  dockerfile = "Dockerfile"
  context = "."
  tags = [
    "${fullname}:${plainVersion(pgBouncerVersion)}",
    "${fullname}:${plainVersion(pgBouncerVersion)}-${distroVersion(base)}",
    "${fullname}:${plainVersion(pgBouncerVersion)}-${formatdate("YYYYMMDDhhmm", now)}-${distroVersion(base)}",
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  args = {
    PGBOUNCER_VERSION = "${pgBouncerVersion}"
    BASE = "${base}"
  }
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
  annotations = [
    "index,manifest:org.opencontainers.image.created=${now}",
    "index,manifest:org.opencontainers.image.url=${url}",
    "index,manifest:org.opencontainers.image.source=${url}",
    "index,manifest:org.opencontainers.image.version=${pgBouncerVersion}",
    "index,manifest:org.opencontainers.image.revision=${revision}",
    "index,manifest:org.opencontainers.image.vendor=${authors}",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PgBouncer ${plainVersion(pgBouncerVersion)}",
    "index,manifest:org.opencontainers.image.description=A PgBouncer ${plainVersion(pgBouncerVersion)} container image",
    "index,manifest:org.opencontainers.image.documentation=${url}",
    "index,manifest:org.opencontainers.image.authors=${authors}",
    "index,manifest:org.opencontainers.image.licenses=Apache-2.0",
    "index,manifest:org.opencontainers.image.base.name=docker.io/library/debian:${tag(base)}",
    "index,manifest:org.opencontainers.image.base.digest=${digest(base)}"
  ]
  labels = {
    "org.opencontainers.image.created" = "${now}",
    "org.opencontainers.image.url" = "${url}",
    "org.opencontainers.image.source" = "${url}",
    "org.opencontainers.image.version" = "${pgBouncerVersion}",
    "org.opencontainers.image.revision" = "${revision}",
    "org.opencontainers.image.vendor" = "${authors}",
    "org.opencontainers.image.title" = "CloudNativePG PgBouncer ${plainVersion(pgBouncerVersion)}",
    "org.opencontainers.image.description" = "A PgBouncer ${plainVersion(pgBouncerVersion)} container image",
    "org.opencontainers.image.documentation" = "${url}",
    "org.opencontainers.image.authors" = "${authors}",
    "org.opencontainers.image.licenses" = "Apache-2.0"
    "org.opencontainers.image.base.name" = "docker.io/library/debian:${tag(base)}"
    "org.opencontainers.image.base.digest" = "${digest(base)}"
  }
}

function tag {
  params = [ imageNameWithSha ]
  result = index(split("@", index(split(":", imageNameWithSha), 1)), 0)
}

function distroVersion {
  params = [ imageNameWithSha ]
  result = index(split("-", tag(imageNameWithSha)), 0)
}

function digest {
  params = [ imageNameWithSha ]
  result = index(split("@", imageNameWithSha), 1)
}

function plainVersion {
  params = [ version ]
  result = index(split("-", version), 0)
}
