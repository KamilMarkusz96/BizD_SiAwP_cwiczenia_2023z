/* 1 i 2 */
DECLARE
  numer_max DEPARTMENTS.DEPARTMENT_ID%TYPE;
  nowy_numer NUMBER;
  nowy_departament_name DEPARTMENTS.DEPARTMENT_NAME%TYPE := 'EDUCATION';
BEGIN
  SELECT MAX(DEPARTMENT_ID) INTO numer_max FROM DEPARTMENTS;

  nowy_numer := numer_max + 10;

  INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, LOCATION_ID)
  VALUES (nowy_numer, nowy_departament_name, 3000);
END;

/* 3 */

CREATE TABLE NOWA (LICZBA VARCHAR2(10));

DECLARE
  i NUMBER := 1;
BEGIN
  WHILE i <= 10 LOOP
    IF i <> 4 AND i <> 6 THEN
      INSERT INTO NOWA (LICZBA) VALUES (TO_CHAR(i));
    END IF;
    i := i + 1;
  END LOOP;
END;

/* 4 */

SET SERVEROUTPUT ON;

DECLARE
  KRAJ COUNTRIES%ROWTYPE;
BEGIN
  SELECT * INTO KRAJ FROM COUNTRIES WHERE COUNTRY_ID = 'CA';
  DBMS_OUTPUT.PUT_LINE('NAZWA KRAJU: ' || KRAJ.COUNTRY_NAME);
  DBMS_OUTPUT.PUT_LINE('ID REGIONU: ' || KRAJ.REGION_ID);
END;


/* 5 i 6 */

DECLARE
  DEPARTAMENTY DEPARTMENTS%ROWTYPE;
BEGIN
  FOR i IN 1..10 LOOP
    SELECT * INTO DEPARTAMENTY FROM DEPARTMENTS WHERE DEPARTMENT_ID = i * 10;
      DBMS_OUTPUT.PUT_LINE('DEPARTMENT_ID: ' || DEPARTAMENTY.DEPARTMENT_ID);
      DBMS_OUTPUT.PUT_LINE('DEPARTMENT_NAME: ' || DEPARTAMENTY.DEPARTMENT_NAME);
      DBMS_OUTPUT.PUT_LINE('MANAGER_ID: ' || DEPARTAMENTY.MANAGER_ID);
      DBMS_OUTPUT.PUT_LINE('LOCATION_ID: ' || DEPARTAMENTY.LOCATION_ID);
      DBMS_OUTPUT.PUT_LINE('------------------------');
  END LOOP;
END;


/* 7 */

DECLARE
  CURSOR WYNAGRODZENIE_CUR IS SELECT LAST_NAME, SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID = 50;
  V_LAST_NAME EMPLOYEES.LAST_NAME%TYPE;
  V_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
  OPEN WYNAGRODZENIE_CUR;
  LOOP
    FETCH WYNAGRODZENIE_CUR INTO V_LAST_NAME, V_SALARY;
    EXIT WHEN WYNAGRODZENIE_CUR%NOTFOUND;
    IF V_SALARY > 3100 THEN
      DBMS_OUTPUT.PUT_LINE(V_LAST_NAME || ' - NIE DAWAÆ PODWY¯KI');
    ELSE
      DBMS_OUTPUT.PUT_LINE(V_LAST_NAME || ' - DAÆ PODWY¯KÊ');
    END IF;
  END LOOP;
  CLOSE WYNAGRODZENIE_CUR;
END;


/* 8 */

DECLARE
  CURSOR ZAROBKI_IMIE_NAZWISKO_CUR (MIN_SALARY NUMBER, MAX_SALARY NUMBER, PART_OF_NAME CHAR) IS SELECT FIRST_NAME, LAST_NAME, SALARY FROM EMPLOYEES WHERE SALARY BETWEEN MIN_SALARY AND MAX_SALARY AND (UPPER(FIRST_NAME) LIKE '%' || UPPER(PART_OF_NAME) || '%');
  V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;
  V_LAST_NAME EMPLOYEES.LAST_NAME%TYPE;
  V_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
  OPEN ZAROBKI_IMIE_NAZWISKO_CUR(1000, 5000, 'A');
  LOOP
    FETCH ZAROBKI_IMIE_NAZWISKO_CUR INTO V_FIRST_NAME, V_LAST_NAME, V_SALARY;
    EXIT WHEN ZAROBKI_IMIE_NAZWISKO_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(V_FIRST_NAME || ' ' || V_LAST_NAME || ' - ' || V_SALARY || ' Z£');
  END LOOP;
  CLOSE ZAROBKI_IMIE_NAZWISKO_CUR;
DBMS_OUTPUT.PUT_LINE('------------------------');
  OPEN ZAROBKI_IMIE_NAZWISKO_CUR(5000, 20000, 'U');
  LOOP
    FETCH ZAROBKI_IMIE_NAZWISKO_CUR INTO V_FIRST_NAME, V_LAST_NAME, V_SALARY;
    EXIT WHEN ZAROBKI_IMIE_NAZWISKO_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(V_FIRST_NAME || ' ' || V_LAST_NAME || ' - ' || V_SALARY || ' Z£');
  END LOOP;
  CLOSE ZAROBKI_IMIE_NAZWISKO_CUR;
END;

/* 9 */
/* a */
CREATE OR REPLACE PROCEDURE DodajJob(p_JobID IN JOBS.JOB_ID%TYPE, p_JobTitle IN JOBS.JOB_TITLE%TYPE) AS
BEGIN
  INSERT INTO JOBS (JOB_ID, JOB_TITLE) VALUES (p_JobID, p_JobTitle);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Blad, do tabeli JOBS nie mo¿na dodaæ wiersza ' || SQLERRM);
END DodajJob;
/

CALL DodajJob('NAUCZ', 'NAUCZCIEL')


/* b */
CREATE OR REPLACE PROCEDURE ModyfikujJobTitle(p_ID IN JOBS.JOB_ID%TYPE, p_NewTitle IN JOBS.JOB_TITLE%TYPE) AS
v_NoJobsUpdated EXCEPTION;
PRAGMA EXCEPTION_INIT(v_NoJobsUpdated, -20000);
v_ErrorCode NUMBER;
BEGIN
UPDATE JOBS SET JOB_TITLE = p_NewTitle WHERE JOB_ID = p_ID;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE v_NoJobsUpdated;
    END IF;
COMMIT;
EXCEPTION
    WHEN v_NoJobsUpdated THEN
        DBMS_OUTPUT.PUT_LINE('B³ad, nie zaktualizowano wierszy.');
END ModyfikujJobTitle;
/

CALL ModyfikujJobTitle('NAUCZ', 'NAUCZYCIEL')

/* c */

CREATE OR REPLACE PROCEDURE UsunJob(p_JobID IN JOBS.JOB_ID%TYPE) AS
    v_NoJobsDeleted EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_NoJobsDeleted, -20001);
BEGIN
    DELETE FROM JOBS WHERE JOB_ID = p_JobID;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE v_NoJobsDeleted;
    END IF;
    COMMIT;
EXCEPTION
    WHEN v_NoJobsDeleted THEN
        DBMS_OUTPUT.PUT_LINE('B³¹d, nie usuniêto wierszy.');
END UsunJob;
/
CALL UsunJob('NAUCZ')


/* d */

CREATE OR REPLACE PROCEDURE PobierzZarobkiNazwisko(p_ID IN EMPLOYEES.EMPLOYEE_ID%TYPE, 
                                                   p_Zarobki OUT EMPLOYEES.SALARY%TYPE,
                                                   p_Nazwisko OUT EMPLOYEES.LAST_NAME%TYPE) AS
BEGIN
    SELECT SALARY, LAST_NAME INTO p_Zarobki, p_Nazwisko
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = p_ID;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono pracownika o ID: ' || p_ID);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('B³¹d podczas pobierania danych pracownika: ' || SQLERRM);
END PobierzZarobkiNazwisko;
/
DECLARE
  v_Zarobki EMPLOYEES.SALARY%TYPE;
  v_Nazwisko EMPLOYEES.LAST_NAME%TYPE;
BEGIN
  PobierzZarobkiNazwisko(111, v_Zarobki, v_Nazwisko);
  DBMS_OUTPUT.PUT_LINE('Zarobki pracownika: ' || v_Zarobki);
  DBMS_OUTPUT.PUT_LINE('Nazwisko pracownika: ' || v_Nazwisko);
END;
/




/* e */
CREATE OR REPLACE PROCEDURE DodajEmployee( p_FirstName EMPLOYEES.FIRST_NAME%TYPE,
                                            p_LastName EMPLOYEES.LAST_NAME%TYPE,
                                            p_email EMPLOYEES.EMAIL%TYPE DEFAULT 'example@mail.com',
                                            p_phoneNumber EMPLOYEES.PHONE_NUMBER%TYPE DEFAULT NULL,
                                            p_hireDate EMPLOYEES.HIRE_DATE%TYPE DEFAULT SYSDATE,
                                            p_jobID EMPLOYEES.JOB_ID%TYPE DEFAULT 'IT_PROG',
                                            p_Salary EMPLOYEES.SALARY%TYPE DEFAULT 0,
                                            p_commissionPct EMPLOYEES.COMMISSION_PCT%TYPE DEFAULT NULL,
                                            p_managerID EMPLOYEES.MANAGER_ID%TYPE DEFAULT NULL,
                                            p_departmentID EMPLOYEES.DEPARTMENT_ID%TYPE DEFAULT 10
)
AS
    v_MaxSalaryExceeded EXCEPTION;
    PRAGMA EXCEPTION_INIT(v_MaxSalaryExceeded, -20002);
    v_EmployeeID NUMBER;
BEGIN
    SELECT (MAX(EMPLOYEE_ID)+1) INTO v_EmployeeID FROM EMPLOYEES;
    IF p_Salary > 20000 THEN
        RAISE v_MaxSalaryExceeded;
    ELSE
        INSERT INTO EMPLOYEES
        VALUES (v_EmployeeID, p_FirstName, p_LastName, p_email, p_phoneNumber,
        p_hireDate, p_jobID, p_Salary, p_commissionPct, p_managerID, p_departmentID);
        COMMIT;
    END IF;
EXCEPTION
    WHEN v_MaxSalaryExceeded THEN
        DBMS_OUTPUT.PUT_LINE('Za wysokie wynagrodzenie. Nie mo¿na dodaæ pracownika.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Nie mo¿na dodaæ pracownika: ' || SQLERRM);
END DodajEmployee;
/
CALL DodajEmployee('Kamil', 'Markuszewski', 20000);





