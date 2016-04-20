create or replace 
package body spreadeasy as
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

   C_SCHEMA_OWNER    CONSTANT  varchar2(30) := sys_context('userenv','current_schema');
   C_XML_VERSION     CONSTANT  varchar2(3) := '1.0';

   subtype datetime_fmt_t is VARCHAR2(30);

   SUBTYPE oracle_obj_name_t  is varchar2(30);
   
   SUBTYPE column_datatypes_aa_idx_t is VARCHAR2(32767);
   TYPE column_datatypes_aat is table oF VARCHAR2(32) INDEX BY column_datatypes_aa_idx_t;
   
   g_ss_style             style_t NOT NULL := Excel;

   g_worksheets_nt        worksheets_nt_t not null := worksheets_nt_t();
   g_active_worksheet     worksheet_idx_t;   
   g_doc_props_rec        doc_props_rt;
   
   type session_vars_aat  is table of varchar2(512) index by varchar2(30);
   
   g_session_vars         session_vars_aat;  
   
   g_start_time               timestamp;
   g_execution_time           execution_time_t;
   
   procedure inspect_session is
      l_idx  varchar2(30);
   begin
      while ( l_idx is not null ) loop
         dbms_output.put_line(l_idx||'='||g_session_vars(l_idx));
         l_idx := g_session_vars.next(l_idx);
      end loop;   
   end;
   
   procedure save_session_vars is
      type name_value_ntt  is table of v$nls_parameters%rowtype;
      l_parameters         name_value_ntt;  
      l_idx                varchar2(30);
   begin
      select p.*
      bulk collect into l_parameters
      from v$nls_parameters p ;
      
      l_idx := l_parameters.FIRST;
      while ( l_idx is not null ) loop
         g_session_vars(lower(l_parameters(l_idx).parameter)) := l_parameters(l_idx).value;
         l_idx := l_parameters.NEXT(l_idx);
      end loop;
   end;
   
   procedure alter_session(param_in varchar2, value_in varchar2) is
      l_sql_stmt   varchar2(512);
   begin
      l_sql_stmt := 'ALTER SESSION SET '||param_in||'='''||value_in||'''';
      execute immediate l_sql_stmt ;
   end;


   procedure restore_session_param(param_in varchar2) is
      l_value   varchar2(30);
   begin
      l_value := g_session_vars(lower(param_in));
      alter_session( param_in, l_value);
   exception
      when no_data_found then
         null; -- exit just doing nothing
   end;
   
   
   procedure set_excel_session_params is
   begin
      save_session_vars;
      alter_session('nls_date_format'        , 'YYYY-MM-DD"T"HH24:MI:SS".000"');
      alter_session('nls_timestamp_format'   , 'YYYY-MM-DD"T"HH24:MI:SS.FF3');
      alter_session('nls_timestamp_tz_format', 'YYYY-MM-DD"T"HH24:MI:SS.FF3');
      -- In order ALTER SESSION SET NLS_NUMERIC_CHARACTERS to take
      -- effect is VERY important to set its value BEFORE opening any cursor
      -- variable. Remember cursors are opened in `addWorksheet` procedure.
      alter_session('nls_numeric_characters' , '.,');
   end;
   
   
   procedure restore_session_params is
   begin
      restore_session_param('nls_date_format');
      restore_session_param('nls_timestamp_format');
      restore_session_param('nls_timestamp_tz_format');
      restore_session_param('nls_numeric_characters');
   end;
   
   
   function xml_safe_tag_name(tag_name_in in varchar2) 
      return varchar2 
   is
      l_ret    varchar2(32767);
      
      function escape_tag_name(aa in varchar2) return varchar2 is
         VALID_CHARS_RE  CONSTANT VARCHAR2(40) := '[a-zA-Z0-9:_.]';
         l_ret   varchar2(32767);
         l_len   PLS_INTEGER;
         l_c     char(1);
      begin
         l_len := length(aa);
         for i in 1 .. l_len loop
            l_c := substr(aa, i, 1);
            if regexp_like(l_c, VALID_CHARS_RE) then
               l_ret := l_ret || l_c ;
            else
               l_ret := l_ret || '_x'||lpad(utl_raw.cast_to_raw(l_c), 4, '0')||'_' ;
            end if;
         end loop;
         return l_ret ;
      end;
      
   begin
      select REGEXP_REPLACE( asciistr(tag_name_in), '\\([0-9A-Z]{4})','_x\1_' ) 
        into l_ret
        from dual;
      l_ret := escape_tag_name(l_ret);  
      return l_ret;
   end xml_safe_tag_name;

   
   procedure reset is
   begin
      g_worksheets_nt := worksheets_nt_t();
      g_active_worksheet := null;
      g_doc_props_rec := null;
   end;
   
   
   procedure newWorkbook(
      style_in           in style_t,
      doc_props_rec_in   in doc_props_rt
   ) is
   begin
      reset;
      set_excel_session_params;
      g_ss_style := style_in;
      g_doc_props_rec := doc_props_rec_in;
   end;
   
   
   procedure newWorkbook(
      style_in     in style_t,
      author_in    in varchar2, 
      company_in   in varchar2
   ) is
      l_doc_props_rec    doc_props_rt;
   begin
      l_doc_props_rec.author  := author_in;
      l_doc_props_rec.company := company_in;
      l_doc_props_rec.created := current_date;
      newWorkbook(style_in, l_doc_props_rec);
   end;
   
   
   procedure newODS(
      author_in    in varchar2 default user, 
      company_in   in varchar2 default ''
   ) is  
   begin
      newWorkbook(ODS, author_in, company_in);
   end;


   procedure format(style_in  in  style_t) is
   begin
      g_ss_style := style_in;
   end;
   
   
   /**
   Add a new worksheet to the spreadsheet and set it to active 
   or just do nothing if the given worksheet name is already in use.
   */
   procedure addWorksheet(
      sqlCursor_io in out sys_refcursor,
      name_in      in     worksheet_name_t DEFAULT null
   ) is
     l_worksheet_rec   worksheet_rec_t;
     l_worksheet_name  worksheet_name_t;
     i                 pls_integer ;
   begin
      begin
         l_worksheet_name := nvl(name_in, 'Worksheet '||to_char(g_worksheets_nt.COUNT+1));
         -- TODO check wheather the 'worksheet name' is already in use
         << CHECK_AGAIN >>
         i := 1;
         while ( i <= g_worksheets_nt.LAST ) loop
            if ( g_worksheets_nt(i).name = l_worksheet_name ) then 
              l_worksheet_name := l_worksheet_name||' (2)';
              goto CHECK_AGAIN;
            end if;
            i := g_worksheets_nt.NEXT(i);
         end loop;
         raise no_data_found;
      exception
         when no_data_found then
            l_worksheet_rec.name := l_worksheet_name;
            l_worksheet_rec.refcur := dbms_sql.to_cursor_number(sqlCursor_io);
            g_worksheets_nt.EXTEND;
            g_worksheets_nt(g_worksheets_nt.LAST) := l_worksheet_rec;
            g_active_worksheet := g_worksheets_nt.LAST;
      end;      
   end;
   

   procedure addWorksheet(
      sqlSelect_in in     varchar2,
      name_in      in     worksheet_name_t DEFAULT null
   ) is
      l_cur   SYS_REFCURSOR;
   begin
      open l_cur for sqlSelect_in;
      addWorksheet(l_cur, name_in);
   end;
   
   
   function getStyle return style_t is
   begin
      return g_ss_style;
   end;
   

   procedure build(dir_in  varchar2, filename_in varchar2) 
   is
      -- For ODS documents the trailing "Z" will be removed by the XSL
      EXCEL_PROP_DATETIME_FMT  CONSTANT datetime_fmt_t := 'YYYY-MM-DD"T"HH24:MI:SS"Z"';
   
      l_spreadsheet_xslt   XMLType;
      l_dataset            XMLType;
      l_ws_rec             worksheet_rec_t;
      l_ws_idx             worksheet_idx_t;  
      l_ss_id              spreadeasy_wrk.spreadsheet_id%type;
      l_xmlctx             DBMS_XMLGEN.ctxHandle;
      
      l_colname            column_datatypes_aa_idx_t;
      l_col_cnt            PLS_INTEGER;
      l_desc_tab           dbms_sql.desc_tab2;
      l_zip_content        BLOB;
      l_dummy_str          varchar2(32767);
      l_dummy_xml          XMLType;
      l_dummy_blob         BLOB;
      l_dummy_cur          SYS_REFCURSOR;
      l_dummy_col_oradt    column_datatypes_aat ; -- Oracle data types
      l_dummy_col_ssdt     column_datatypes_aat ; -- Spreadsheet data types
--      l_dummy_col_fmval    column_datatypes_aat ; -- Formatted values
      
      PRAGMA AUTONOMOUS_TRANSACTION;
      
      function fields_info_injection(
        worksheet_rec_in       in worksheet_rec_t
      , column_ora_datatypes_aa_in in column_datatypes_aat
      , column_ss_datatypes_aa_in  in column_datatypes_aat
      ) return XMLType 
      is
         l_ret   XMLType;
         l_buf   CLOB;
         
         function xslt_template(column_name_in in varchar2, oratype_in in varchar2, sstype_in varchar2) return CLOB
         is
            l_buf   CLOB;
         begin
            l_buf := to_clob('<xsl:template match="'||xml_safe_tag_name(column_name_in)||'">');
            dbms_lob.append(l_buf, to_clob('<xsl:copy><xsl:attribute name="oratype">'||oratype_in||'</xsl:attribute><xsl:attribute name="sstype">'||sstype_in||'</xsl:attribute>'));
            dbms_lob.append(l_buf, to_clob('<xsl:attribute name="column_heading">'||htf.escape_sc(column_name_in)||'</xsl:attribute>'));
            dbms_lob.append(l_buf, to_clob('<xsl:apply-templates select="node()"/></xsl:copy></xsl:template>'));
            return l_buf;
         end xslt_template;
        
      begin
         l_buf := to_clob('<?xml version="1.0" encoding="UTF-8"?>');
         dbms_lob.append(l_buf, to_clob('<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >'));
         dbms_lob.append(l_buf, to_clob('<xsl:output method="xml" indent="yes" encoding="utf-8"/>'));
         dbms_lob.append(l_buf, to_clob('<xsl:template match="/*"><xsl:copy><xsl:attribute name="worksheet_name">'||htf.escape_sc(worksheet_rec_in.name)||'</xsl:attribute><xsl:apply-templates select="node()"/></xsl:copy></xsl:template>'));
         dbms_lob.append(l_buf, to_clob('<xsl:template match="ROW"><xsl:copy><xsl:apply-templates select="node()"/></xsl:copy></xsl:template>'));
         l_colname := column_ora_datatypes_aa_in.FIRST;
         loop 
            exit when l_colname is null;
            dbms_lob.append(l_buf, xslt_template(l_colname, column_ora_datatypes_aa_in(l_colname), column_ss_datatypes_aa_in(l_colname) )); 
            l_colname := column_ora_datatypes_aa_in.NEXT(l_colname);
         end loop;
         dbms_lob.append(l_buf, to_clob('</xsl:stylesheet>'));

         select xmltype(l_buf) into l_ret from dual;
         return l_ret;
      end fields_info_injection;


      procedure gen_xml_fragment(
         spreadsheet_id  in spreadeasy_wrk.spreadsheet_id%type, 
         fragment_id     in spreadeasy_wrk.worksheet_id%type, 
         context_in      in DBMS_XMLGEN.ctxHandle,
         xslt_in         in XMLType default null
      ) is 
      begin
         if ( xslt_in is null ) then
            INSERT INTO spreadeasy_wrk
            SELECT spreadsheet_id, fragment_id, dbms_xmlgen.getxmltype(context_in)
              FROM dual;
         else
            INSERT INTO spreadeasy_wrk
            SELECT spreadsheet_id, fragment_id, XMLtransform(dbms_xmlgen.getxmltype(context_in), xslt_in)
              FROM dual;
         end if;  
      end;
      
      function dbms_sql2ora_type(oradt_in in binary_integer) return varchar2 is
        l_ret   varchar2(50);
      begin
        case oradt_in
          when dbms_sql.varchar2_type          then l_ret := 'VARCHAR2';
          when dbms_sql.number_type            then l_ret := 'NUMBER';
          when dbms_sql.long_type              then l_ret := 'LONG';
          when dbms_sql.rowid_type             then l_ret := 'ROWID';
          when dbms_sql.date_type              then l_ret := 'DATE';
          when dbms_sql.raw_type               then l_ret := 'RAW';
          when dbms_sql.long_raw_type          then l_ret := 'LONG RAW';
          when dbms_sql.char_type              then l_ret := 'CHAR';
          when dbms_sql.binary_float_type      then l_ret := 'BINARY FLOAT';
          when dbms_sql.binary_double_type     then l_ret := 'BINARY DOUBLE';
          when dbms_sql.MLSLabel_type          then l_ret := 'MLSLABEL';
          when dbms_sql.User_Defined_type      then l_ret := 'USER DEFINED';
          when dbms_sql.Ref_type               then l_ret := 'REF';
          when dbms_sql.clob_type              then l_ret := 'CLOB';
          when dbms_sql.blob_type              then l_ret := 'BLOB';
          when dbms_sql.bfile_type             then l_ret := 'BFILE';
          when dbms_sql.Timestamp_Type         then l_ret := 'TIMESTAMP';
          when dbms_sql.Timestamp_With_TZ_Type then l_ret := 'TIMESTAMP WITH TIME ZONE';
          when dbms_sql.Timestamp_With_Local_TZ_Type then l_ret := 'TIMESTAMP WITH LOCAL TIME ZONE';
          when dbms_sql.Interval_Year_To_Month_Type then l_ret := 'INTERVAL YEAR TO MONTH';
          when dbms_sql.Interval_Day_To_Second_Type then l_ret := 'INTERVAL DAY TO SECOND';
          when dbms_sql.urowid_type            then l_ret := 'UROWID';
          when dbms_sql.binary_bouble_type     then l_ret := 'BINARY BOUBLE';
          else
            l_ret := '#UNHANDLED#';
        end case;  
        return l_ret;
      end dbms_sql2ora_type;
      

      function dbms_sql2spreadsheet_type(oradt_in in binary_integer) return varchar2 is
        l_ret   varchar2(50);
      begin
        case oradt_in
          when dbms_sql.number_type            then l_ret := 'Numeric';
          when dbms_sql.binary_float_type      then l_ret := 'Numeric';
          when dbms_sql.binary_double_type     then l_ret := 'Numeric';
          when dbms_sql.date_type              then l_ret := 'DateTime';
          when dbms_sql.Timestamp_Type         then l_ret := 'DateTime';
          when dbms_sql.Timestamp_With_TZ_Type then l_ret := 'DateTime';
          when dbms_sql.Timestamp_With_Local_TZ_Type then l_ret := 'DateTime';
          else
            l_ret := 'String';
        end case;  
        return l_ret;
      end dbms_sql2spreadsheet_type;
      
      
      procedure cleanup_this_routine is
      begin
         rollback; -- Notice this routine starts an AUTONOMOUS TRANSACTION !
         dbms_lob.freetemporary( l_zip_content );        
         restore_session_params;
      end cleanup_this_routine;


      function clob2blob(clob_in  IN  CLOB CHARACTER SET ANY_CS) return BLOB is
         the_blob         BLOB;
         l_dest_offset    INTEGER := 1;
         l_src_offset     INTEGER := 1;
         l_lang_ctxt      INTEGER := 0;
         l_warn           INTEGER ;
      begin
         DBMS_LOB.CREATETEMPORARY(the_blob, TRUE);
         if DBMS_LOB.GETLENGTH(clob_in) > 0 then
           DBMS_LOB.CONVERTTOBLOB(
              the_blob,
              clob_in,
              DBMS_LOB.getLength(clob_in),
              l_dest_offset,
              l_src_offset, 
              NLS_CHARSET_ID(C_BUILDERS_CHARSET),
              l_lang_ctxt,
              l_warn
           );
         end if;
         RETURN the_blob;
      end;
      
   begin
      g_start_time := systimestamp ;

-- =============================================================================
-- First phase: building the XML dataset from the cursors
-- =============================================================================

      if ( g_worksheets_nt.COUNT = 0 ) then
         return;
      end if;
      
      SELECT spreadeasy_spreadsheet_wrk_seq.NEXTVAL INTO l_ss_id FROM dual;
      
      open l_dummy_cur for
      Select g_doc_props_rec.author as "Author",
             g_doc_props_rec.author as "LastAuthor",
             to_char(g_doc_props_rec.created, EXCEL_PROP_DATETIME_FMT) as "Created",
             to_char(g_doc_props_rec.created, EXCEL_PROP_DATETIME_FMT) as "LastSaved",
             g_doc_props_rec.company as "Company",
             1 as "Version",
             C_GENERATOR as "Generator"
        from dual;
      
      l_xmlctx := DBMS_XMLGEN.newContext(l_dummy_cur);
      gen_xml_fragment(l_ss_id, 0, l_xmlctx);
      DBMS_XMLGEN.CLOSECONTEXT(l_xmlctx);
      close l_dummy_cur;
      
      l_ws_idx := g_worksheets_nt.FIRST;
      while ( l_ws_idx <= g_worksheets_nt.LAST ) 
      loop
         l_ws_rec := g_worksheets_nt(l_ws_idx) ;
         
         dbms_sql.describe_columns2(c => l_ws_rec.refcur, col_cnt => l_col_cnt, desc_t => l_desc_tab);   
         for i in 1 .. l_col_cnt loop
            l_dummy_col_oradt(l_desc_tab(i).col_name) := dbms_sql2ora_type(l_desc_tab(i).col_type);
            l_dummy_col_ssdt (l_desc_tab(i).col_name) := dbms_sql2spreadsheet_type(l_desc_tab(i).col_type);
--            l_dummy_col_fmval(l_desc_tab(i).col_name) := dbms_sql2formatted_values(l_desc_tab(i).col_type);
         end loop;
         l_dummy_xml := fields_info_injection(l_ws_rec, l_dummy_col_oradt, l_dummy_col_ssdt);
               
         l_dummy_cur := dbms_sql.to_refcursor(l_ws_rec.refcur);
         l_xmlctx := DBMS_XMLGEN.newContext(l_dummy_cur);
         gen_xml_fragment(l_ss_id, l_ws_idx, l_xmlctx, l_dummy_xml);
         DBMS_XMLGEN.CLOSECONTEXT(l_xmlctx);
         close l_dummy_cur;  
         
         l_ws_idx := g_worksheets_nt.NEXT(l_ws_idx);
      end loop;


      select XMLRoot(XMLELEMENT("SPREADSHEET", XMLAGG(document)), VERSION C_XML_VERSION) as xml
        into l_dataset
        from spreadeasy_wrk
       where spreadsheet_id = l_ss_id
       order by worksheet_id;

-- =============================================================================
-- Second phase: building the Spreadsheet starting from the XML dataset
-- =============================================================================
      for builder_rec in (select * 
                            from spreadeasy_builders b 
                           where b.style_id = getStyle
                           order by b.step ) 
      loop
         case builder_rec.builder_type
            when 'TXT' then
               as_zip.add1file( l_zip_content, builder_rec.out_path, clob2blob(builder_rec.builder_doc));
            when 'XML' then
               select xmlserialize(document builder_rec.xml_doc  as blob no indent) as aBlob
                 into l_dummy_blob
                 from dual;
               as_zip.add1file( l_zip_content, builder_rec.out_path, l_dummy_blob);
            when 'XSL' then
               select xmlserialize(document XMLtransform(l_dataset, builder_rec.xml_doc)  as blob no indent) as aBlob
                 into l_dummy_blob
                 from dual;
               if l_dummy_blob is null then
                 raise_application_error(-20001, 'XSLT gave a NULL object for '||builder_rec.out_path||'. Check the XSL document.');
               end if;
               as_zip.add1file( l_zip_content, builder_rec.out_path, l_dummy_blob );
         end case;
      end loop;
      
      as_zip.finish_zip( l_zip_content );
      as_zip.save_zip( l_zip_content, dir_in, filename_in );
      cleanup_this_routine;
      g_execution_time := systimestamp - g_start_time;
   exception
      when others then
         cleanup_this_routine;
         raise;
   end;

   
   function getStartTime return timestamp is
   begin
      return g_start_time;
   end;
   
   
   function getExecutionTime return execution_time_t is
   begin
      return g_execution_time;
   end;
   

end;
/