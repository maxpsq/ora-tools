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
	--tabtext.csv(fs_in => ';', encl_in => '"'); 
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
