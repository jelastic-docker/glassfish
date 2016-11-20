#!/bin/bash

service ssh start

sudo -u "${USER}" /glassfish.sh "$@"