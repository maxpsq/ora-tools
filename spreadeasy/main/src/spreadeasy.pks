create or replace 
package spreadeasy as
/*
███████╗██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗ █████╗ ███████╗██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
███████╗██████╔╝██████╔╝█████╗  ███████║██║  ██║█████╗  ███████║███████╗ ╚████╔╝ 
╚════██║██╔═══╝ ██╔══██╗██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██║╚════██║  ╚██╔╝  
███████║██║     ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║   ██║   
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   

  a software by Massimo Pasquini                                   vers. 1.0-M3
  
  License                                                    Apache version 2.0
  Last update                                                       2016-Feb-23
  
  Project homepage                          https://github.com/maxpsq/ora-tools

*/

   C_GENERATOR   constant varchar2(64) := 'Spreadeasy v1.0-M3';

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
   ODS          CONSTANT  style_t := 2 ;


   subtype execution_time_t   is INTERVAL DAY(1) TO SECOND(9);

   
   procedure reset;


   /** Initialize a new spreadsheet  in the specified style, 
       setting the given document properties */
   procedure newWorkbook(
      style_in           in style_t,
      doc_props_rec_in   in doc_props_rt
   );
   
   
   /** Initialize a new spreadsheet in the specified style,
       setting author and company name */
   procedure newWorkbook(
      style_in     in style_t,
      author_in    in varchar2, 
      company_in   in varchar2
   );   
   
   
   /** Initialize a new ODS spreadsheet, setting author and company name */
   procedure newODS(
      author_in    in varchar2 default user, 
      company_in   in varchar2 default ''
   );
   

   /** Return the spreadsheet style previously set (1=Excel) */
   function getStyle return style_t;


   /** Add a new worksheet and on which the cursor variable data will be shown */
   procedure addWorksheet(
      sqlCursor_io in out sys_refcursor,
      name_in      in     worksheet_name_t DEFAULT null
   );
   
   
   /** Add a new worksheet and on which the select statement data will be shown */
   procedure addWorksheet(
      sqlSelect_in in     varchar2,
      name_in      in     worksheet_name_t DEFAULT null
   );
   
   
   /** Build the spreadsheet using the cursors passed to each worksheet
       and save it to disk at the given location */
   procedure build(dir_in  varchar2, filename_in varchar2); 
   
   
   /** Get the generated spreadsheet as a XMLType variable */
   function getAsXMLType return XMLType;
   
   
   /** Get the generated spreadsheet as a CLOB variable */
   function getAsCLOB return CLOB;
   
   
   /** Get the date and time of the last call to `build` routine */
   function getStartTime return timestamp;
   

   /** Get the time it took to execute the `build` routine */
   function getExecutionTime return execution_time_t;
   
end;
/