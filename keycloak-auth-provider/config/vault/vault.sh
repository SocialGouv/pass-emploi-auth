#!/bin/bash

#docker run --rm -it -v $(pwd):/ansible willhallonline/ansible:2.11-alpine-3.13 "echo toto" 
docker run --rm -it -v $(pwd):/ansible ansible-vault /bin/bash
