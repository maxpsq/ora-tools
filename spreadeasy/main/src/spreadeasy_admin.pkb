create or replace
package body spreadeasy_admin is
/*
███████╗██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗ █████╗ ███████╗██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
███████╗██████╔╝██████╔╝█████╗  ███████║██║  ██║█████╗  ███████║███████╗ ╚████╔╝ 
╚════██║██╔═══╝ ██╔══██╗██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██║╚════██║  ╚██╔╝  
███████║██║     ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║   ██║   
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   

  a software by Massimo Pasquini                                   vers. 1.0-M3
  
  License                                                    Apache version 2.0
  Last update                                                       2016-May-03
  
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


   procedure unset_resource_dir is
      l_stmt  varchar2(32767);
   begin
      l_stmt := 'drop directory '||ORA_DIRNAME;
      execute immediate l_stmt;
   end;


   procedure set_style(
      style_id_in    in spreadeasy_styles.style_id%type, 
      description_in in spreadeasy_styles.description%type
   ) is
      pragma autonomous_transaction;
   begin 
      merge into spreadeasy_styles d
         using ( select description_in   as description
                      , style_id_in      as style_id
                   from dual ) s
         on (s.style_id = d.style_id)          
         when matched then
            update set d.description = s.description
         when not matched then
            insert (d.style_id, d.description)
            values (s.style_id, s.description);
      commit; 
   end; 


   procedure load_xml_builder(
      style_id_in      in spreadeasy_styles.style_id%type, 
      step_in          in number,
      builder_type_in  in varchar2,
      outpath_in       in varchar2,
      dir_in           in varchar2,
      fname_in         in varchar2, 
      charset_in       in varchar2
   ) is
      pragma autonomous_transaction;
      l_xml   XMLType;
   begin 
      l_xml := XMLType(bfilename(dir_in, fname_in), nls_charset_id(charset_in));
      merge into spreadeasy_builders d
         using ( select l_xml as xml_doc
                      , step_in          as step
                      , builder_type_in  as builder_type
                      , outpath_in       as out_path
                      , style_id_in      as style_id
                   from dual ) s
         on (s.style_id = d.style_id and s.step = d.step)          
         when matched then
            update set d.builder_type = s.builder_type
                     , d.out_path     = s.out_path
                     , d.xml_doc      = s.xml_doc
                     , d.builder_doc  = null
         when not matched then
            insert (d.style_id, d.step, d.builder_type, d.out_path, d.xml_doc)
            values (s.style_id, s.step, s.builder_type, s.out_path, s.xml_doc);
      commit; 
   end; 
  
  
   procedure load_txt_builder(
      style_id_in      in spreadeasy_styles.style_id%type, 
      step_in          in number,
      builder_type_in  in varchar2,
      out_path_in      in varchar2,
      dir_in           in varchar2,
      fname_in         in varchar2, 
      charset_in       in varchar2
   ) is
      pragma autonomous_transaction;
      
      l_bfile    bfile;
      l_clob     CLOB;
      l_fsize    INTEGER;
      l_dest_offset    INTEGER := 1;
      l_src_offset     INTEGER := 1;
      l_lang_context   INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
      l_warn           INTEGER ;

      procedure clean_up is
      begin
         dbms_lob.freetemporary( l_clob );  
         if ( 1 = DBMS_LOB.isopen(l_bfile) ) then
            DBMS_LOB.CLOSE(l_bfile);   
         end if;
      end;
      
   begin 
      l_bfile := bfilename(dir_in, fname_in);
      DBMS_LOB.OPEN (l_bfile, DBMS_LOB.LOB_READONLY);
      DBMS_LOB.CREATETEMPORARY (l_clob, TRUE, DBMS_LOB.SESSION);
      
      l_fsize := DBMS_LOB.GETLENGTH(l_bfile);
      if ( l_fsize > 0 ) then
        DBMS_LOB.LOADCLOBFROMFILE (l_clob, l_bfile, l_fsize, 
                                   l_dest_offset, l_src_offset, 
                                   NLS_CHARSET_ID(charset_in), l_lang_context, 
                                   l_warn);
      end if;
      merge into spreadeasy_builders d
         using ( select l_clob           as builder_doc
                      , step_in          as step
                      , builder_type_in  as builder_type
                      , out_path_in      as out_path
                      , style_id_in      as style_id
                   from dual ) s
         on (s.style_id = d.style_id and s.step = d.step)          
         when matched then
            update set d.builder_type = s.builder_type
                     , d.out_path     = s.out_path
                     , d.builder_doc  = s.builder_doc
                     , d.xml_doc      = null
         when not matched then
            insert (d.style_id, d.step, d.builder_type, d.out_path, d.builder_doc)
            values (s.style_id, s.step, s.builder_type, s.out_path, s.builder_doc);
      commit; 
      clean_up;    
   exception
      when others then
         clean_up;    
         raise;
   end; 

  
   procedure load_ods_builders(charset_in  in varchar2) is
      l_style_id   spreadeasy_builders.style_id%type := spreadeasy.ODS;
   begin
      set_style(l_style_id, 'Open Document Spreadsheet 1.2');
      load_xml_builder(l_style_id, 1, 'XSL', 'meta.xml', 
                       ORA_DIRNAME, 'ods-meta.xsl', charset_in);
      load_txt_builder(l_style_id, 2, 'TXT', 'mimetype', 
                       ORA_DIRNAME, 'ods-mimetype', charset_in);
      load_xml_builder(l_style_id, 3, 'XML', 'META-INF/manifest.xml', 
                       ORA_DIRNAME, 'ods-manifest.xml', charset_in);
      load_xml_builder(l_style_id, 4, 'XML', 'manifest.rdf', 
                       ORA_DIRNAME, 'ods-manifest.rdf', charset_in);
      load_xml_builder(l_style_id, 5, 'XSL', 'content.xml', 
                       ORA_DIRNAME, 'ods-content.xsl', charset_in);
      load_xml_builder(l_style_id, 6, 'XSL', 'styles.xml', 
                       ORA_DIRNAME, 'ods-styles.xsl', charset_in);
      load_xml_builder(l_style_id, 7, 'XSL', 'settings.xml', 
                       ORA_DIRNAME, 'ods-settings.xsl', charset_in);
      -- Notice `current.xml` is an empty file, therefore it's been classified
      -- as TXT.
      load_txt_builder(l_style_id, 8, 'TXT', 'Configurations2/accelerator/current.xml', 
                       ORA_DIRNAME, 'ods-current.xml', charset_in);
   end;


   procedure load_all_builders(charset_in  in varchar2) is
   begin
      load_ods_builders(charset_in);
   end;


end;
/