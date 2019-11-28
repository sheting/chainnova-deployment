#!/bin/bash

docker run -d -p 30222:30222 -v $(pwd)/gitlab-notify/config.json:/home/config/config.json 370307265965.dkr.ecr.cn-north-1.amazonaws.com.cn/chainnova/ci/notify-server:0.0.1
<<<<<<< HEAD
ec491a1b9f9eb7559cf1dc53507cfeec8987d1a89e9e9ec18c3953f1c997c128
=======
>>>>>>> d6a0df20c92a9177012385b8adf451ded50fa8f4
