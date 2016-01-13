# Tabular Text (tabtext)

This package provides a simple way to convert a cursor to tabular plain text file (like CSV or TSV).

Here's a snippet showing how o use it

```
DECLARE
   l_employees_rc  sys_refcursor ;
   l_headings   tabtext.headings_ntt := tabtext.headings_ntt('aaa', 'bbb', 'ccc');

   Function open_cursor return sys_refcursor is
      l_src  sys_refcursor ;
   begin
      Open l_src For
        Select First_name, last_name, salary
          from hr.employees
         where employee_id < 109 ;
      return l_src;
   end;
BEGIN

   /* Comma separated values */
   tabtext.separated_values(fs_in => ';', enc_in => '"'); 
   tabtext.headings(l_headings);  -- This is optional: cursor columns will be isplayed otherwise.
   l_employees_rc := open_cursor;
   tabtext.wrap(l_employees_rc);
   loop
      begin
         dbms_output.put_line(tabtext.get_row);
      exception
         when no_data_found then
            exit;
      end;
   end loop;
   CLOSE l_employees_rc;
   
   dbms_output.put_line('.');
   dbms_output.put_line('.');

   /* Fixed column size */
   tabtext.fixed_size; 
   l_employees_rc := open_cursor;
   tabtext.wrap(l_employees_rc);
   loop
      begin
         dbms_output.put_line(tabtext.get_row);
      exception
         when no_data_found then
            exit;
      end;
   end loop;
   CLOSE l_employees_rc;
END;
/
```

