CREATE OR REPLACE
PACKAGE BODY tabtext AS

   SUBTYPE  oracle_data_type_t  is PLS_INTEGER; -- Type used in SYS.DBMS_TYPES package
   SUBTYPE  tab_row_t           IS VARCHAR2(32767);

   g_fs            varchar2(1) ;
   g_encl          varchar2(1) ;
   g_head_printed  BOOLEAN ;
   g_head_on       BOOLEAN NOT NULL DEFAULT true ;
   g_headings_no   headings_ntt := headings_ntt();
   g_headings      headings_ntt ;
   g_date_format   VARCHAR2(100);  --> TODO
   g_timest_format VARCHAR2(100);  --> TODO

   g_rcn                INTEGER ;   -- REF CURSOR NUMBER
   g_column_count       number;
   g_columns_metadata   dbms_sql.desc_tab3;



   PROCEDURE init IS
   BEGIN
      g_fs         := ';' ;
      g_encl       := '"' ;
      g_head_on    := true ;
      g_head_printed := false ;
      g_headings   := g_headings_no ;
      g_rcn        := NULL;
      g_column_count := NULL;
      --g_columns_metadata := NULL;
   END init;


   PROCEDURE init(fs_in   IN varchar2, encl_in   IN varchar2) IS
   BEGIN
      init;
      g_fs   := fs_in ;
      g_encl := encl_in ;
   END init;


   PROCEDURE headings_off IS
   BEGIN
      g_head_on := false ;
   END headings_off;


   PROCEDURE headings(headings_in   IN headings_ntt) IS
   BEGIN
      g_headings := headings_in ;
      g_head_on  := true ;
   END headings;


      -- Use NOCOPY and track the time needed
   PROCEDURE add_column(row_in in out VARCHAR2, col_in   VARCHAR2) IS
   
      FUNCTION enclose(val_in varchar2) return varchar2 is
      BEGIN
         if ( g_encl is null) then
            return val_in;
         end if;
         return g_encl || val_in || g_encl ;
      END enclose;
   
   BEGIN
      if ( row_in is not null ) then
         row_in := row_in || g_fs ;
      end if;
      row_in := row_in || enclose(col_in);
   END add_column;

      
   FUNCTION default_headings RETURN headings_ntt IS
      l_headings   headings_ntt := headings_ntt();
   BEGIN
      FOR i in 1 .. g_column_count LOOP
         l_headings.EXTEND;
         l_headings(i) := g_columns_metadata(i).col_name ;
      END LOOP;
      RETURN l_headings;
   END;   
   
   
   FUNCTION PRINT_HEADINGS RETURN VARCHAR2 IS
      l_row   tab_row_t;
      l_ind   headings_ind_t;
   BEGIN
      l_ind := g_headings.FIRST;
      WHILE (l_ind <= g_headings.LAST) LOOP
         add_column( l_row, g_headings(l_ind));
         l_ind := g_headings.NEXT(l_ind);
      END LOOP;
      g_head_printed := TRUE;
      RETURN l_row;
   END ;


   FUNCTION is_numeric(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_types.typecode_number);
   END is_numeric;
   
   FUNCTION is_string(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_types.typecode_char, 
                        dbms_types.typecode_varchar2, 
                        dbms_types.typecode_varchar);
   END is_string;
   
   FUNCTION is_timest(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_types.typecode_timestamp,
                        dbms_types.typecode_timestamp_tz,
                        dbms_types.typecode_timestamp_ltz);
   END is_timest;
   
   FUNCTION is_date(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_types.typecode_date);
   END is_date;
   


   /*
   || Wraps the cursor and initialize the column headings
   || using the cursor column names in case no custom headings were
   || provided and printing of headings is turned on.
   */
   PROCEDURE wrap(rc_in IN OUT sys_refcursor) IS
      l_string_value   VARCHAR2(32767);
      l_numeric_value  NUMBER;      
      l_date_value     DATE;
      l_timest_value   TIMESTAMP;
   BEGIN
      g_rcn := dbms_sql.to_cursor_number(rc_in);
      dbms_sql.describe_columns3(
         c       => g_rcn,
         col_cnt => g_column_count,
         desc_t  => g_columns_metadata
      );
      
      FOR l_col_idx IN 1 .. g_column_count LOOP
         IF is_string (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_string_value, g_columns_metadata(l_col_idx).col_max_len);
         ELSIF is_numeric (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_numeric_value); 
         ELSIF is_date (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_date_value);
         ELSIF is_timest (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_timest_value);
         ELSE
            raise_application_error(-20102, '<UNHANDLED TYPE>');
         END IF;
      END LOOP;

      if ( g_head_on AND g_headings.COUNT = 0 ) then
         g_headings := default_headings;
      end if;
   END WRAP;
   
   
   FUNCTION get_row RETURN VARCHAR2 IS
   
      l_row            tab_row_t;
      l_col_idx        INTEGER;
      l_string_value   VARCHAR2(32767);
      l_numeric_value  NUMBER;      
      l_date_value     DATE;
      l_timest_value   TIMESTAMP;
      l_fdbk           INTEGER;
   BEGIN
      IF ( g_head_on AND NOT g_head_printed) THEN
         RETURN PRINT_HEADINGS;
      END IF;
      l_fdbk := DBMS_SQL.FETCH_ROWS (g_rcn); 
      IF ( l_fdbk = 0 ) THEN
         RAISE no_data_found ;
      END IF;
      FOR l_col_idx IN 1 .. g_column_count LOOP
         IF is_string (l_col_idx) THEN
            DBMS_SQL.COLUMN_VALUE (g_rcn, l_col_idx, l_string_value);
         ELSIF is_numeric (l_col_idx) THEN
            DBMS_SQL.COLUMN_VALUE (g_rcn, l_col_idx, l_numeric_value); 
            l_string_value := TO_CHAR(l_numeric_value);
         ELSIF is_date (l_col_idx) THEN
            DBMS_SQL.COLUMN_VALUE (g_rcn, l_col_idx, l_date_value);
            l_string_value := TO_CHAR(l_date_value); --, g_date_format); 
         ELSIF is_timest (l_col_idx) THEN
            DBMS_SQL.COLUMN_VALUE (g_rcn, l_col_idx, l_timest_value);
            l_string_value := TO_CHAR(l_timest_value); --, g_timest_format); 
         ELSE
            l_string_value := '<UNHANDLED FORMAT>';
         END IF;
         add_column(l_row, l_string_value);
      END LOOP;
      RETURN l_row ;
   END get_row;
   
BEGIN
   init ;
END;