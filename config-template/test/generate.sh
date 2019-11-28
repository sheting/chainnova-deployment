#!/bin/bash

#keep the file permission
cp build_image.sh.tmpl build_image.sh
gomplate --file build_image.sh.tmpl         --out build_image.sh            --datasource baas-config.yaml

gomplate --file mysql-deployment.yaml.tmpl  --out mysql-deployment.yaml     --datasource baas-config.yaml

gomplate --file peer0-deployment.yaml.tmpl  --out peer0-deployment.yaml     --datasource baas-config.yaml
