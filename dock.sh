#!/bin/bash
sudo docker build -t personal_packages . && sudo docker run -it personal_packages
