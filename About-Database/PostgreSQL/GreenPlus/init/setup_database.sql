-- 创建测试数据库
\c postgres;

-- 删除已存在的表（如果存在）
DROP TABLE IF EXISTS emp CASCADE;
DROP TABLE IF EXISTS dept CASCADE;

-- ============================================
-- 创建 dept 表（小表）
-- 使用 DEPTNO 作为分布键
-- ============================================
CREATE TABLE dept (
    DEPTNO int PRIMARY KEY,
    DNAME varchar(14),
    LOC varchar(13)
)
DISTRIBUTED BY (DEPTNO);

-- 插入 dept 数据
INSERT INTO DEPT VALUES (10,'ACCOUNTING','NEW YORK');
INSERT INTO DEPT VALUES (20,'RESEARCH','DALLAS');
INSERT INTO DEPT VALUES (30,'SALES','CHICAGO');
INSERT INTO DEPT VALUES (40,'OPERATIONS','BOSTON');

-- ============================================
-- 创建 emp 表（大表）
-- 使用 DEPTNO 作为分布键（与 dept 相同）
-- 这样 deptno 相同的行会在同一个 segment 上
-- JOIN 时无需跨节点数据交换
-- ============================================
CREATE TABLE emp (
    EMPNO int,
    ENAME varchar(10),
    JOB varchar(9),
    MGR int,
    HIREDATE DATE,
    SAL int,
    COMM int,
    DEPTNO int
)
DISTRIBUTED BY (DEPTNO);

-- 插入 emp 数据
INSERT INTO emp VALUES (7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO emp VALUES (7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);
INSERT INTO emp VALUES (7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);
INSERT INTO emp VALUES (7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20);
INSERT INTO emp VALUES (7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO emp VALUES (7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30);
INSERT INTO emp VALUES (7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10);
INSERT INTO emp VALUES (7788,'SCOTT','ANALYST',7566,to_date('13-06-1987','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO emp VALUES (7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO emp VALUES (7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);
INSERT INTO emp VALUES (7876,'ADAMS','CLERK',7788,to_date('13-07-1987','dd-mm-yyyy'),1100,NULL,20);
INSERT INTO emp VALUES (7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30);
INSERT INTO emp VALUES (7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO emp VALUES (7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10);

-- ============================================
-- 验证执行计划（关键）
-- ============================================
-- 查看表分布信息
\d+ dept
\d+ emp

-- 执行查询并查看执行计划（带EXPLAIN）
EXPLAIN ANALYZE
SELECT e.ename, d.dname
FROM dept d, emp e
WHERE d.deptno = e.deptno;

-- 简洁版执行计划
EXPLAIN
SELECT e.ename, d.dname
FROM dept d, emp e
WHERE d.deptno = e.deptno;
