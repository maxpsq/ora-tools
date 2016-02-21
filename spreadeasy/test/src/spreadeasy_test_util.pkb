create or replace
package body spreadeasy_test_util is

   procedure save_test(
      test_unit_name_in in SPREADEASY_TEST_RESULTS.TEST_UNIT_NAME%type
   ) is
      pragma autonomous_transaction;
   begin
      INSERT INTO SPREADEASY_TEST_RESULTS r
         (r.TEST_UNIT_NAME, 
          r.STYLE_ID, r.SPREADSHEET, 
          r.START_DATE_TIME, r.EXECUTION_TIME)
      select test_unit_name_in, 
          SPREADEASY.getStyle, SPREADEASY.GetAsXMLType, 
          SPREADEASY.getStartTime, SPREADEASY.getExecutionTime
        from dual;
      -- Notice this routine runs in an autonomous transaction
      commit;
   end;

end;
/