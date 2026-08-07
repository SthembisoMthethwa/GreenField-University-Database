/* ============================================================
   Greenfield University Database
   Schema: Table creation script
   Author: Impulse
   Description: A 10-table relational database managing tutors,
   students, courses, timetables, departments, and staff for a
   fictional university, built to demonstrate relational design,
   normalization, and T-SQL skills.
   ============================================================ */
Create database Greenfield

USE Greenfield

--Creating tables for the database

--Department
Create table Department(
DepartmentID INT primary key, 
DepartmentName VARCHAR(100) NOT NULL,
HeadofDeptID INT
);

Select * from Department
--Tutor
Create table Tutor(
TutorID INT primary key,
Firstname VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Email VARCHAR(100),
Phone_Number VARCHAR(20),
DepartmentID INT,
Salary DECIMAL (10,2),
HireDate DATE,
Qualification VARCHAR(100),
FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID));

Select * from Tutor

--Employee (non teaching staff)
Create table Employee(
EmployeeID INT primary key,
Firstname VARCHAR(50) NOT NULL,
Lastname VARCHAR(50) NOT NULL,
JobRole VARCHAR(50),
DepartmentID INT,
Salary DECIMAL (10,2),
HireDate DATE,
ShiftType VARCHAR(20),
FOREIGN KEY (DepartmentID) REFERENCES Department (DepartmentID)
);

--Room
Create table Room (
RoomID INT PRIMARY KEY,
RoomName VARCHAR(50) NOT NULL,
Building VARCHAR(50),
Capacity INT
);

--Programme (Needed for Students/Course Links)
Create Table Programme (
ProgrammeID INT Primary Key,
ProgrammeName VARCHAR (180),
DepartmentID INT,
FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

--Course
Create Table Course (
CourseID INT PRIMARY KEY,
Coursename VARCHAR (180) NOT NULL,
CourseCode VARCHAR (20) UNIQUE,
Credits INT,
DepartmentID INT,
ProgrammeID INT,
FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
FOREIGN KEY (ProgrammeID) REFERENCES Programme(ProgrammeID)
);

--Student
Create Table Student (
StudentID INT Primary Key,
FirstName VARCHAR(50) NOT NULL,
LAstName VARCHAR(50),
Email VARCHAR(100),
DateOfBirth Date,
ProgrammeID INT,
YearOfStudy INT,
FOREIGN KEY (ProgrammeID) REFERENCES Programme(ProgrammeID)
);


--Timetable 
Create Table Timetable (
PeriodID INT PRIMARY KEY,
TutorID INT,
Num_periods INT,
Period_name VARCHAR(50),
Period_date DATE,
StartTime TIME,
EndTime TIME,
CourseID INT,
RoomID INT,
FOREIGN KEY (TutorID) REFERENCES Tutor(TutorID),
FOREIGN KEY (CourseID) REFERENCES Course(CourseID),
FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

---Enrollment (Junction table: Student <-> Course)
Create Table Enrollment (
EnrollmentID INT PRIMARY KEY,
StudentID INT,
CourseID INT,
Semester VARCHAR(20),
Grade VARCHAR (5),
FOREIGN KEY (CourseID) REFERENCES Course(CourseID),
FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

---Attendance (Junction table: Student<->Timetable)
Create Table Attendance (
AttendanceID INT PRIMARY KEY,
StudentID INT,
PeriodID INT,
Status VARCHAR(25),
FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
FOREIGN KEY (PeriodID) REFERENCES Timetable(PeriodID)
);

-- ============================================================
-- Resolve circular reference: Department -> Tutor (Head of Dept)
-- Must run AFTER Tutor table exists
-- ============================================================
ALTER TABLE Department
ADD FOREIGN KEY (HeadOfDeptID) REFERENCES Tutor(TutorID);

