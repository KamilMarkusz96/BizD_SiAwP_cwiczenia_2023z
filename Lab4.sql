/* 1.1 */

CREATE OR REPLACE FUNCTION znajdzPrace(idPracy VARCHAR2) RETURN VARCHAR2
IS
    v_nazwaPracy VARCHAR2(150);
BEGIN
    SELECT job_title INTO v_nazwaPracy FROM JOBS WHERE job_id = idPracy;
    RETURN v_nazwaPracy;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie ma pracy o danym ID');
END;
/
SELECT znajdzPrace('AD_PRES') AS nazwa_pracy FROM DUAL;


/* 1.2 */

CREATE OR REPLACE FUNCTION roczneZarobki(idPracownika INT) RETURN FLOAT
IS
    v_wynagrodzenie FLOAT;
    v_premia FLOAT;
BEGIN
    SELECT (salary * 12) INTO v_wynagrodzenie FROM employees WHERE employee_id = idPracownika;

    SELECT (salary * commission_pct) INTO v_premia FROM employees WHERE employee_id = idPracownika;

    IF v_premia IS NOT NULL THEN
        RETURN (v_wynagrodzenie + v_premia);
    END IF;
    RETURN v_wynagrodzenie;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20002, 'Nie ma pracownika o danym ID');
END;
/
SELECT roczneZarobki(100) FROM DUAL;


/* 1.3 */

CREATE OR REPLACE FUNCTION kierunkowyWNawias(nrTelefonu IN VARCHAR2) RETURN VARCHAR2
IS
    v_kierunkowy VARCHAR2(50);
BEGIN
    v_kierunkowy := '(' || SUBSTR(nrTelefonu,1, LENGTH(nrTelefonu)-9) || ')' || SUBSTR(nrTelefonu,LENGTH(nrTelefonu)-9+1);
    RETURN v_kierunkowy;
END;
/
SELECT kierunkowyWNawias('+48123123123') FROM DUAL;


/* 1.4 */

CREATE OR REPLACE FUNCTION wielkoscLiter(sztring VARCHAR2) RETURN VARCHAR2
IS
    v_wynik VARCHAR2(4000);
BEGIN
    IF LENGTH(sztring) = 0 THEN
        RETURN NULL;
    END IF;
    
    v_wynik := INITCAP(SUBSTR(sztring, 1, 1)) || LOWER(SUBSTR(sztring, 2, LENGTH(sztring) - 2)) || INITCAP(SUBSTR(sztring, -1, 1));
    
    RETURN v_wynik;
END;
/
SELECT wielkoscLiter('sztrING') AS wynik FROM DUAL;


/* 1.5 */

CREATE OR REPLACE FUNCTION dataZPeselu(pesel VARCHAR2) RETURN VARCHAR2
IS
    v_rok VARCHAR2(4);
    v_miesiac VARCHAR2(2);
    v_dzien VARCHAR2(2);
    v_data_ur VARCHAR2(10);
BEGIN
    IF LENGTH(pesel) <> 11 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Zła długość');
    END IF;
    
    v_miesiac := SUBSTR(pesel, 3, 2);
    IF v_miesiac > 20 THEN
        v_rok := '20' || SUBSTR(pesel, 1, 2);
        v_miesiac := TO_CHAR(TO_NUMBER( v_miesiac)-20);
    ELSE
        v_rok := '19' || SUBSTR(pesel, 1, 2);
    END IF;
    v_dzien := SUBSTR(pesel, 5, 2);

    v_data_ur := v_rok || '-' || v_miesiac || '-' || v_dzien;
    
    RETURN v_data_ur;
END;
/
SELECT dataZPeselu('95121109888') AS data_urodzenia FROM DUAL;
SELECT dataZPeselu('02220202220') AS data_urodzenia FROM DUAL;


/* 1.6 */

CREATE OR REPLACE FUNCTION liczbaPracownikowIDepartmentow(kraj VARCHAR2)
RETURN 
    VARCHAR2
IS
    v_liczba_pracownikow INT;
    v_liczba_departamentow INT;
    wynik VARCHAR2(100);
BEGIN
    SELECT COUNT(*) INTO v_liczba_pracownikow FROM employees JOIN departments ON employees.department_id = departments.department_id WHERE departments.location_id IN (SELECT locations.location_id FROM locations JOIN countries ON locations.country_id = countries.country_id WHERE countries.country_name = kraj);
    SELECT COUNT(*) INTO v_liczba_departamentow FROM departments JOIN locations ON departments.location_id = locations.location_id JOIN countries ON locations.country_id = countries.country_id WHERE countries.country_name = kraj;
    IF v_liczba_departamentow = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Podany kraj nie istnieje w bazie danych.');
    END IF;   
    wynik := ' Liczba pracowników: ' || TO_CHAR(v_liczba_pracownikow) || '. Liczba departmentów: ' || TO_CHAR(v_liczba_departamentow);
    RETURN wynik;

END;
/
SELECT liczbaPracownikowIDepartmentow('Denmark') FROM DUAL;
SELECT liczbaPracownikowIDepartmentow('United States of America') FROM DUAL;




/* 2.1 */

CREATE TABLE DEPARTMENTS_ARCHIVE (department_id NUMBER, department_name VARCHAR2(50), data_zamkniecia DATE, manager_id NUMBER, location_id NUMBER);

CREATE OR REPLACE TRIGGER department_delete AFTER DELETE ON departments FOR EACH ROW
BEGIN
    INSERT INTO departments_archive
    VALUES (:OLD.department_id, :OLD.department_name, SYSTIMESTAMP, :OLD.manager_id, :OLD.location_id);
END;
/

/* 2.2 */




/* 2.3 */

CREATE SEQUENCE employeeIdSeq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

CREATE OR REPLACE TRIGGER employeesNextId BEFORE INSERT ON employees FOR EACH ROW
BEGIN
  IF :NEW.employee_id IS NULL THEN
    SELECT employeeIdSeq.NEXTVAL INTO :NEW.employee_id FROM DUAL;
  END IF;
END;
/

/* 2.4 */

CREATE OR REPLACE TRIGGER jobGradesEditStopper BEFORE INSERT OR UPDATE OR DELETE ON JOB_GRADES
BEGIN
  RAISE_APPLICATION_ERROR(-20024, 'You shall not pass.');
END;
/

/* 2.5 */

CREATE OR REPLACE TRIGGER jobsNoSalaryChange BEFORE UPDATE ON jobs FOR EACH ROW
BEGIN
    :NEW.max_salary := :OLD.max_salary;
    :NEW.min_salary := :OLD.min_salary;
END;
/

/* 3.1 */

CREATE OR REPLACE PACKAGE pakiet1 AS
    FUNCTION znajdzPrace(id_pracy VARCHAR2) RETURN VARCHAR2;
    FUNCTION roczneZarobki(id_pracownika INT) RETURN FLOAT;
    FUNCTION kierunkowyWNawias(nr_telefonu IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION wielkoscLiter(p_ciag VARCHAR2) RETURN VARCHAR2;
    FUNCTION dataZPeselu(p_pesel VARCHAR2) RETURN VARCHAR2;
    FUNCTION liczbaPracownikowIDepartmentow(kraj VARCHAR2) RETURN VARCHAR2;
END pakiet1;
/

/* 3.2 */
