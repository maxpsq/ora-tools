set serveroutput on;
declare
   l_cur   SYS_REFCURSOR;
   l_stmt1 VARCHAR2(500) := 'SELECT HIRE_DATE as "HIRE", LAST_NAME as "Cognome", salary/2.32 as FLOAT_VALUE FROM hr.employees WHERE department_id = 100';
   l_stmt2 VARCHAR2(500) := 'SELECT DEPARTMENT_NAME as "Dipartimento", MANAGER_ID as "ID>capo" FROM hr.departments WHERE rownum < 4';
begin
   spreadeasy.newExcel('Max','New Company');
   spreadeasy.addWorksheet(l_stmt2);
   spreadeasy.addWorksheet(l_stmt1);
   spreadeasy.build;
   spreadeasy_test_util.save_test('Employees and Departments table');
   spreadeasy.reset;
exception
   when others then
      spreadeasy.reset;
      raise;
end;
/


select * from SPREADEASY_TEST_RESULTS order by test_no desc;


begin
  spreadeasy_admin.set_resource_dir('/home/oracle/Desktop');
  spreadeasy_admin.load_excel_xslt;
end;
/
