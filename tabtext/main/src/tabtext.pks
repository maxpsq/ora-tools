CREATE OR REPLACE
PACKAGE tabtext AS

   SUBTYPE  varchar2_max_t     IS VARCHAR2(32767);
   SUBTYPE  apperrmsg_t        IS VARCHAR2(2000);
   
   
   no_cursor_provided          EXCEPTION;
   NO_CURSOR_EC      CONSTANT  PLS_INTEGER := -20101;
   PRAGMA EXCEPTION_INIT( no_cursor_provided, -20101); 
   

   SUBTYPE headings_ind_t      IS PLS_INTEGER;
   TYPE headings_ntt           IS TABLE OF varchar2_max_t; -- see DBMS_SQL.desc_rec3.col_name

   
   -- Public routines...

   
   PROCEDURE separated_values(fs_in   IN varchar2, encl_in   IN varchar2);
   
   
   PROCEDURE separated_values;


   PROCEDURE fixed_size ;


   PROCEDURE headings_off;


   PROCEDURE headings(headings_in   IN headings_ntt);
   
   
   PROCEDURE wrap(rc_in IN OUT sys_refcursor);
   
   
   FUNCTION get_row RETURN VARCHAR2;

END tabtext;