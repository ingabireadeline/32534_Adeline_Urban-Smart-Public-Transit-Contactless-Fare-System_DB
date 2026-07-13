CREATE OR REPLACE TRIGGER trg_audit_smart_card
AFTER INSERT OR UPDATE OR DELETE ON SMART_CARD
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
    v_old_val VARCHAR2(4000);
    v_new_val VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_new_val := 'Card_ID: ' || :NEW.Card_ID || ', Balance: ' || :NEW.Balance;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_old_val := 'Balance: ' || :OLD.Balance;
        v_new_val := 'Balance: ' || :NEW.Balance;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_old_val := 'Card_ID: ' || :OLD.Card_ID;
    END IF;

    INSERT INTO AUDIT_LOG (Table_Name, Action_Type, User_Name, Old_Value, New_Value)
    VALUES ('SMART_CARD', v_action, USER, v_old_val, v_new_val);
END;
/
