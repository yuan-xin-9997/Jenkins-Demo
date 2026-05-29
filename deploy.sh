# /home/yuanxin/deploy.sh
#!/bin/bash
cd /home/yuanxin/demo
pkill -f demo-0.0.1-SNAPSHOT.jar || true
nohup java -jar demo-0.0.1-SNAPSHOT.jar > app.log 2>&1 &
echo "应用启动成功 - $(date)" >> deploy.log