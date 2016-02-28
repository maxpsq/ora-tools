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
