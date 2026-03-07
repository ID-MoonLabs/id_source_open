### 1. 进入根目录
```
cd GreenPlus
```

### 2. 启动集群

```bash
# 启动所有服务
docker-compose up -d
```

### 3. 查看启动状态

```bash
# 查看容器状态
docker-compose ps

# 查看启动日志
docker-compose logs -f master
```

### 4. 等待初始化完成

集群启动后会自动执行初始化脚本，通常需要 1-2 分钟。可以通过以下命令监控：

```bash
# 监控 master 节点日志
docker-compose logs -f master

# 当看到 "Database setup complete!" 表示初始化完成
```

## 详细部署步骤

### 步骤 1：环境准备

```bash
# 检查 Docker 和 Docker Compose 版本
docker --version
docker-compose --version

# 检查端口占用
netstat -tlnp | grep 5432
```

### 步骤 2：启动集群

```bash
# 后台启动所有服务
docker-compose up -d

# 启动指定服务（可选）
docker-compose up -d master seg1 seg2
```

### 步骤 3：验证部署

#### 3.1 检查容器状态

```bash
docker-compose ps
```

期望输出：
```
NAME                IMAGE                   COMMAND                  SERVICE     STATUS              PORTS
gp_master           datagrip/greenplum      "/docker-entrypoint.…"   master      running             0.0.0.0:5432->5432/tcp
gp_seg1             datagrip/greenplum      "/docker-entrypoint.…"   seg1        running             
gp_seg2             datagrip/greenplum      "/docker-entrypoint.…"   seg2        running             
```

#### 3.2 测试数据库连接

```bash
# 连接到 GreenPlum 数据库
docker exec -it gp_master psql -U postgres -d postgres

# 在 psql 中执行测试查询
SELECT version();
```

#### 3.3 验证测试数据

```sql
-- 查看表列表
\dt

-- 查看 dept 表数据
SELECT * FROM dept;

-- 查看 emp 表数据
SELECT * FROM emp;

-- 执行 JOIN 查询测试
SELECT e.ename, d.dname
FROM dept d, emp e
WHERE d.deptno = e.deptno;
```

## 数据库连接信息

### 连接参数
- **主机**: localhost 或 127.0.0.1
- **端口**: 5432
- **数据库**: postgres
- **用户名**: postgres
- **密码**: postgres

### 常用连接方式

#### 使用 psql 命令行
```bash
# 本地连接
psql -h localhost -p 5432 -U postgres -d postgres

# Docker 容器内连接
docker exec -it gp_master psql -U postgres -d postgres
```

#### 使用应用程序连接
```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="postgres",
    user="postgres",
    password="postgres"
)
```

## 管理命令

### 查看集群状态

```bash
# 查看 GreenPlum 集群状态
docker exec -it gp_master su - gpadmin -c "gpstate"

# 查看 segment 状态
docker exec -it gp_master su - gpadmin -c "gpstate -s"
```

### 数据库管理

```bash
# 进入数据库控制台
docker exec -it gp_master psql -U postgres -d postgres

# 备份数据库
docker exec -it gp_master pg_dump -U postgres postgres > backup.sql

# 查看数据库大小
docker exec -it gp_master psql -U postgres -d postgres -c "
SELECT pg_size_pretty(pg_database_size('postgres'));"
```

### 监控和日志

```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务日志
docker-compose logs master
docker-compose logs seg1
docker-compose logs seg2

# 实时跟踪日志
docker-compose logs -f
```

## 停止和清理

### 停止集群

```bash
# 停止所有服务（保留数据）
docker-compose stop

# 停止特定服务
docker-compose stop master
```

### 完全清理

```bash
# 停止并删除所有容器
docker-compose down

# 删除数据卷（注意：会丢失所有数据）
docker-compose down -v

# 重新构建镜像
docker-compose down -v --build
```

## 性能测试和查询优化

### 执行计划分析

集群初始化后，可以执行以下查询来分析性能优化效果：

```sql
-- 查看表分布信息
\d+ dept
\d+ emp

-- 执行查询并查看执行计划
EXPLAIN ANALYZE
SELECT e.ename, d.dname
FROM dept d, emp e
WHERE d.deptno = e.deptno;
```

### 性能对比测试

```sql
-- 统计查询
SELECT d.dname, COUNT(e.empno) as emp_count, AVG(e.sal) as avg_salary
FROM dept d
LEFT JOIN emp e ON d.deptno = e.deptno
GROUP BY d.deptno, d.dname
ORDER BY emp_count DESC;
```

## 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 查找占用端口的进程
sudo netstat -tlnp | grep 5432

# 终止占用进程
sudo kill -9 <PID>
```

#### 2. 容器启动失败
```bash
# 查看详细错误信息
docker-compose logs master

# 重新构建镜像
docker-compose down --build
docker-compose up -d
```

#### 3. 数据库连接失败
```bash
# 检查容器状态
docker-compose ps

# 检查网络连接
docker network ls
docker network inspect greenplus_gp_network
```

#### 4. 内存不足
```bash
# 检查系统资源
free -h
df -h

# 调整 Docker 内存限制
# 在 Docker Desktop 中设置内存 >= 8GB
```

### 日志分析

```bash
# 查看初始化脚本执行日志
docker-compose logs master | grep -i init

# 查看数据库启动日志
docker-compose logs master | grep -i postgres

# 查看错误信息
docker-compose logs master | grep -i error
```

## 高级配置

### 自定义配置

#### 修改数据库密码
编辑 `docker-compose.yml` 文件中的环境变量：
```yaml
environment:
  - GREENPLUM_PASSWORD=your_new_password
```

#### 调整内存配置
在 `docker-compose.yml` 中为服务添加内存限制：
```yaml
services:
  master:
    # ... 其他配置
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
```

#### 添加数据持久化
```yaml
volumes:
  - ./data:/var/lib/postgresql/data  # 添加数据目录挂载
```

### 网络配置

集群使用自定义 bridge 网络 `gp_network`，网段为 `192.168.19.0/24`。如需修改，编辑 `docker-compose.yml` 中的网络配置。

## 最佳实践

### 1. 数据备份
定期备份重要数据：
```bash
# 创建备份脚本
#!/bin/bash
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

docker exec -it gp_master pg_dump -U postgres postgres > $BACKUP_DIR/greenplum_backup_$DATE.sql
```

### 2. 监控
设置监控脚本定期检查集群状态：
```bash
#!/bin/bash
docker exec -it gp_master su - gpadmin -c "gpstate -q" || echo "Cluster check failed"
```

### 3. 性能优化
- 合理设置分布键
- 定期更新表统计信息
- 监控磁盘使用情况
- 优化查询语句

## 技术支持

如遇到问题，请检查：
1. Docker 和 Docker Compose 版本兼容性
2. 系统资源是否充足
3. 端口是否被占用
4. 防火墙设置
5. 容器日志中的错误信息

## 版本信息

- GreenPlum: latest (基于 datagrip/greenplum 镜像)
- Docker Compose: 3.5
- 网络模式: Bridge
- 数据持久化: Docker Volumes
```
