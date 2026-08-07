# Greenfield University Database

A 10-table relational database built in Microsoft SQL Server (T-SQL), modeling
tutors, students, courses, timetables, departments, and staff for a fictional
university. Built as a hands-on SQL learning project and portfolio piece,
covering schema design, normalization, foreign key relationships, and
practical T-SQL querying.

## Scenario

Greenfield University needs a system to manage academic and administrative
operations: which tutors teach which courses, when classes are scheduled,
which students are enrolled and how they're graded, attendance tracking,
and salary/staffing records across both teaching and non-teaching staff.

## Entity Relationship Diagram

![Greenfield University ERD](diagrams/erd_diagram.png)

## Schema Overview

| Table | Purpose |
|---|---|
| Department | Academic departments, each with a head of department |
| Tutor | Academic/teaching staff |
| Employee | Non-teaching staff (admin, security, cleaning, etc.) |
| Room | Physical rooms used for scheduled classes |
| Programme | Degree programmes, linked to a department |
| Course | Individual courses, linked to a programme and department |
| Student | Enrolled students, linked to a programme |
| Timetable | Scheduled class periods (tutor, course, room, time) |
| Enrollment | Junction table: student ↔ course, with grade per semester |
| Attendance | Junction table: student ↔ scheduled period, with status |

## Key Design Decisions

- **Normalization**: Salary lives on `Tutor`/`Employee`, not `Timetable`, to
  avoid repeating it across every scheduled period.
- **Junction tables**: `Enrollment` and `Attendance` resolve the many-to-many
  relationships between students and courses/periods.
- **Circular FK resolved**: `Department.HeadOfDeptID` references `Tutor`, while
  `Tutor.DepartmentID` references `Department` — handled via `ALTER TABLE`
  after both tables exist.

Full reasoning behind these decisions is in [`docs/design_notes.md`](docs/design_notes.md).

## Tech Used

- Microsoft SQL Server / T-SQL
- SSMS (SQL Server Management Studio) — schema design, diagramming

## Repository Structure

```
greenfield-university-database/
├── README.md
├── schema/
│   └── create_tables.sql       -- All CREATE TABLE + FK statements
├── data/
│   └── insert_data.sql         -- Sample data (50+ rows per core table)
├── queries/
│   └── sample_queries.sql      -- JOINs, aggregates, subqueries, window functions
├── diagrams/
│   └── erd_diagram.png         -- Entity Relationship Diagram
└── docs/
    └── design_notes.md         -- Design decisions and reasoning
```

## Sample Query

Highest-paid tutor per department, using a window function:

```sql
SELECT * FROM (
    SELECT FirstName, LastName, DepartmentID, Salary,
        RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
    FROM Tutor
) Ranked
WHERE SalaryRank = 1;
```

More examples in [`queries/sample_queries.sql`](queries/sample_queries.sql).

## How to Run

1. Run `schema/create_tables.sql` to create the database and all 10 tables
   (respects foreign key dependency order).
2. Run `data/insert_data.sql` to populate all tables with sample data.
3. Run any query from `queries/sample_queries.sql` to explore the data.

## Author

Sthembiso Mthethwa — ICT Honours graduate, Durban University of Technology
