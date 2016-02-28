# NLS_MEM

Have you ever needed to change the national language support (NLS) paremeters within
a PL/SQL block execution? Well, I have!

I wrote this utility package with the idea to make easy to issue a set of `ALTER SESSION` 
and then restore the session as it was.

NLS_MEM is just a wrapper around a stack (LIFO) where you can save the NLS settings 
within the current session you want to restore at a given time in the future.

Yes, you got it... NLS_MEM is build around an actual stack so you can save the session
settings many times and then restore the configuration to the last one you pushed in the
stack.

Here's a snippet as an example...

```
set serveroutput on;
declare
  CURRENCY_FORMAT_C  constant varchar2(20) := 'C999G999D00';
  l_salary   NUMBER := 1660.50;
  
  function expected(result_in in varchar2) return varchar2 is
  begin
    return 'Expected '||result_in;
  end;
  
  procedure print_salary(salary_in NUMBER, expected_in in varchar2) is
  begin
    dbms_output.put_line('#'||nls_mem.stack_size||' '||
      expected_in||' => '||to_char(salary_in, CURRENCY_FORMAT_C));
  end;
  
  procedure change_territory(country_in in varchar2) is
  begin
    nls_mem.altersession('NLS_TERRITORY', country_in);
  end;
  
begin
  print_salary(l_salary, expected('EUR1.660,50'));

  nls_mem.save; -- push the NLS parameters in the stack (position 1)
  change_territory('AMERICA');
  print_salary(l_salary, expected('USD1,660.50'));

  nls_mem.save; -- push the NLS parameters in the stack (position 2)
  change_territory('POLAND');
  print_salary(l_salary, expected('PLN1 660,50'));

  nls_mem.flashback; -- get params from the stack (position 2)
  print_salary(l_salary, expected('USD1,660.50'));

  nls_mem.save; -- push the NLS parameters in the stack (position 2, previously freed)
  change_territory('AUSTRALIA');
  print_salary(l_salary, expected('AUD1,660.50'));

  nls_mem.flashback;  -- get params from the stack (position 2)
  print_salary(l_salary, expected('USD1,660.50'));

  nls_mem.flashback;  -- get params from the stack (position 1)
  print_salary(l_salary, expected('EUR1.660,50'));

  -- The stack is now empty
end;
/
```

... and here's the output:

```
PL/SQL procedure succesfully completed.
#0 Expected EUR1.660,50 =>        EUR1.660,50 (*)
#1 Expected USD1,660.50 =>        USD1,660.50
#2 Expected PLN1 660,50 =>        PLN1 660,50
#1 Expected USD1,660.50 =>        USD1,660.50
#2 Expected AUD1,660.50 =>        AUD1,660.50
#1 Expected USD1,660.50 =>        USD1,660.50
#0 Expected EUR1.660,50 =>        EUR1.660,50

(*) The default NLS_TERRITORY of my client machine is ITALY
```

