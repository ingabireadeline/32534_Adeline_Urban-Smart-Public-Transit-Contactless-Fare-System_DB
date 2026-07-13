-- 1. Function to Get Card Balance
CREATE OR REPLACE FUNCTION GetCardBalance(p_Card_Number VARCHAR2) RETURN NUMBER IS
    v_Balance NUMBER;
BEGIN
    SELECT Balance INTO v_Balance 
    FROM SMART_CARD 
    WHERE Card_Number = p_Card_Number AND Status = 'ACTIVE';
    RETURN v_Balance;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN -1;
    WHEN OTHERS THEN RETURN -2;
END GetCardBalance;
/

-- 2. Procedure to Recharge Card
CREATE OR REPLACE PROCEDURE RechargeCard(p_Card_Number VARCHAR2, p_Amount NUMBER) IS
    v_Card_ID NUMBER;
    v_Current_Balance NUMBER;
    e_Invalid_Card EXCEPTION;
    e_Invalid_Amount EXCEPTION;
BEGIN
    IF p_Amount <= 0 THEN RAISE e_Invalid_Amount; END IF;

    SELECT Card_ID, Balance INTO v_Card_ID, v_Current_Balance
    FROM SMART_CARD WHERE Card_Number = p_Card_Number AND Status = 'ACTIVE';

    UPDATE SMART_CARD SET Balance = Balance + p_Amount WHERE Card_ID = v_Card_ID;

    INSERT INTO TRANSACTION_RECORD (Card_ID, Amount, Transaction_Type)
    VALUES (v_Card_ID, p_Amount, 'RECHARGE');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Recharge successful. New balance: ' || (v_Current_Balance + p_Amount));
EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE e_Invalid_Card;
    WHEN e_Invalid_Amount THEN DBMS_OUTPUT.PUT_LINE('Error: Amount must be > 0.');
    WHEN e_Invalid_Card THEN DBMS_OUTPUT.PUT_LINE('Error: Card not found or inactive.');
    WHEN OTHERS THEN ROLLBACK; DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END RechargeCard;
/

-- 3. Package for Transit Management
CREATE OR REPLACE PACKAGE TransitManagement AS
    PROCEDURE ProcessFare(p_Card_Number VARCHAR2, p_Schedule_ID NUMBER);
    FUNCTION GetDailyRevenue(p_Date DATE) RETURN NUMBER;
END TransitManagement;
/

CREATE OR REPLACE PACKAGE BODY TransitManagement AS
    PROCEDURE ProcessFare(p_Card_Number VARCHAR2, p_Schedule_ID NUMBER) IS
        v_Card_ID NUMBER;
        v_Balance NUMBER;
        v_Fare NUMBER;
        v_Status VARCHAR2(10);
    BEGIN
        SELECT Card_ID, Balance, Status INTO v_Card_ID, v_Balance, v_Status
        FROM SMART_CARD WHERE Card_Number = p_Card_Number;
        
        IF v_Status != 'ACTIVE' THEN RAISE_APPLICATION_ERROR(-20001, 'Card is not active.'); END IF;
        
        SELECT r.Base_Fare INTO v_Fare FROM SCHEDULE s
        JOIN ROUTE r ON s.Route_ID = r.Route_ID WHERE s.Schedule_ID = p_Schedule_ID;
        
        IF v_Balance < v_Fare THEN RAISE_APPLICATION_ERROR(-20002, 'Insufficient balance.'); END IF;
        
        UPDATE SMART_CARD SET Balance = Balance - v_Fare WHERE Card_ID = v_Card_ID;
        
        INSERT INTO TRANSACTION_RECORD (Card_ID, Schedule_ID, Amount, Transaction_Type)
        VALUES (v_Card_ID, p_Schedule_ID, v_Fare, 'FARE_DEDUCTION');
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Fare deducted. Remaining: ' || (v_Balance - v_Fare));
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20003, 'Invalid card or schedule.');
        WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20004, 'Failed: ' || SQLERRM);
    END ProcessFare;

    FUNCTION GetDailyRevenue(p_Date DATE) RETURN NUMBER IS
        v_Total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(Amount), 0) INTO v_Total FROM TRANSACTION_RECORD
        WHERE Transaction_Type = 'FARE_DEDUCTION' AND TRUNC(Transaction_Date) = p_Date;
        RETURN v_Total;
    END GetDailyRevenue;
END TransitManagement;
/

-- 4. Cursor Example: Daily Revenue Report
DECLARE
    CURSOR c_daily_revenue IS
        SELECT TRUNC(Transaction_Date) as Trans_Date, SUM(Amount) as Total_Amount
        FROM TRANSACTION_RECORD WHERE Transaction_Type = 'FARE_DEDUCTION'
        GROUP BY TRUNC(Transaction_Date) ORDER BY Trans_Date DESC;
    v_Record c_daily_revenue%ROWTYPE;
BEGIN
    OPEN c_daily_revenue;
    LOOP
        FETCH c_daily_revenue INTO v_Record;
        EXIT WHEN c_daily_revenue%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(v_Record.Trans_Date, 'YYYY-MM-DD') || ' | Revenue: ' || v_Record.Total_Amount);
    END LOOP;
    CLOSE c_daily_revenue;
END;
/
