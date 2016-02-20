create or replace 
package body spreadeasy as

   subtype datetime_fmt_t is VARCHAR2(30);

   SUBTYPE oracle_obj_name_t  is varchar2(30);
   
   SUBTYPE column_datatypes_aa_idx_t is VARCHAR2(32767);
   TYPE column_datatypes_aat is table oF VARCHAR2(32) INDEX BY column_datatypes_aa_idx_t;
   
   g_ss_style             style_t := Excel;

   g_worksheets_nt        worksheets_nt_t not null := worksheets_nt_t();
   g_active_worksheet     worksheet_idx_t;   
   g_spreadsheet          XMLType;
   g_doc_props_rec        doc_props_rt;
   
   type session_vars_aat  is table of varchar2(512) index by varchar2(30);
   
   g_session_vars    session_vars_aat;  
   
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
      l_sql_stmt := 'ALTER SESSION SET '||param_in||' = '''||value_in||'''';
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
      alter_session('nls_numeric_characters' , '.,');
      alter_session('nls_date_format'        , 'YYYY-MM-DD"T"HH24:MI:SS".000"');
      alter_session('nls_timestamp_format'   , 'YYYY-MM-DD"T"HH24:MI:SS.FF3');
      alter_session('nls_timestamp_tz_format', 'YYYY-MM-DD"T"HH24:MI:SS.FF3');
   end;
   
   
   procedure restore_excel_session_params is
   begin
      restore_session_param('nls_numeric_characters');
      restore_session_param('nls_date_format');
      restore_session_param('nls_timestamp_format');
      restore_session_param('nls_timestamp_tz_format');
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
   /*
   procedure cleanup_ctx is
      l_ws_idx    worksheet_idx_t;  
   begin
      if ( g_worksheets_nt.COUNT = 0 ) then
         return;
      end if;
      l_ws_idx := g_worksheets_nt.FIRST;
      while ( l_ws_idx <= g_worksheets_nt.LAST ) 
      loop
         DBMS_SQL.CLOSE(g_worksheets_nt(l_ws_idx).refcur);
         l_ws_idx := g_worksheets_nt.NEXT(l_ws_idx);
      end loop;
   end;*/
   
   procedure reset is
   begin
      restore_excel_session_params;
      g_worksheets_nt := worksheets_nt_t();
      g_active_worksheet := null;
      g_spreadsheet := null;
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
      l_doc_props_rec.created := sysdate;
      newWorkbook(style_in, l_doc_props_rec);
   end;
   
   
   procedure newExcel(
      author_in    in varchar2 default user, 
      company_in   in varchar2 default ''
   ) is  
   begin
      newWorkbook(Excel, author_in, company_in);
   end;


   function get_style_xslt(style_in  in  style_t) return XMLType 
   is
      l_dburi    varchar2(512);
   begin
      l_dburi := '/'||USER||'/SPREADEASY_STYLES/ROW[STYLE_ID="'||style_in||'"]/DOCUMENT/text()';
      return DBURIType(l_dburi).getXML(l_dburi);
   end;


   procedure format(style_in  in  style_t) is
   begin
      g_ss_style := style_in;
   end;
   
   
   /**
   Add a new worksheet to the spreadsheet and set it to active 
   or just do nothing if the given worksheet name is already in use.
   */
   procedure newWorksheet(
      name_in      in     worksheet_name_t,
      sqlCursor_io in out sys_refcursor
   ) is
     l_worksheet_rec   worksheet_rec_t;
   begin
      begin
         -- TODO check wheather the 'worksheet name' is already in use
         raise no_data_found;
      exception
         when no_data_found then
            l_worksheet_rec.name := name_in;
--            l_worksheet_rec.refcur := sqlCursor_in;
            l_worksheet_rec.refcur := dbms_sql.to_cursor_number(sqlCursor_io);
            g_worksheets_nt.EXTEND;
            g_worksheets_nt(g_worksheets_nt.LAST) := l_worksheet_rec;
            g_active_worksheet := g_worksheets_nt.LAST;
      end;      
   end;
   

   procedure newWorksheet(
      name_in      in worksheet_name_t,
      sqlSelect_in in varchar2
   ) is
      l_cur   SYS_REFCURSOR;
   begin
      open l_cur for sqlSelect_in;
      newWorksheet(name_in, l_cur);
   end;
   
   
   function getStyle return style_t is
   begin
      return g_ss_style;
   end;
   

   procedure build 
   is
   
      EXCEL_PROP_DATETIME_FMT  CONSTANT datetime_fmt_t := 'YYYY-MM-DD"T"HH24:MI:SS"Z"';
   
      l_spreadsheet_xslt   XMLType;
      l_datatype_xslt      XMLType;
      l_ws_rec             worksheet_rec_t;
      l_ws_idx             worksheet_idx_t;  
      l_ss_id              spreadeasy_wrk.spreadsheet_id%type;
      l_dummy_cur          SYS_REFCURSOR;
      l_xmlctx             DBMS_XMLGEN.ctxHandle;
      
      l_colname            column_datatypes_aa_idx_t;
      l_dummy_coldt        column_datatypes_aat ;
      l_col_cnt            PLS_INTEGER;
      l_desc_tab           dbms_sql.desc_tab2;
      
      PRAGMA AUTONOMOUS_TRANSACTION;
      
      function datatype_injection(
        column_datatypes_aa_in in column_datatypes_aat
      ) return XMLType 
      is
         l_ret   XMLType;
         l_buf   CLOB;
         
         function xslt_template(column_name_in in varchar2, type_in in varchar2) return CLOB
         is
         begin
            return to_clob('<xsl:template match="'||column_name_in||'"><xsl:copy><xsl:attribute name="type">'||type_in||'</xsl:attribute><xsl:apply-templates select="node()"/></xsl:copy></xsl:template>');
         end xslt_template;
        
      begin
         l_buf := to_clob('<?xml version="1.0" encoding="UTF-8"?>');
         dbms_lob.append(l_buf, to_clob('<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >'));
         dbms_lob.append(l_buf, to_clob('<xsl:template match="/*"><xsl:copy><xsl:apply-templates select="node()"/></xsl:copy></xsl:template>'));
         dbms_lob.append(l_buf, to_clob('<xsl:template match="ROW"><xsl:copy><xsl:apply-templates select="node()"/></xsl:copy></xsl:template>'));
         dbms_lob.append(l_buf, to_clob('<xsl:template match="*/ROW[position()=1]/*"><xsl:copy><xsl:apply-templates select="node()"/></xsl:copy></xsl:template>'));
         l_colname := column_datatypes_aa_in.FIRST;
         loop 
            exit when l_colname is null;
            dbms_lob.append(l_buf, xslt_template(xml_safe_tag_name(l_colname), column_datatypes_aa_in(l_colname))); 
            l_colname := column_datatypes_aa_in.NEXT(l_colname);
         end loop;
         dbms_lob.append(l_buf, to_clob('</xsl:stylesheet>'));

         select xmltype(l_buf) into l_ret from dual;
         return l_ret;
      end datatype_injection;


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
      
      function dbms_sql2excel_type(oradt_in in binary_integer) return varchar2 is
        l_ret   varchar2(50);
      begin
        case oradt_in
          when dbms_sql.number_type            then l_ret := 'Number';
          when dbms_sql.binary_float_type      then l_ret := 'Number';
          when dbms_sql.binary_double_type     then l_ret := 'Number';
          when dbms_sql.date_type              then l_ret := 'DateTime';
          when dbms_sql.Timestamp_Type         then l_ret := 'DateTime';
          when dbms_sql.Timestamp_With_TZ_Type then l_ret := 'DateTime';
          when dbms_sql.Timestamp_With_Local_TZ_Type then l_ret := 'DateTime';
          else
            l_ret := 'String';
        end case;  
        return l_ret;
      end dbms_sql2excel_type;
      

      procedure cleanup_this_routine is
      begin
         rollback; -- Notice this routine starts an AUTONOMOUS TRANSACTION !
         restore_excel_session_params;
      end cleanup_this_routine;

      
   begin
      if ( g_worksheets_nt.COUNT = 0 ) then
         return;
      end if;
      
      SELECT spreadeasy_spreadsheet_seq.NEXTVAL INTO l_ss_id FROM dual;
      
      open l_dummy_cur for
      Select g_doc_props_rec.author as "Author",
             g_doc_props_rec.author as "LastAuthor",
             to_char(g_doc_props_rec.created, EXCEL_PROP_DATETIME_FMT) as "Created",
             to_char(g_doc_props_rec.created, EXCEL_PROP_DATETIME_FMT) as "LastSaved",
             g_doc_props_rec.company as "Company",
             1 as "Version"
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
            l_dummy_coldt(l_desc_tab(i).col_name) := dbms_sql2excel_type(l_desc_tab(i).col_type);
         end loop;
         l_datatype_xslt := datatype_injection(l_dummy_coldt);
      
         l_dummy_cur := dbms_sql.to_refcursor(l_ws_rec.refcur);
         l_xmlctx := DBMS_XMLGEN.newContext(l_dummy_cur);
         DBMS_XMLGEN.SETROWSETTAG(l_xmlctx, l_ws_rec.name);         
         gen_xml_fragment(l_ss_id, l_ws_idx, l_xmlctx, l_datatype_xslt);
         DBMS_XMLGEN.CLOSECONTEXT(l_xmlctx);
         close l_dummy_cur;  
         
         l_ws_idx := g_worksheets_nt.NEXT(l_ws_idx);
      end loop;

      l_spreadsheet_xslt := get_style_xslt(g_ss_style);

      select XMLtransform( 
           XMLELEMENT("SPREADSHEET", XMLAGG(rowset))
           , l_spreadsheet_xslt) 
           as xml
        into g_spreadsheet 
        from spreadeasy_wrk
       where spreadsheet_id = l_ss_id
       order by worksheet_id;
        
      cleanup_this_routine;
   exception
      when others then
         cleanup_this_routine;
         raise;
   end;


   function getAsXMLType return XMLType is
   begin
      return g_spreadsheet;
   end;
   
   
   function getAsCLOB return CLOB is
   begin
      return g_spreadsheet.getCLOBVal();
   end;
   

end;
/