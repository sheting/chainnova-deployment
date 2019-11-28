#!/bin/bash

DATA=$(date -d "1 week ago" +%Y-%m-%d); 

echo "${DATA}"; 

curl -XDELETE 'http://elasticsearch-0.es:9200/*-logstash-${DATA}'


