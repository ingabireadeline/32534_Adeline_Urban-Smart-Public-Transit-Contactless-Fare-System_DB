CREATE OR REPLACE TRIGGER trg_restrict_dml_operations
FOR INSERT OR UPDATE OR DELETE ON TRANSACTION_RECORD
COMPOUND TRIGGER

    v_day VARCHAR2(3);
    v_holiday_count NUMBER;
    v_today DATE;

BEFORE EACH ROW IS
BEGIN
    v_today := TRUNC(SYSDATE);
    v_day := TO_CHAR(v_today, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');
    
    -- Block operations on Weekdays (Monday - Friday)
    IF v_day IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
        RAISE_APPLICATION_ERROR(-20100, 'DML operations are blocked on weekdays (Monday-Friday).');
    END IF;
    
    -- Block operations on Public Holidays
    SELECT COUNT(*) INTO v_holiday_count 
    FROM PUBLIC_HOLIDAY 
    WHERE Holiday_Date = v_today;
    
    IF v_holiday_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'DML operations are blocked on public holidays.');
    END IF;
END BEFORE EACH ROW;

END trg_restrict_dml_operations;
/
