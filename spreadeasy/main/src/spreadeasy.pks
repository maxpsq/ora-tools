create or replace 
package spreadeasy as
/*
███████╗██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗ █████╗ ███████╗██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
███████╗██████╔╝██████╔╝█████╗  ███████║██║  ██║█████╗  ███████║███████╗ ╚████╔╝ 
╚════██║██╔═══╝ ██╔══██╗██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██║╚════██║  ╚██╔╝  
███████║██║     ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║   ██║   
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   

  a software by Massimo Pasquini                                   vers. 0.1-M2
  
  License                                                    Apache version 2.0
  Last update                                                       2016-Feb-23
  
  Project homepage                          https://github.com/maxpsq/ora-tools

*/

   TYPE doc_props_rt is record(
      author      varchar2(128),
      created     date,
      company     varchar2(128)
   );

   SUBTYPE worksheet_idx_t     is PLS_INTEGER;

   SUBTYPE worksheet_name_t    is varchar2(31);

   TYPE worksheet_rec_t is record(name  worksheet_name_t, refcur PLS_INTEGER);
   
   TYPE worksheets_nt_t is table of worksheet_rec_t;

   subtype      style_t   IS spreadeasy_styles.style_id%type;

   
   Excel        CONSTANT  style_t := 1 ;
-- Calc         CONSTANT  style_t := 2 ;


   subtype execution_time_t   is INTERVAL DAY(1) TO SECOND(9);

   
   procedure reset;


   procedure newWorkbook(
      style_in           in style_t,
      doc_props_rec_in   in doc_props_rt
   );
   
   
   procedure newWorkbook(
      style_in     in style_t,
      author_in    in varchar2, 
      company_in   in varchar2
   );   
   
   
   procedure newExcel(
      author_in    in varchar2 default user, 
      company_in   in varchar2 default ''
   );


   procedure format(style_in  in  style_t);
   

   procedure addWorksheet(
      sqlCursor_io in out sys_refcursor,
      name_in      in     worksheet_name_t DEFAULT null
   );
   
   
   procedure addWorksheet(
      sqlSelect_in in     varchar2,
      name_in      in     worksheet_name_t DEFAULT null
   );
   
   
   function getStyle return style_t;
   
   
   procedure build ;
   
   
   function getAsXMLType return XMLType;
   
   
   function getAsCLOB return CLOB;
   
   
   function getStartTime return timestamp;
   
   
   function getExecutionTime return execution_time_t;
   
end;
/