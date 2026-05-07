#!/bin/bash

# This makes an image you use locally for testing.
docker build . -t segregator-base-image --no-cache
