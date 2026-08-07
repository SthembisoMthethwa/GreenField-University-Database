# Design Notes — Greenfield University Database

This document explains the key design decisions made while building this schema.

## Normalization

**Salary removed from Timetable.** Salary originally lived in the timetable/period
table alongside tutor info. Since a tutor teaches multiple periods, this would
repeat their salary across many rows — a normalization violation. Salary was moved
to the `Tutor` table (and `Employee` table for non-teaching staff), where it belongs
to one row per person instead of being duplicated per scheduled period.

## Junction tables (many-to-many relationships)

- **Enrollment** resolves the many-to-many relationship between `Student` and
  `Course` — one student takes many courses, and one course has many students.
  The `Grade` column lives here specifically because a grade is a property of
  *one student's result in one course in one semester*, not of the student or
  course alone.
- **Attendance** resolves the many-to-many relationship between `Student` and
  `Timetable` (a specific scheduled period) — tracking whether a specific student
  was present at a specific period.

## Circular foreign key: Department ↔ Tutor

`Department.HeadOfDeptID` should reference a `Tutor`, but `Tutor.DepartmentID`
references `Department` — each table depends on the other. This was resolved by:
1. Creating `Department` first, without the `HeadOfDeptID` constraint.
2. Creating `Tutor`, which references the now-existing `Department` table.
3. Using `ALTER TABLE Department ADD FOREIGN KEY (HeadOfDeptID) REFERENCES Tutor(TutorID);`
   once `Tutor` exists, to close the loop.

## Separate Tutor and Employee tables

Tutors (academic staff) and Employees (non-teaching staff — admin, security,
cleaners, etc.) are kept in separate tables rather than one combined "Staff"
table, since their attributes diverge (e.g., `Qualification` is meaningful for
tutors but not for general staff, `ShiftType` is meaningful for employees but
not tutors). Combining them would mean a lot of unused/NULL columns depending
on staff type.

## Reserved keyword avoidance

`Role` was renamed to `JobRole` in the `Employee` table, since `ROLE` is a
reserved keyword in SQL Server (used in access control statements like
`CREATE ROLE`). Using it as a column name risks ambiguity and requires
bracket-escaping (`[Role]`) on every reference — renaming avoided that entirely.

## Data realism vs. row count balance

Naturally small real-world tables (`Department`, `Room`, `Programme`) were kept
at realistic counts (15, 20, and 15 respectively) rather than forced to an
arbitrary large number, while tables that scale in a real university
(`Tutor`, `Employee`, `Course`, `Student`, `Timetable`, `Enrollment`,
`Attendance`) were populated with 50+ rows each to demonstrate the schema
under a more realistic data volume.
