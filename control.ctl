LOAD DATA
APPEND
INTO TABLE emp
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
EMPNO,
ENAME,
JOB,
MGR,
HIREDATE DATE "dd/mm/yyyy",
SAL,
COMM,
DEPTNO
)
