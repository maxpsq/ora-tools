CREATE OR REPLACE
PACKAGE tabtext AS

   SUBTYPE headings_ind_t    IS PLS_INTEGER;
   TYPE headings_ntt         IS TABLE OF VARCHAR2(40);-- INDEX BY headings_ind_t;

   
   PROCEDURE init;


   PROCEDURE init(fs_in   IN varchar2, encl_in   IN varchar2);


   PROCEDURE headings_off;


   PROCEDURE headings(headings_in   IN headings_ntt);
   
   
   PROCEDURE wrap(rc_in IN OUT sys_refcursor);
   
   
   FUNCTION get_row RETURN VARCHAR2;

END;