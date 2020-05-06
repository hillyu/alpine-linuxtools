#!/bin/bash
dockerd >/tmp/docker.stdout 2>/tmp/docker.stderr
exec "$@"
