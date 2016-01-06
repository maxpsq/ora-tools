/*
select * from dba_source where owner = 'SYS' and name='DBMS_TYPES';
select * from user_tables ;
select * from my_employees where employee_id < 104;
*/
set serveroutput on;
DECLARE

   l_employees_rc   sys_refcursor ;
   
   
   l_headings   tabtext.headings_ntt := tabtext.headings_ntt('aaa', 'bbb', 'ccc');

BEGIN
   OPEN l_employees_rc FOR 
   select employee_id ID, first_name "First Name", last_name "Last Name", hire_date "Hire date"
     from my_employees where employee_id < 104;

    -- or even better
	tabtext.init(fs_in => ';', encl_in => '"'); 
  --tabtext.init(fs_in => chr(9), encl_in => ''); 
	--tabtext.headings(l_headings);  -- or even  tabtext.no_headings;
  --tabtext.headings_off;
	tabtext.wrap(l_employees_rc);
	loop
		begin
      dbms_output.put_line(tabtext.get_row);
		exception
			when no_data_found then
				exit;
		end;
	end loop;

END;
/