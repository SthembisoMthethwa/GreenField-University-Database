/* ============================================================
   Greenfield University Database
   Sample Queries: Demonstrating JOINs, aggregation, subqueries,
   window functions, and CASE logic across the schema.
   ============================================================ */

-- 1. Which tutor teaches which course, in which room
SELECT T.FirstName, T.LastName, C.CourseName, R.RoomName, TT.Period_date, TT.StartTime
FROM Timetable TT
JOIN Tutor T ON TT.TutorID = T.TutorID
JOIN Course C ON TT.CourseID = C.CourseID
JOIN Room R ON TT.RoomID = R.RoomID;

-- 2. Students enrolled in courses, with grades
SELECT S.FirstName, S.LastName, C.CourseName, E.Semester, E.Grade
FROM Enrollment E
JOIN Student S ON E.StudentID = S.StudentID
JOIN Course C ON E.CourseID = C.CourseID;

-- 3. Attendance report per student per period
SELECT S.FirstName, S.LastName, TT.Period_name, TT.Period_date, A.Status
FROM Attendance A
JOIN Student S ON A.StudentID = S.StudentID
JOIN Timetable TT ON A.PeriodID = TT.PeriodID;

-- 4. Department overview: head of department + tutor count
SELECT D.DepartmentName,
       ISNULL(HOD.FirstName + ' ' + HOD.LastName, 'Vacant') AS HeadOfDepartment,
       COUNT(T.TutorID) AS NumberOfTutors
FROM Department D
LEFT JOIN Tutor HOD ON D.HeadOfDeptID = HOD.TutorID
LEFT JOIN Tutor T ON T.DepartmentID = D.DepartmentID
GROUP BY D.DepartmentName, HOD.FirstName, HOD.LastName;

-- 5. Full student profile: programme, department, courses, grades
SELECT S.FirstName, S.LastName, P.ProgrammeName, D.DepartmentName, C.CourseName, E.Grade
FROM Student S
JOIN Programme P ON S.ProgrammeID = P.ProgrammeID
JOIN Department D ON P.DepartmentID = D.DepartmentID
JOIN Enrollment E ON S.StudentID = E.StudentID
JOIN Course C ON E.CourseID = C.CourseID;

-- 6. Total salary cost per department (Tutors + Employees combined)
SELECT D.DepartmentName,
       ISNULL(SUM(T.Salary), 0) + ISNULL(SUM(EMP.Salary), 0) AS TotalSalaryCost
FROM Department D
LEFT JOIN Tutor T ON T.DepartmentID = D.DepartmentID
LEFT JOIN Employee EMP ON EMP.DepartmentID = D.DepartmentID
GROUP BY D.DepartmentName;

-- 7. Tutors earning above the average tutor salary (subquery)
SELECT FirstName, LastName, Salary
FROM Tutor
WHERE Salary > (SELECT AVG(Salary) FROM Tutor);

-- 8. Departments with no tutors assigned (subquery + NOT IN)
SELECT DepartmentName
FROM Department
WHERE DepartmentID NOT IN (
    SELECT DepartmentID FROM Tutor WHERE DepartmentID IS NOT NULL
);

-- 9. Salary band classification (CASE statement)
SELECT FirstName, LastName, Salary,
    CASE
        WHEN Salary >= 46000 THEN 'High'
        WHEN Salary >= 42000 THEN 'Medium'
        ELSE 'Low'
    END AS SalaryBand
FROM Tutor;

-- 10. Highest-paid tutor per department (window function)
SELECT * FROM (
    SELECT FirstName, LastName, DepartmentID, Salary,
        RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
    FROM Tutor
) Ranked
WHERE SalaryRank = 1;

-- 11. Attendance summary: present/absent/late counts (CASE inside aggregate)
SELECT
    COUNT(CASE WHEN Status = 'Present' THEN 1 END) AS PresentCount,
    COUNT(CASE WHEN Status = 'Absent' THEN 1 END) AS AbsentCount,
    COUNT(CASE WHEN Status = 'Late' THEN 1 END) AS LateCount
FROM Attendance;

-- 12. Enrollments not yet graded
SELECT S.FirstName, S.LastName, C.CourseName, E.Semester
FROM Enrollment E
JOIN Student S ON E.StudentID = S.StudentID
JOIN Course C ON E.CourseID = C.CourseID
WHERE E.Grade IS NULL;

-- 13. Row counts across all tables (sanity check)
SELECT 'Department' AS TableName, COUNT(*) AS TotalRows FROM Department
UNION ALL SELECT 'Room', COUNT(*) FROM Room
UNION ALL SELECT 'Programme', COUNT(*) FROM Programme
UNION ALL SELECT 'Tutor', COUNT(*) FROM Tutor
UNION ALL SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL SELECT 'Course', COUNT(*) FROM Course
UNION ALL SELECT 'Student', COUNT(*) FROM Student
UNION ALL SELECT 'Timetable', COUNT(*) FROM Timetable
UNION ALL SELECT 'Enrollment', COUNT(*) FROM Enrollment
UNION ALL SELECT 'Attendance', COUNT(*) FROM Attendance;

-- 14. Verify all foreign key relationships are enforced
SELECT
    fk.name AS FK_Name,
    tp.name AS ParentTable,
    cp.name AS FK_Column,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
ORDER BY ParentTable;
