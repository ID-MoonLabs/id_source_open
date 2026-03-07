#!/bin/bash
set -e

echo "Waiting for Greenplum to be ready..."
sleep 30

# 配置hosts文件
echo "192.168.19.10 master" >> /etc/hosts
echo "192.168.19.11 seg1" >> /etc/hosts
echo "192.168.19.12 seg2" >> /etc/hosts

# 初始化Greenplum数据库（如果需要手动初始化）
# 等待Master完全启动
su - gpadmin -c "gpstate" || echo "Greenplum initializing..."

# 等待数据库就绪
until su - gpadmin -c "psql -c 'select 1'" &>/dev/null; do
    echo "Waiting for database..."
    sleep 5
done

echo "Greenplum is ready!"

# 执行SQL脚本
su - gpadmin -c "psql -f /docker-entrypoint-initdb.d/setup_database.sql"

echo "Database setup complete!"
