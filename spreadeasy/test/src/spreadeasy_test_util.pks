create or replace
package spreadeasy_test_util is

   procedure save_test(
      test_unit_name_in in SPREADEASY_TEST_RESULTS.TEST_UNIT_NAME%type
   );
   
end;
/