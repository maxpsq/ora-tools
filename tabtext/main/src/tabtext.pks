CREATE OR REPLACE
PACKAGE tabtext AS
/**
___________     ___.         .__                 ___________              __   
\__    ___/____ \_ |__  __ __|  | _____ _______  \__    ___/___ ___  ____/  |_ 
  |    |  \__  \ | __ \|  |  \  | \__  \\_  __ \   |    |_/ __ \\  \/  /\   __\
  |    |   / __ \| \_\ \  |  /  |__/ __ \|  | \/   |    |\  ___/ >    <  |  |  
  |____|  (____  /___  /____/|____(____  /__|      |____| \___  >__/\_ \ |__|  
               \/    \/                \/                     \/      \/                                
               
  a software by Massimo Pasquini                                    vers. 0.0.3
  
  License                                                    Apache version 2.0                        
  Last update                                                       2016-Jan-16
  
  Project homepage                          https://github.com/maxpsq/ora-tools
  
 */

   SUBTYPE  varchar2_max_t     IS VARCHAR2(32767);
   SUBTYPE  apperrmsg_t        IS VARCHAR2(2000);
   
   
   no_cursor_provided          EXCEPTION;
   NO_CURSOR_EC      CONSTANT  PLS_INTEGER := -20101;
   PRAGMA EXCEPTION_INIT( no_cursor_provided, -20101); 
   

   SUBTYPE headings_ind_t      IS PLS_INTEGER;
   TYPE headings_ntt           IS TABLE OF varchar2_max_t; -- see DBMS_SQL.desc_rec3.col_name

   
   -- Public routines...

   
   /*\
    | Set a comma separated values row format.
    | This is the main initializer for any 'separated values' format.
   \*/
   PROCEDURE csv(
      fs_in     IN varchar2 default ',', 
      encl_in   IN varchar2 default '"', 
      esc_in    IN varchar2 default '\'
   );


   /*\
    | Set a tab separated values row format.
   \*/
   PROCEDURE tsv;


   /*\
    | Set e fixed size column row format (EXPERIMENTAL)
   \*/
   PROCEDURE fixed_size ;


   /*\
    | Prevents column headings from being returned by 'get_row'
   \*/
   PROCEDURE headings_off;


   /*\
    | Set your own column headings to override cursor column names
   \*/
   PROCEDURE headings(headings_in   IN headings_ntt);

   
   /*\
    | Pass your cursor to TabText using this routine.
   \*/
   PROCEDURE wrap(rc_in IN OUT sys_refcursor);

   
   /*\
    | Close the cursor
   \*/
   PROCEDURE unwrap;
   
   
   /*\ 
    | Returns a single line corresponding to a row from the cursor recordset or 
    | the column headings. Call this function inside a loop to fetch all the 
    | records from your cursor.
    | Raises 'no_data_found' exception when the cursor is exausted. Surround the
    | call to this routine with a PL/SQL block and catch this exception to quit
    | the loop.
    | The cursor is automatically closed before 'no_data_found' exception is 
    | raised.
   \*/
   FUNCTION get_row RETURN VARCHAR2;


END tabtext;