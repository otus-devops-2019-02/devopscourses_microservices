#!/bin/bash
gcloud compute firewall-rules create gitlab-ci\
 --allow tcp:80,tcp:443 \
 --target-tags=docker-machine \
 --description="gitlab-ci connections http & https" \
 --direction=INGRESS

