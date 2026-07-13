-- Create Roles for Role-Based Access Control (RBAC)
CREATE ROLE transit_operator;
CREATE ROLE transit_finance;

-- Grant Object Privileges
GRANT SELECT, INSERT, UPDATE ON SMART_CARD TO transit_operator;
GRANT SELECT ON PASSENGER TO transit_operator;
GRANT SELECT ON TRANSACTION_RECORD TO transit_finance;
GRANT SELECT ON ROUTE TO transit_finance;

-- Create Users and Assign Roles
CREATE USER ops_user IDENTIFIED BY OpsPass123;
CREATE USER fin_user IDENTIFIED BY FinPass123;

GRANT CREATE SESSION TO ops_user, fin_user;
GRANT transit_operator TO ops_user;
GRANT transit_finance TO fin_user;
