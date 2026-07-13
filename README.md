## FINAL PROJECT REPORT
- Project Title: Urban Smart Public Transit & Contactless Fare System
- Course: DPR400210 – Database Programming with Oracle Database
- Student Name: Ingabire Adeline
- Student ID: 32534
1. Introduction
The Urban Smart Public Transit & Contactless Fare System is a centralized Oracle database solution designed to modernize public transportation. It automates passenger registration, contactless fare collection, fleet scheduling, and revenue management, replacing inefficient manual ticketing systems.
2. Problem Definition
Urban public transport operators face severe challenges due to manual cash fare collection, resulting in long boarding queues, revenue leakage, ticket fraud, and a lack of centralized operational data. These inefficiencies increase operational costs and degrade the passenger experience.
3. Methodology
The project was developed following a structured database lifecycle:
Problem Analysis: Identified operational bottlenecks in public transit.
Business Process Modeling: Mapped actors, workflows, and system scope using UML/BPMN.
Logical Design: Designed normalized entities (3NF) to ensure data integrity.
Implementation: Created the Oracle database, tables, constraints, and PL/SQL logic.
Advanced Programming: Implemented triggers for auditing and strict business rule enforcement.
4. Database Design
The database schema consists of 9 core entities: PASSENGER, SMART_CARD, BUS, DRIVER, ROUTE, SCHEDULE, TRANSACTION_RECORD, PUBLIC_HOLIDAY, and AUDIT_LOG.
Normalization: The design is normalized to the Third Normal Form (3NF). Partial dependencies were eliminated by ensuring all non-key attributes depend fully on the primary key. Transitive dependencies were removed (e.g., Route details depend only on Route_ID, not on Schedule_ID).
5. Implementation Details
Database Creation: A dedicated Pluggable Database (PDB) and user were created with specific privileges following the required naming convention.
Table Implementation: Tables were created with strict constraints (PK, FK, UNIQUE, CHECK) to enforce data integrity (e.g., Balance >= 0, Arrival_Time > Departure_Time).
PL/SQL Programming: Developed a TransitManagement package containing the ProcessFare procedure to handle secure fare deduction and the GetDailyRevenue function for financial reporting. Exception handling ensures transaction rollback on failures.
Advanced Programming:
Implemented an AFTER trigger to automatically log all DML operations on SMART_CARD into the AUDIT_LOG table.
Implemented a COMPOUND TRIGGER on TRANSACTION_RECORD to block all INSERT/UPDATE/DELETE operations on weekdays and public holidays, enforcing strict operational business rules.
6. Results & Testing
Fare Processing: Executing TransitManagement.ProcessFare successfully deducts the fare, updates the balance, and logs the transaction.
Audit System: Updating a smart card balance automatically generates a record in AUDIT_LOG capturing the user, timestamp, and old/new values.
Business Rule Restriction: Attempting to insert a transaction record on a weekday successfully raises the custom error: ORA-20100: DML operations are blocked on weekdays (Monday-Friday).
Security: Users ops_user and fin_user can only access tables permitted by their assigned roles (transit_operator and transit_finance), proving RBAC functionality.
7. Conclusion
The Urban Smart Public Transit & Contactless Fare System successfully digitizes transit operations. By leveraging Oracle's advanced features such as PL/SQL packages, compound triggers, and role-based security, the system ensures data integrity, prevents fare fraud, automates revenue tracking, and enforces strict operational policies. The solution provides transport authorities with a reliable, scalable, and secure foundation for modern public transit management.
