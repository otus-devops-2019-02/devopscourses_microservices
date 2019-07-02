#!/bin/bash
gcloud compute firewall-rules create  puma-default\
 --allow tcp:9292 \
 --target-tags=docker-machine \
 --description=" monitoring puma  connections" \
 --direction=INGRESS