CREATE DATABASE hr_analytics;
USE hr_analytics;

USE hr_analytics;
CREATE TABLE employees_raw(
Age INT,
Attrition VARCHAR(10),
BusinessTravel VARCHAR(30),
DailyRate INT,
Department VARCHAR(50),
DistanceFromHome INT,
Education INT,
EducationField VARCHAR(50),
EmployeeCount INT,
EmployeeNumber INT PRIMARY KEY,
EnvironmentSatisfaction INT,
Gender VARCHAR(20),
HourlyRate INT,
JobInvolvement INT,
JobLevel INT,
JobRole VARCHAR(50),
JobSatisfaction INT,
MaritalStatus VARCHAR(30),
MonthlyIncome INT,
MonthlyRate INT,
NumCompaniesWorked INT,
 Over18 VARCHAR(5),
 OverTime VARCHAR(10),
 PercentSalaryHike INT,
 PerformanceRating INT,
 RelationshipSatisfaction INT,
 StandardHours INT,
 StockOptionLevel INT,
 TotalWorkingYears INT,
 TrainingTimesLastYear INT,
 WorkLifeBalance INT,
 YearsAtCompany INT,
 YearsInCurrentRole INT,
 YearsSinceLastPromotion INT,
 YearsWithCurrManager INT
 );
 SHOW TABLES;
 DESCRIBE employees_raw;
 
 SELECT COUNT(*) AS total_employees
 from employees_raw_import;
 
 SELECT * 
 FROM employees_raw_import
 LIMIT 10;
 
 /* SELECT COUNT(*) AS total_employees
FROM employees_raw_import;

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'hr_analytics'
AND table_name = 'employees_raw_import';
 */
 
 -- Check for duplicate Employee IDs
 SELECT 
 EmployeeNumber,
 COUNT(*) AS duplicate_count
 FROM employees_raw_import
 GROUP BY EmployeeNumber
 HAVING COUNT(*) > 1;
 
 -- Check Missing Values
SELECT
    COUNT(*) AS total_rows,
    COUNT(EmployeeNumber) AS employee_id_present,
    COUNT(Age) AS age_present,
    COUNT(Department) AS department_present,
    COUNT(JobRole) AS job_role_present,
    COUNT(MonthlyIncome) AS income_present,
    COUNT(OverTime) AS overtime_present,
    COUNT(Attrition) AS attrition_present
FROM employees_raw_import;

SHOW COLUMNS FROM employees_raw_import;

ALTER TABLE employees_raw_import
CHANGE COLUMN `ï»¿Age` Age INT;

CREATE TABLE employees_analysis AS
SELECT
   EmployeeNumber,
    Age,
    Gender,
    MaritalStatus,
    Education,
    DistanceFromHome,
    Department,
    JobRole,
    JobLevel,
    BusinessTravel,
    OverTime,
    MonthlyIncome,
    PercentSalaryHike,
    StockOptionLevel,
    TotalWorkingYears,
    YearsAtCompany,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    YearsWithCurrManager,
    NumCompaniesWorked,
    JobSatisfaction,
    EnvironmentSatisfaction,
    WorkLifeBalance,
    JobInvolvement,
    TrainingTimesLastYear,
    Attrition
FROM employees_raw_import;
   
SELECT COUNT(*) AS total_employees
FROM employees_analysis;

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'hr_analytics'
AND table_name = 'employees_analysis';

SELECT * 
 FROM employees_analysis
 LIMIT 10;
 
 
 
 
 
 
 
 
 
 
 
 -- Q1 What is the overall employee attrition rate?
 
 SELECT                                         -- SUBQUERY 
  ROUND(
  (COUNT(*)/(SELECT COUNT(*)
  FROM employees_analysis)) *100 ,2) 
  AS attrition_rate
  FROM employees_analysis
  WHERE Attrition = 'Yes';
 
-- Q2 Find employees earning more than the average salary                   
SELECT
    EmployeeNumber,
    MonthlyIncome
FROM employees_analysis
WHERE MonthlyIncome >(
SELECT 
   AVG(MonthlyIncome)
FROM employees_analysis);

                                --   DATA RESTORE SUCCESSFULLY   (upload csv file again)

SELECT DATABASE();
SHOW TABLES;
SELECT COUNT(*) AS total_employees
FROM employees_raw;

SELECT COUNT(*) AS total_employees
FROM employees_raw_import;

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'hr_analytics'
AND table_name = 'employees_raw_import';

ALTER TABLE employees_raw_import
CHANGE COLUMN `ï»¿Age` Age INT;

CREATE TABLE employees_analysis AS
SELECT
    EmployeeNumber,
    Age,
    Gender,
    MaritalStatus,
    Education,
    DistanceFromHome,
    Department,
    JobRole,
    JobLevel,
    BusinessTravel,
    OverTime,
    MonthlyIncome,
    PercentSalaryHike,
    StockOptionLevel,
    TotalWorkingYears,
    YearsAtCompany,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    YearsWithCurrManager,
    NumCompaniesWorked,
    JobSatisfaction,
    EnvironmentSatisfaction,
    WorkLifeBalance,
    JobInvolvement,
    TrainingTimesLastYear,
    Attrition
FROM employees_raw_import;

SELECT COUNT(*) AS total_employees
FROM employees_analysis;

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'hr_analytics'
AND table_name = 'employees_analysis';

SELECT *
FROM employees_analysis
LIMIT 10;

-- Q3 Find employees who have worked at the company longer than the average employee.        
SELECT 
    EmployeeNumber,
    YearsAtCompany
FROM employees_analysis
where YearsAtCompany >(
    SELECT AVG(YearsAtCompany)
    FROM employees_analysis);

-- Q4 Find employees whose MonthlyIncome is greater than the average income of employees who left the company.
SELECT 
   EmployeeNumber,
   MonthlyIncome,
   Attrition
FROM employees_analysis
where MonthlyIncome >(
   SELECT AVG(MonthlyIncome)
   FROM employees_analysis
   where Attrition = 'Yes');

--  Q5 Find employees whose YearsAtCompany is greater than the average YearsAtCompany of employees who have left the company.
SELECT 
    EmployeeNumber,
    YearsAtCompany,
    Attrition
FROM employees_analysis
Where YearsAtCompany >(
    SELECT AVG(YearsAtCompany)
    FROM employees_analysis
    where Attrition ='Yes');                        -- 5.1308


                                              -- Correlated subquery
                                              
-- Q6: Find employees who earn more than the average salary in their department.
SELECT 
    Department,
    AVG(MonthlyIncome) AS average_salary
FROM employees_analysis
GROUP BY Department;

SELECT AVG(MonthlyIncome) AS average_salary
FROM employees_analysis
WHERE Department = 'Sales';

SELECT AVG(MonthlyIncome) AS average_salary
FROM employees_analysis
WHERE Department = 'Research & Development';

SELECT AVG(MonthlyIncome) AS average_salary
FROM employees_analysis
WHERE Department = 'Human Resources';

SELECT
    e.EmployeeNumber,
    e.Department,
    e.MonthlyIncome,
    (
        SELECT AVG(e2.MonthlyIncome)                                      -- e = employee we are currently checking   
        FROM employees_analysis e2                                        -- e2 = employees used to calculate the average 
        WHERE e2.Department = e.Department
    ) AS department_avg_salary
FROM employees_analysis e
WHERE e.MonthlyIncome > (
    SELECT AVG(e2.MonthlyIncome)
    FROM employees_analysis e2
    WHERE e2.Department = e.Department
); 


-- Q7 — Attrition rate by Department
SELECT
    Department,
    COUNT(*) AS total_employees
FROM employees_analysis
GROUP BY Department;

SELECT
    Department,
    COUNT(*) AS employees_left
FROM employees_analysis
WHERE Attrition = 'Yes'
GROUP BY Department;

SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS attrition_rate
FROM employees_analysis
GROUP BY Department;


-- Q8 — Attrition Rate by Job Role
SELECT
    JobRole,
    COUNT(*) AS total_employees
FROM employees_analysis
GROUP BY JobRole;

SELECT
    JobRole,
    COUNT(*) AS employees_left
FROM employees_analysis
WHERE Attrition = 'Yes'
GROUP BY JobRole;


SELECT
    JobRole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS attrition_rate
FROM employees_analysis
GROUP BY JobRole
ORDER BY attrition_rate DESC;


-- Q9 — Does overtime relate to employee attrition?
SELECT
      OverTime,
      Count(*) AS total_employees,
      SUM(CASE WHEN Attrition ='Yes' THEN 1 ELSE 0 END) AS employees_left,
      ROUND(
      SUM(CASE WHEN Attrition ='Yes' THEN 1 ELSE 0 END)
      /COUNT(*) * 100,
      2
      ) AS attrition_rate
FROM employees_analysis
GROUP BY OVERTIME
ORDER BY attrition_rate DESC ;
      
-- Q10 — Does job satisfaction relate to attrition?
SELECT
    JobSatisfaction,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS attrition_rate
FROM employees_analysis
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;



-- Q11 — Which departments have the highest average salary?
SELECT
    Department,
    COUNT(*) AS total_employees,
    ROUND(AVG(MonthlyIncome), 2) AS average_salary
FROM employees_analysis
GROUP BY Department
ORDER BY average_salary DESC;


-- Q12 — Which job roles have the highest average salary?
SELECT
    JobRole,
    COUNT(*) AS total_employees,
    ROUND(AVG(MonthlyIncome), 2) AS average_salary
FROM employees_analysis
GROUP BY JobRole
ORDER BY average_salary DESC;