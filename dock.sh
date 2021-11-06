#!/bin/bash
docker build -t personal_packages . && docker run -it personal_packages
