create or replace
package body spreadeasy_admin is
/*
███████╗██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗ █████╗ ███████╗██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
███████╗██████╔╝██████╔╝█████╗  ███████║██║  ██║█████╗  ███████║███████╗ ╚████╔╝ 
╚════██║██╔═══╝ ██╔══██╗██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██║╚════██║  ╚██╔╝  
███████║██║     ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║   ██║   
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   

  a software by Massimo Pasquini                                   vers. 0.1-M1
  
  License                                                    Apache version 2.0
  Last update                                                       2016-Feb-21
  
  Project homepage                          https://github.com/maxpsq/ora-tools

*/

   
   ORA_DIRNAME  constant varchar2(30) := 'SPREADEASY_RESOURCES';
   
   
   procedure set_resource_dir(path_in in varchar2) is
      l_stmt  varchar2(32767);
   begin
      if ( path_in is null ) then
        return;
      end if;
      l_stmt := 'create or replace directory '||ORA_DIRNAME||' as '''||path_in||'''';
      execute immediate l_stmt;
   end;


   procedure load_xslt(
      style_id_in    in spreadeasy_styles.style_id%type, 
      description_in in spreadeasy_styles.description%type, 
      dir_in         in varchar2,
      fname_in       in varchar2, 
      charset_in     in varchar2
   ) is
      pragma autonomous_transaction;
   begin 
      merge into spreadeasy_styles d
         using ( select XMLType(bfilename(dir_in, fname_in), nls_charset_id(charset_in)) as document
                      , description_in   as description
                      , style_id_in      as style_id
                   from dual ) s
         on (s.style_id = d.style_id)          
         when matched then
            update set d.document = s.document
                     , d.description = s.description
         when not matched then
            insert (d.style_id, d.description, d.document)
            values (s.style_id, s.description, s.document);
      commit; 
   end; 

  
   procedure load_excel_xslt is
   begin
      load_xslt(spreadeasy.Excel, 
               'Microsoft Office XML Spreadsheet (Excel 2002 / Office XP)', 
               ORA_DIRNAME, 'excel-2002.xsl', 'AL32UTF8');
   end;


end;
/