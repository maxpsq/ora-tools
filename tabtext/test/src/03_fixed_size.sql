set serveroutput on;
alter session set nls_date_format='DD/MM/YYYY';
declare
  l_employees_cur   sys_refcursor;
  buf   varchar2(1024);
begin
  open l_employees_cur for
    select e.* , d.*
      from hr.employees e
      left outer join hr.departments d
        on ( d.department_id = e.department_id);
  tabtext.fixed_size(' ');
  tabtext.wrap(l_employees_cur);
  loop
    begin
      buf := tabtext.get_row;
      dbms_output.put_line(buf);
    exception
      when no_data_found then
        tabtext.unwrap;
        exit;
    end;
  end loop;
end;
