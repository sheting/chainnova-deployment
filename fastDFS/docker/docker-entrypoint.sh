#!/bin/bash
mkdir -p /home/fastdfs/tracker/logs;
mkdir -p /home/fastdfs/storaged/logs;
touch /home/fastdfs/storage/logs/storaged.log;
mkdir -p /var/local/fdfs/storage/data /var/local/fdfs/tracker;
mkdir -p $STORAGE_PATH0;
ln -s /var/local/fdfs/storage/data/ /var/local/fdfs/storage/data/M00;
#sed -i \"s/listen\ .*$/listen\ \$WEB_PORT;/g\" /usr/local/nginx/conf/nginx.conf;
sed -i "s/^http.server_port=.*$/http.server_port=$WEB_PORT/g" /etc/fdfs/storage.conf;
sed -i "s/^http.server_port=.*$/http.server_port=$TRACKER_WEB_PORT/g" /etc/fdfs/tracker.conf;
if [ "$IP" = "" ]; then
    IP=`ifconfig eth0 | grep inet | awk '{print $2}'| awk -F: '{print $2}'`;
fi
sed -i "s#^base_path=.*\$#base_path=$STORAGE_PATH#g" /etc/fdfs/storage.conf;
sed -i "s#^base_path=.*\$#base_path=$TRACKER_PATH#g" /etc/fdfs/tracker.conf;
sed -i "s#^store_path0=.*\$#store_path0=$STORAGE_PATH0#g" /etc/fdfs/storage.conf;
#sed -i "s/^base_path=.*$/base_path=$STORAGE_PATH/g" /etc/fdfs/storage.conf;
#sed -i "s/^base_path=.*$/base_path=$TRACKER_PATH/g" /etc/fdfs/tracker.conf;
sed -i "s/^port=.*$/port=$STORAGE_PORT/g" /etc/fdfs/storage.conf;
#sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/client.conf;
sed -i "s/^tracker_server=.*$/tracker_server=$IP:$FDFS_PORT/g" /etc/fdfs/storage.conf;
sed -i "s/^port=.*$/port=$FDFS_PORT/g" /etc/fdfs/tracker.conf;
#sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/mod_fastdfs.conf;
#cat /etc/fdfs/tracker.conf;
#cat /etc/fdfs/storage.conf;

/etc/init.d/fdfs_trackerd start;
/etc/init.d/fdfs_storaged start;
tail -f /home/fastdfs/storage/logs/storaged.log;
#/usr/local/nginx/sbin/nginx;
