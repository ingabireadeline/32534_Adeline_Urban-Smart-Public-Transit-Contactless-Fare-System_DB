-- Connect as SYSDBA to create the user and assign privileges
-- sqlplus sys as sysdba

CREATE USER 2210_2025_Eric_Transit_DB IDENTIFIED BY SecurePass123;

GRANT CONNECT, RESOURCE TO 2210_2025_Eric_Transit_DB;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE TO 2210_2025_Eric_Transit_DB;

ALTER USER 2210_2025_Eric_Transit_DB QUOTA UNLIMITED ON USERS;

-- Connect as the new user to proceed with table creation
-- CONNECT 2210_2025_Eric_Transit_DB/SecurePass123;
