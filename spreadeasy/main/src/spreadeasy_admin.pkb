create or replace
package body spreadeasy_admin is

   
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
      style_id_in  in spreadeasy_styles.style_id%type, 
      dir_in       in varchar2, 
      fname_in     in varchar2, 
      charset_in   in varchar2
   ) is
      pragma autonomous_transaction;
   begin
      update spreadeasy_styles s
         set s.document = XMLType(bfilename(dir_in, fname_in), nls_charset_id(charset_in))
       where s.style_id = style_id_in;
      commit; 
  end; 

  
  procedure load_excel_xslt is
  begin
     load_xslt(spreadeasy.Excel, ORA_DIRNAME, 'excel-2002.xsl', 'AL32UTF8');
  end;


end;
/