# Tabular Text (tabtext)   vers. 0.1-M1 (Milestone 1)

This package provides a simple way to convert a cursor resultset to tabular plain text (like CSV or TSV).
A fixed size column format is also available but still experimental.

Here's a snippet showing how to use it:

```
DECLARE
   -- the cursor for data extraction
   l_employees_rc  sys_refcursor ;

   -- Cursor column names (or aliases) will be shown by default as column headings
   -- but may be eventually overridden passing a collection of strings
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

   /* Example 1: CSV */
   l_employees_rc := open_cursor;
   tabtext.csv;
   tabtext.wrap(l_employees_rc);
   loop
      begin
         dbms_output.put_line(tabtext.get_row);
      exception
         when no_data_found then
            exit;
      end;
   end loop;
   --> There's no actual need to close the cursor for
   --> TabText does it for you when the cursor is exhausted :)
   --> A 'unwrap' method is provided to explicitly close the
   --> cursor in case an unexpected exception is raised.
   tabtext.unwrap; 
   
   dbms_output.new_line;
   dbms_output.new_line;

   /* Example 2: TSV */
   l_employees_rc := open_cursor;
   tabtext.tsv; -- TSV
   tabtext.wrap(l_employees_rc);
   loop
      begin
         dbms_output.put_line(tabtext.get_row);
      exception
         when no_data_found then
            exit;
      end;
   end loop;
   tabtext.unwrap; 
   
   dbms_output.new_line;
   dbms_output.new_line;

   /* Example 3 : Fixed size column (EXPERIMENTAL) */
   l_employees_rc := open_cursor;
   tabtext.fixed_size; 
   tabtext.headings(l_headings); -- this is optional
   tabtext.wrap(l_employees_rc);
   loop
      begin
         dbms_output.put_line(tabtext.get_row);
      exception
         when no_data_found then
            exit;
      end;
   end loop;
   tabtext.unwrap; 
END;
/
```

