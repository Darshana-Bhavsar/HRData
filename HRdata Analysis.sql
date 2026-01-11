SELECT * FROM hrdata;
-- 1. Employees earning more than their manager
SELECT E."Employee_Name", E."EmpID", E.salary as Emp_Salary, M.salary as Mng_Salary
FROM hrdata E inner JOIN hrdata M on E."ManagerID" = M."EmpID";

SELECT "EmpID" from hrdata order by "EmpID";

-- 2. Second highest salary
SELECT MAX(salary) from hrdata where salary <(select Max(salary) from hrdata);

-- 3. Nth highest salary (example 5th)
SELECT distinct salary from hrdata order by salary desc limit 1 offset 4;

SELECT * FROM hrdata
WHERE doh >= CURRENT_DATE - INTERVAL '10 years';

ALTER TABLE hrdata
ALTER COLUMN "sex" TYPE text
USING trim(replace(replace("sex"::text, '{', ''), '}', ''));

--Verify active vs terminated employees
SELECT
  COUNT(*) AS total_employees,
  COUNT("dot") AS terminated,
  COUNT(*) - COUNT("dot") AS active
FROM hrdata;

--How many employees are currently active?
select count(*) from hrdata where dot is Null;

--How many employees have left the company?
select count(*) from hrdata where dot is not Null;

--Employee count by Department
select dept,count(*) from hrdata group by dept;

--Average salary by department
select dept,round(avg(salary),4)from hrdata group by dept order by avg(salary) desc;

--Highest paid employee
select * from hrdata where salary = (select MAX(salary) from hrdata);

--Gender distribution
SELECT sex, count(*) as gender_count from hrdata group by sex;

--Average salary by gender
select sex, avg(salary) from hrdata group by sex;

--employee hired per month and year
select extract(month from(doh)) as hire_month, count(*) as hire_count from hrdata group by hire_month order by hire_count desc;

select extract(year from(doh)) as hire_yr, count(*) as hire_count from hrdata group by hire_yr order by hire_count desc;

--Attrition analysis (who left and when)
select dept, count(*)from hrdata where dot is not null group by dept order by count(*);

--Average tenure of terminated employees (in years)
SELECT
  ROUND(
    AVG(
      (dot::date - doh::date) / 365.0
    ),
    2
  ) AS avg_tenure_years
FROM hrdata
WHERE dot IS NOT NULL;

--Employees by recruitment source
select recruitmentsource, count(*) from hrdata group by recruitmentsource order by count(*) desc;

--Manager-wise team size
select managerid, managername,count(*) as team_size from hrdata group by managerid,managername order by team_size desc;

--Employees earning above department average
select empid,salary,dept from hrdata h where h.salary > (select avg(salary) from hrdata where dept = h.dept);

SELECT employee_name, empid, salary, dept_avg_salary
FROM (
    SELECT
        employee_name,
        empid,
        salary,
        dept,
        AVG(salary) OVER (PARTITION BY dept) AS dept_avg_salary
    FROM hrdata
) t
WHERE salary > dept_avg_salary;

--Age of employees (current)
SELECT empid,employee_name, extract(year from age(current_date, dob)) as age from hrdata;

--Department with highest attrition rate
select dept, count(dot)*100/count(*) as attrition_rate from hrdata group by dept order by attrition_rate desc;