
nohup java -jar $JAR_NAME --server.port=$PORT --spring.profiles.active=$MODE_TYPE 2>&1 | tee -a /home/logs/salix-runtimelog.log
