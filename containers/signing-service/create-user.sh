#!/bin/bash -e

# Add non-privileges user
groupadd --gid 999 signing-service
useradd --system --uid 999 --gid signing-service signing-service
