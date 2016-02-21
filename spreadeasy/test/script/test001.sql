

set serveroutput on;
declare
   l_cur   SYS_REFCURSOR;
begin
   OPEN l_cur FOR SELECT * FROM oe.orders ;
   spreadeasy.newExcel;
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
  spreadeasy_admin.set_resource_dir('/home/oracle/Desktop');
  spreadeasy_admin.load_excel_xslt;
end;
/
