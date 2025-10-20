# Building PgBouncer Container Images for CloudNativePG

This guide explains how to build PgBouncer operand images for
[CloudNativePG](https://cloudnative-pg.io) using
[Docker Bake](https://docs.docker.com/build/bake/) together with a
[GitHub Actions workflow](.github/workflows/bake.yml).

## Prerequisites

This project depends on
[`postgres-containers`](https://github.com/cloudnative-pg/postgres-containers).
Before you begin, ensure that you have met the same prerequisites and
requirements described there:

- [Prerequisites](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#prerequisites)
- [Verifying requirements (from the `postgres-containers` project)](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#verifying-requirements)

To confirm that your environment is correctly set up for building PgBouncer
images, run:

```bash
# The two docker-bake.hcl files are:
# - the one from the upstream postgres-containers repository (remote)
# - the one from this project (local), which extends/overrides the upstream file
docker buildx bake --check \
  -f docker-bake.hcl \
  -f cwd://docker-bake.hcl \
  "https://github.com/cloudnative-pg/postgres-containers.git#main" \
  ?????
```

TODO: COMPLETE PLEASE OR REMOVE
