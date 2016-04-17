

set serveroutput on;
declare
   l_cur   SYS_REFCURSOR;
begin
   -- It's important to open the cursor variable after calling `newExcel`
   -- where the NLS_NUMERIC_CHARACTERS session variable is set. Excel requires
   -- decimal numbers to be formatted using the point as decimal separator.
   spreadeasy.newExcel;
   OPEN l_cur FOR SELECT * FROM oe.orders ;
   spreadeasy.addWorksheet(l_cur, 'Orders');
   spreadeasy.build;
   
   spreadeasy_test_util.save_test('Full OE.Orders table');
   spreadeasy.reset;
exception
   when others then
      spreadeasy.reset;
      raise;
end;
/


select * from SPREADEASY_TEST_RESULTS order by test_no desc;


begin
  spreadeasy_admin.set_resource_dir('/home/oracle/Desktop/spreadeasy-resources');
  spreadeasy_admin.load_excel_xslt;
end;
/
