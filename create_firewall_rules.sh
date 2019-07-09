#!/bin/bash
gcloud compute firewall-rules create  puma-default\
 --allow tcp:9292 \
 --target-tags=docker-machine \
 --description=" monitoring puma  connections" \
 --direction=INGRESS

gcloud compute firewall-rules create  puma-default\
 --allow tcp:8080 \
 --target-tags=docker-machine \
 --description=" cAdvisor" \
 --direction=INGRESS