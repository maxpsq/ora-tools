/*
select * from dba_source where owner = 'SYS' and name='DBMS_TYPES';
select * from user_tables ;
select * from my_employees where employee_id < 104;
*/
set serveroutput on;
DECLARE

   l_employees_sysrc   sys_refcursor ;
   l_avg_sal_sysrc     sys_refcursor ;
   
   l_headings   tabtext.headings_ntt := tabtext.headings_ntt('aaa', 'bbb', 'ccc');

BEGIN
   OPEN l_employees_sysrc FOR 
   select employee_id ID, first_name "First Name", last_name "Last Name", hire_date "Hire date"
     from my_employees where employee_id < 104;

   OPEN l_avg_sal_sysrc FOR 
   select department_id, to_char(round(sum(salary),2),'99G999G999D00')
     from my_employees 
    group by department_id;

    -- or even better
	--tabtext.separated_values(fs_in => ';', encl_in => '"'); 
  tabtext.fixed_size; 
  --tabtext.init(fs_in => chr(9), encl_in => ''); 
	--tabtext.headings(l_headings);  -- or even  tabtext.no_headings;
  --tabtext.headings_off;
	tabtext.wrap(l_avg_sal_sysrc);
	loop
		begin
      dbms_output.put_line(tabtext.get_row);
		exception
			when no_data_found then
				exit;
		end;
	end loop;
exception
  when tabtext.no_cursor_provided then  
    raise; 
END;
/
drop table TEST_TABTEXT purge;

CREATE TABLE TEST_TABTEXT2 (
   C_NUMBER             NUMBER,
   C_VARCHAR2           VARCHAR2(20),
   C_CHAR               CHAR(20),
   C_DATE               DATE,
   C_TIMESTAMP          TIMESTAMP(4),
   C_TIMESTAMP_TZ       TIMESTAMP(4) WITH TIME ZONE,
   C_TIMESTAMP_LTZ      TIMESTAMP(4) WITH LOCAL TIME ZONE,
   C_INTERVAL_DS        INTERVAL DAY(2) TO SECOND(5),
   C_INTERVAL_YM        INTERVAL YEAR(5) TO MONTH
);
INSERT INTO TEST_TABTEXT2
SELECT 76534.7623, 'STRINGA VARIABILE', 'STRINGA FISSA',
       SYSDATE, LOCALTIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
       INTERVAL '5' DAY, INTERVAL '1' MONTH
FROM DUAL;
COMMIT;


CREATE TABLE TEST_TABTEXT (
   C_NUMBER             NUMBER,
   C_VARCHAR2           VARCHAR2(20),
   C_CHAR               CHAR(20),
   C_DATE               DATE,
   C_TIMESTAMP          TIMESTAMP(9),
   C_TIMESTAMP_TZ       TIMESTAMP(9) WITH TIME ZONE,
   C_TIMESTAMP_LTZ      TIMESTAMP(9) WITH LOCAL TIME ZONE,
   C_INTERVAL_DS        INTERVAL DAY(9) TO SECOND(9),
   C_INTERVAL_YM        INTERVAL YEAR(9) TO MONTH
);

INSERT INTO TEST_TABTEXT
SELECT 76534.7623, 'STRINGA VARIABILE', 'STRINGA FISSA',
       SYSDATE, LOCALTIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
       INTERVAL '5' DAY, INTERVAL '1' MONTH
FROM DUAL;
COMMIT;

rollback;

set serveroutput on;
DECLARE
   l_cur   sys_refcursor ;
BEGIN
   OPEN l_cur FOR 
   select C_NUMBER,
          C_VARCHAR2,
          C_CHAR,
   C_TIMESTAMP,
   C_TIMESTAMP_TZ,
   C_TIMESTAMP_LTZ,
   C_INTERVAL_DS,
   C_INTERVAL_YM,
          C_DATE
     from TEST_TABTEXT2;

	tabtext.separated_values(fs_in => ';', encl_in => '"'); 
	tabtext.wrap(l_cur);
	loop
		begin
      dbms_output.put_line(tabtext.get_row);
		exception
			when no_data_found then
				exit;
		end;
	end loop;
exception
  when tabtext.no_cursor_provided then  
    raise; 
END;
/


