CREATE OR REPLACE
PACKAGE BODY tabtext AS
/**
___________     ___.         .__                 ___________              __   
\__    ___/____ \_ |__  __ __|  | _____ _______  \__    ___/___ ___  ____/  |_ 
  |    |  \__  \ | __ \|  |  \  | \__  \\_  __ \   |    |_/ __ \\  \/  /\   __\
  |    |   / __ \| \_\ \  |  /  |__/ __ \|  | \/   |    |\  ___/ >    <  |  |  
  |____|  (____  /___  /____/|____(____  /__|      |____| \___  >__/\_ \ |__|  
               \/    \/                \/                     \/      \/                                
               
  a software by Massimo Pasquini                                    vers. 0.0.3
  
  License                                                    Apache version 2.0                        
  Last update                                                       2016-Jan-16
  
  Project homepage                          https://github.com/maxpsq/ora-tools
  
 */

   SUBTYPE oracle_data_type_t IS PLS_INTEGER; -- Type used in SYS.DBMS_TYPES package
   SUBTYPE refcursor_number_t IS INTEGER;
   SUBTYPE refcursor_column_t IS PLS_INTEGER;
   SUBTYPE tab_row_t          IS varchar2_max_t;

   g_sepval                   boolean not null := true;
   g_fs                       varchar2(1) ;
   g_encl                     varchar2(1) ;
   g_esc                      varchar2(1) ;
   g_head_printed             BOOLEAN ;
   g_head_on                  BOOLEAN NOT NULL DEFAULT true ;
   g_headings                 headings_ntt ;

   g_rcn                      refcursor_number_t;
   g_column_count             number;
   g_columns_metadata_empty   dbms_sql.desc_tab3;
   g_columns_metadata         dbms_sql.desc_tab3;


   PROCEDURE RAISE_NO_CURSOR IS
   BEGIN
     RAISE_APPLICATION_ERROR(NO_CURSOR_EC, 'No cursor provided', true) ;
   END;
   
   
   PROCEDURE reset_cursor IS
   BEGIN
      g_rcn              := NULL;
      g_column_count     := NULL;
      g_columns_metadata := g_columns_metadata_empty;
   END reset_cursor;


   PROCEDURE csv(
      fs_in     IN varchar2 default ',', 
      encl_in   IN varchar2 default '"', 
      esc_in    IN varchar2 default '\'
   ) IS
   BEGIN
      g_fs         := fs_in ;
      g_encl       := encl_in ;
      g_esc        := esc_in ;
      g_sepval     := true;
      g_head_on    := true;
      g_head_printed := false;
      g_headings   := headings_ntt() ;
      reset_cursor ;
   END csv;


   PROCEDURE tsv IS
   BEGIN
      csv(chr(9), '', '');
   END tsv;


   PROCEDURE fixed_size IS
   BEGIN
      csv('', '', '');
      g_sepval := false;
   END fixed_size;


   PROCEDURE headings_off IS
   BEGIN
      g_head_on := false ;
   END headings_off;


   PROCEDURE headings(headings_in   IN headings_ntt) IS
   BEGIN
      g_headings := headings_in ;
      g_head_on  := true ;
   END headings;


   FUNCTION is_numeric(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_sql.number_type,
                        dbms_sql.binary_float_type,
                        dbms_sql.binary_double_type);
   END is_numeric;
   
   FUNCTION is_string(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_sql.char_type, 
                        dbms_sql.clob_type, 
                        dbms_sql.varchar2_type);
   END is_string;
/*   
   FUNCTION is_nstring(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_types.typecode_nchar, 
                        dbms_types.typecode_nclob, 
                        dbms_types.typecode_nvarchar2);
   END is_nstring;
*/   
   FUNCTION is_timest(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type = dbms_sql.timestamp_type ;
   END is_timest;
   
   FUNCTION is_timest_tz(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type = dbms_sql.timestamp_with_tz_type;
   END is_timest_tz;
   
   FUNCTION is_timest_ltz(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type = dbms_sql.timestamp_with_local_tz_type;
   END is_timest_ltz;
   
   FUNCTION is_date(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_sql.date_type);
   END is_date;
   
   FUNCTION is_interval_ds(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_sql.interval_day_to_second_type);
   END is_interval_ds;
   
   FUNCTION is_interval_ym(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_sql.interval_year_to_month_type);
   END is_interval_ym;
   
   FUNCTION is_rowid(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_sql.rowid_type);
   END is_rowid;
   
   FUNCTION is_urowid(idx_in INTEGER) RETURN BOOLEAN IS
      l_type  oracle_data_type_t;
   BEGIN
      l_type := g_columns_metadata(idx_in).col_type;
      RETURN l_type IN (dbms_sql.urowid_type);
   END is_urowid;
   

   function number_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_num   NUMBER;
   begin
      DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_num);
      RETURN TO_CHAR(l_num);
   end number_as_str;


   function date_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_date   DATE;
   begin
      DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_date);
      RETURN TO_CHAR(l_date);
   end date_as_str;


   function timestamp_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_ts0_val    TIMESTAMP(0);
      l_ts1_val    TIMESTAMP(1);
      l_ts2_val    TIMESTAMP(2);
      l_ts3_val    TIMESTAMP(3);
      l_ts4_val    TIMESTAMP(4);
      l_ts5_val    TIMESTAMP(5);
      l_ts6_val    TIMESTAMP(6);
      l_ts7_val    TIMESTAMP(7);
      l_ts8_val    TIMESTAMP(8);
      l_ts9_val    TIMESTAMP(9);
      l_str        varchar2_max_t;
   begin
      case g_columns_metadata(col_in).col_scale
         when 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts0_val);
           l_str := TO_CHAR(l_ts0_val);
         when 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts1_val);
           l_str := TO_CHAR(l_ts1_val);
         when 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts2_val);
           l_str := TO_CHAR(l_ts2_val);
         when 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts3_val);
           l_str := TO_CHAR(l_ts3_val);
         when 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts4_val);
           l_str := TO_CHAR(l_ts4_val);
         when 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts5_val);
           l_str := TO_CHAR(l_ts5_val);
         when 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts6_val);
           l_str := TO_CHAR(l_ts6_val);
         when 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts7_val);
           l_str := TO_CHAR(l_ts7_val);
         when 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts8_val);
           l_str := TO_CHAR(l_ts8_val);
         when 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts9_val);
           l_str := TO_CHAR(l_ts9_val);
      end case;
      return l_str ;
   end timestamp_as_str;


   function timestamp_tz_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_ts0_val    TIMESTAMP(0) WITH TIME ZONE ;
      l_ts1_val    TIMESTAMP(1) WITH TIME ZONE ;
      l_ts2_val    TIMESTAMP(2) WITH TIME ZONE ;
      l_ts3_val    TIMESTAMP(3) WITH TIME ZONE ;
      l_ts4_val    TIMESTAMP(4) WITH TIME ZONE ;
      l_ts5_val    TIMESTAMP(5) WITH TIME ZONE ;
      l_ts6_val    TIMESTAMP(6) WITH TIME ZONE ;
      l_ts7_val    TIMESTAMP(7) WITH TIME ZONE ;
      l_ts8_val    TIMESTAMP(8) WITH TIME ZONE ;
      l_ts9_val    TIMESTAMP(9) WITH TIME ZONE ;
      l_str        varchar2_max_t;
   begin
      case g_columns_metadata(col_in).col_scale
         when 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts0_val);
           l_str := TO_CHAR(l_ts0_val);
         when 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts1_val);
           l_str := TO_CHAR(l_ts1_val);
         when 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts2_val);
           l_str := TO_CHAR(l_ts2_val);
         when 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts3_val);
           l_str := TO_CHAR(l_ts3_val);
         when 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts4_val);
           l_str := TO_CHAR(l_ts4_val);
         when 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts5_val);
           l_str := TO_CHAR(l_ts5_val);
         when 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts6_val);
           l_str := TO_CHAR(l_ts6_val);
         when 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts7_val);
           l_str := TO_CHAR(l_ts7_val);
         when 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts8_val);
           l_str := TO_CHAR(l_ts8_val);
         when 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts9_val);
           l_str := TO_CHAR(l_ts9_val);
      end case;
      return l_str ;
   end timestamp_tz_as_str;


   function timestamp_ltz_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_ts0_val    TIMESTAMP(0) WITH LOCAL TIME ZONE ;
      l_ts1_val    TIMESTAMP(1) WITH LOCAL TIME ZONE ;
      l_ts2_val    TIMESTAMP(2) WITH LOCAL TIME ZONE ;
      l_ts3_val    TIMESTAMP(3) WITH LOCAL TIME ZONE ;
      l_ts4_val    TIMESTAMP(4) WITH LOCAL TIME ZONE ;
      l_ts5_val    TIMESTAMP(5) WITH LOCAL TIME ZONE ;
      l_ts6_val    TIMESTAMP(6) WITH LOCAL TIME ZONE ;
      l_ts7_val    TIMESTAMP(7) WITH LOCAL TIME ZONE ;
      l_ts8_val    TIMESTAMP(8) WITH LOCAL TIME ZONE ;
      l_ts9_val    TIMESTAMP(9) WITH LOCAL TIME ZONE ;
      l_str        varchar2_max_t;
   begin
      case g_columns_metadata(col_in).col_scale
         when 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts0_val);
           l_str := TO_CHAR(l_ts0_val);
         when 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts1_val);
           l_str := TO_CHAR(l_ts1_val);
         when 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts2_val);
           l_str := TO_CHAR(l_ts2_val);
         when 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts3_val);
           l_str := TO_CHAR(l_ts3_val);
         when 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts4_val);
           l_str := TO_CHAR(l_ts4_val);
         when 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts5_val);
           l_str := TO_CHAR(l_ts5_val);
         when 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts6_val);
           l_str := TO_CHAR(l_ts6_val);
         when 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts7_val);
           l_str := TO_CHAR(l_ts7_val);
         when 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts8_val);
           l_str := TO_CHAR(l_ts8_val);
         when 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ts9_val);
           l_str := TO_CHAR(l_ts9_val);
      end case;
      return l_str ;
   end timestamp_ltz_as_str;


   function intervalym_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_ym0_val    INTERVAL YEAR(0) TO MONTH;
      l_ym1_val    INTERVAL YEAR(1) TO MONTH;
      l_ym2_val    INTERVAL YEAR(2) TO MONTH;
      l_ym3_val    INTERVAL YEAR(3) TO MONTH;
      l_ym4_val    INTERVAL YEAR(4) TO MONTH;
      l_ym5_val    INTERVAL YEAR(5) TO MONTH;
      l_ym6_val    INTERVAL YEAR(6) TO MONTH;
      l_ym7_val    INTERVAL YEAR(7) TO MONTH;
      l_ym8_val    INTERVAL YEAR(8) TO MONTH;
      l_ym9_val    INTERVAL YEAR(9) TO MONTH;
      l_p          NATURAL;
      l_str        varchar2_max_t;
   begin
      l_p := g_columns_metadata(col_in).col_precision;
      case l_p
         when 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym0_val);
           l_str := TO_CHAR(l_ym0_val);
         when 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym1_val);
           l_str := TO_CHAR(l_ym1_val);
         when 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym2_val);
           l_str := TO_CHAR(l_ym2_val);
         when 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym3_val);
           l_str := TO_CHAR(l_ym3_val);
         when 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym4_val);
           l_str := TO_CHAR(l_ym4_val);
         when 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym5_val);
           l_str := TO_CHAR(l_ym5_val);
         when 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym6_val);
           l_str := TO_CHAR(l_ym6_val);
         when 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym7_val);
           l_str := TO_CHAR(l_ym7_val);
         when 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym8_val);
           l_str := TO_CHAR(l_ym8_val);
         when 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ym9_val);
           l_str := TO_CHAR(l_ym9_val);
         else
           raise_application_error(-20104, 'Unandled precision='||l_p);
      end case;
      return l_str ;
   end intervalym_as_str;


   function intervalds_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_ds0_0_val  INTERVAL DAY(0) TO SECOND(0);
      l_ds0_1_val  INTERVAL DAY(0) TO SECOND(1);
      l_ds0_2_val  INTERVAL DAY(0) TO SECOND(2);
      l_ds0_3_val  INTERVAL DAY(0) TO SECOND(3);
      l_ds0_4_val  INTERVAL DAY(0) TO SECOND(4);
      l_ds0_5_val  INTERVAL DAY(0) TO SECOND(5);
      l_ds0_6_val  INTERVAL DAY(0) TO SECOND(6);
      l_ds0_7_val  INTERVAL DAY(0) TO SECOND(7);
      l_ds0_8_val  INTERVAL DAY(0) TO SECOND(8);
      l_ds0_9_val  INTERVAL DAY(0) TO SECOND(9);
      l_ds1_0_val  INTERVAL DAY(1) TO SECOND(0);
      l_ds1_1_val  INTERVAL DAY(1) TO SECOND(1);
      l_ds1_2_val  INTERVAL DAY(1) TO SECOND(2);
      l_ds1_3_val  INTERVAL DAY(1) TO SECOND(3);
      l_ds1_4_val  INTERVAL DAY(1) TO SECOND(4);
      l_ds1_5_val  INTERVAL DAY(1) TO SECOND(5);
      l_ds1_6_val  INTERVAL DAY(1) TO SECOND(6);
      l_ds1_7_val  INTERVAL DAY(1) TO SECOND(7);
      l_ds1_8_val  INTERVAL DAY(1) TO SECOND(8);
      l_ds1_9_val  INTERVAL DAY(1) TO SECOND(9);
      l_ds2_0_val  INTERVAL DAY(2) TO SECOND(0);
      l_ds2_1_val  INTERVAL DAY(2) TO SECOND(1);
      l_ds2_2_val  INTERVAL DAY(2) TO SECOND(2);
      l_ds2_3_val  INTERVAL DAY(2) TO SECOND(3);
      l_ds2_4_val  INTERVAL DAY(2) TO SECOND(4);
      l_ds2_5_val  INTERVAL DAY(2) TO SECOND(5);
      l_ds2_6_val  INTERVAL DAY(2) TO SECOND(6);
      l_ds2_7_val  INTERVAL DAY(2) TO SECOND(7);
      l_ds2_8_val  INTERVAL DAY(2) TO SECOND(8);
      l_ds2_9_val  INTERVAL DAY(2) TO SECOND(9);
      l_ds3_0_val  INTERVAL DAY(3) TO SECOND(0);
      l_ds3_1_val  INTERVAL DAY(3) TO SECOND(1);
      l_ds3_2_val  INTERVAL DAY(3) TO SECOND(2);
      l_ds3_3_val  INTERVAL DAY(3) TO SECOND(3);
      l_ds3_4_val  INTERVAL DAY(3) TO SECOND(4);
      l_ds3_5_val  INTERVAL DAY(3) TO SECOND(5);
      l_ds3_6_val  INTERVAL DAY(3) TO SECOND(6);
      l_ds3_7_val  INTERVAL DAY(3) TO SECOND(7);
      l_ds3_8_val  INTERVAL DAY(3) TO SECOND(8);
      l_ds3_9_val  INTERVAL DAY(3) TO SECOND(9);
      l_ds4_0_val  INTERVAL DAY(4) TO SECOND(0);
      l_ds4_1_val  INTERVAL DAY(4) TO SECOND(1);
      l_ds4_2_val  INTERVAL DAY(4) TO SECOND(2);
      l_ds4_3_val  INTERVAL DAY(4) TO SECOND(3);
      l_ds4_4_val  INTERVAL DAY(4) TO SECOND(4);
      l_ds4_5_val  INTERVAL DAY(4) TO SECOND(5);
      l_ds4_6_val  INTERVAL DAY(4) TO SECOND(6);
      l_ds4_7_val  INTERVAL DAY(4) TO SECOND(7);
      l_ds4_8_val  INTERVAL DAY(4) TO SECOND(8);
      l_ds4_9_val  INTERVAL DAY(4) TO SECOND(9);
      l_ds5_0_val  INTERVAL DAY(5) TO SECOND(0);
      l_ds5_1_val  INTERVAL DAY(5) TO SECOND(1);
      l_ds5_2_val  INTERVAL DAY(5) TO SECOND(2);
      l_ds5_3_val  INTERVAL DAY(5) TO SECOND(3);
      l_ds5_4_val  INTERVAL DAY(5) TO SECOND(4);
      l_ds5_5_val  INTERVAL DAY(5) TO SECOND(5);
      l_ds5_6_val  INTERVAL DAY(5) TO SECOND(6);
      l_ds5_7_val  INTERVAL DAY(5) TO SECOND(7);
      l_ds5_8_val  INTERVAL DAY(5) TO SECOND(8);
      l_ds5_9_val  INTERVAL DAY(5) TO SECOND(9);
      l_ds6_0_val  INTERVAL DAY(6) TO SECOND(0);
      l_ds6_1_val  INTERVAL DAY(6) TO SECOND(1);
      l_ds6_2_val  INTERVAL DAY(6) TO SECOND(2);
      l_ds6_3_val  INTERVAL DAY(6) TO SECOND(3);
      l_ds6_4_val  INTERVAL DAY(6) TO SECOND(4);
      l_ds6_5_val  INTERVAL DAY(6) TO SECOND(5);
      l_ds6_6_val  INTERVAL DAY(6) TO SECOND(6);
      l_ds6_7_val  INTERVAL DAY(6) TO SECOND(7);
      l_ds6_8_val  INTERVAL DAY(6) TO SECOND(8);
      l_ds6_9_val  INTERVAL DAY(6) TO SECOND(9);
      l_ds7_0_val  INTERVAL DAY(7) TO SECOND(0);
      l_ds7_1_val  INTERVAL DAY(7) TO SECOND(1);
      l_ds7_2_val  INTERVAL DAY(7) TO SECOND(2);
      l_ds7_3_val  INTERVAL DAY(7) TO SECOND(3);
      l_ds7_4_val  INTERVAL DAY(7) TO SECOND(4);
      l_ds7_5_val  INTERVAL DAY(7) TO SECOND(5);
      l_ds7_6_val  INTERVAL DAY(7) TO SECOND(6);
      l_ds7_7_val  INTERVAL DAY(7) TO SECOND(7);
      l_ds7_8_val  INTERVAL DAY(7) TO SECOND(8);
      l_ds7_9_val  INTERVAL DAY(7) TO SECOND(9);
      l_ds8_0_val  INTERVAL DAY(8) TO SECOND(0);
      l_ds8_1_val  INTERVAL DAY(8) TO SECOND(1);
      l_ds8_2_val  INTERVAL DAY(8) TO SECOND(2);
      l_ds8_3_val  INTERVAL DAY(8) TO SECOND(3);
      l_ds8_4_val  INTERVAL DAY(8) TO SECOND(4);
      l_ds8_5_val  INTERVAL DAY(8) TO SECOND(5);
      l_ds8_6_val  INTERVAL DAY(8) TO SECOND(6);
      l_ds8_7_val  INTERVAL DAY(8) TO SECOND(7);
      l_ds8_8_val  INTERVAL DAY(8) TO SECOND(8);
      l_ds8_9_val  INTERVAL DAY(8) TO SECOND(9);
      l_ds9_0_val  INTERVAL DAY(9) TO SECOND(0);
      l_ds9_1_val  INTERVAL DAY(9) TO SECOND(1);
      l_ds9_2_val  INTERVAL DAY(9) TO SECOND(2);
      l_ds9_3_val  INTERVAL DAY(9) TO SECOND(3);
      l_ds9_4_val  INTERVAL DAY(9) TO SECOND(4);
      l_ds9_5_val  INTERVAL DAY(9) TO SECOND(5);
      l_ds9_6_val  INTERVAL DAY(9) TO SECOND(6);
      l_ds9_7_val  INTERVAL DAY(9) TO SECOND(7);
      l_ds9_8_val  INTERVAL DAY(9) TO SECOND(8);
      l_ds9_9_val  INTERVAL DAY(9) TO SECOND(9);
      l_p          NATURAL;
      l_s          NATURAL;
      l_str        varchar2_max_t;
   begin
      l_p := g_columns_metadata(col_in).col_precision;
      l_s := g_columns_metadata(col_in).col_scale;
      case 
         when l_p = 0 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_0_val);
           l_str := TO_CHAR(l_ds0_0_val);
         when l_p = 0 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_1_val);
           l_str := TO_CHAR(l_ds0_1_val);
         when l_p = 0 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_2_val);
           l_str := TO_CHAR(l_ds0_2_val);
         when l_p = 0 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_3_val);
           l_str := TO_CHAR(l_ds0_3_val);
         when l_p = 0 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_4_val);
           l_str := TO_CHAR(l_ds0_4_val);
         when l_p = 0 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_5_val);
           l_str := TO_CHAR(l_ds0_5_val);
         when l_p = 0 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_6_val);
           l_str := TO_CHAR(l_ds0_6_val);
         when l_p = 0 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_7_val);
           l_str := TO_CHAR(l_ds0_7_val);
         when l_p = 0 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_8_val);
           l_str := TO_CHAR(l_ds0_8_val);
         when l_p = 0 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds0_9_val);
           l_str := TO_CHAR(l_ds0_9_val);
         when l_p = 1 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_0_val);
           l_str := TO_CHAR(l_ds1_0_val);
         when l_p = 1 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_1_val);
           l_str := TO_CHAR(l_ds1_1_val);
         when l_p = 1 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_2_val);
           l_str := TO_CHAR(l_ds1_2_val);
         when l_p = 1 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_3_val);
           l_str := TO_CHAR(l_ds1_3_val);
         when l_p = 1 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_4_val);
           l_str := TO_CHAR(l_ds1_4_val);
         when l_p = 1 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_5_val);
           l_str := TO_CHAR(l_ds1_5_val);
         when l_p = 1 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_6_val);
           l_str := TO_CHAR(l_ds1_6_val);
         when l_p = 1 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_7_val);
           l_str := TO_CHAR(l_ds1_7_val);
         when l_p = 1 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_8_val);
           l_str := TO_CHAR(l_ds1_8_val);
         when l_p = 1 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds1_9_val);
           l_str := TO_CHAR(l_ds1_9_val);
         when l_p = 2 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_0_val);
           l_str := TO_CHAR(l_ds2_0_val);
         when l_p = 2 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_1_val);
           l_str := TO_CHAR(l_ds2_1_val);
         when l_p = 2 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_2_val);
           l_str := TO_CHAR(l_ds2_2_val);
         when l_p = 2 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_3_val);
           l_str := TO_CHAR(l_ds2_3_val);
         when l_p = 2 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_4_val);
           l_str := TO_CHAR(l_ds2_4_val);
         when l_p = 2 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_5_val);
           l_str := TO_CHAR(l_ds2_5_val);
         when l_p = 2 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_6_val);
           l_str := TO_CHAR(l_ds2_6_val);
         when l_p = 2 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_7_val);
           l_str := TO_CHAR(l_ds2_7_val);
         when l_p = 2 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_8_val);
           l_str := TO_CHAR(l_ds2_8_val);
         when l_p = 2 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds2_9_val);
           l_str := TO_CHAR(l_ds2_9_val);
         when l_p = 3 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_0_val);
           l_str := TO_CHAR(l_ds3_0_val);
         when l_p = 3 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_1_val);
           l_str := TO_CHAR(l_ds3_1_val);
         when l_p = 3 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_2_val);
           l_str := TO_CHAR(l_ds3_2_val);
         when l_p = 3 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_3_val);
           l_str := TO_CHAR(l_ds3_3_val);
         when l_p = 3 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_4_val);
           l_str := TO_CHAR(l_ds3_4_val);
         when l_p = 3 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_5_val);
           l_str := TO_CHAR(l_ds3_5_val);
         when l_p = 3 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_6_val);
           l_str := TO_CHAR(l_ds3_6_val);
         when l_p = 3 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_7_val);
           l_str := TO_CHAR(l_ds3_7_val);
         when l_p = 3 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_8_val);
           l_str := TO_CHAR(l_ds3_8_val);
         when l_p = 3 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds3_9_val);
           l_str := TO_CHAR(l_ds3_9_val);
         when l_p = 4 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_0_val);
           l_str := TO_CHAR(l_ds4_0_val);
         when l_p = 4 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_1_val);
           l_str := TO_CHAR(l_ds4_1_val);
         when l_p = 4 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_2_val);
           l_str := TO_CHAR(l_ds4_2_val);
         when l_p = 4 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_3_val);
           l_str := TO_CHAR(l_ds4_3_val);
         when l_p = 4 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_4_val);
           l_str := TO_CHAR(l_ds4_4_val);
         when l_p = 4 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_5_val);
           l_str := TO_CHAR(l_ds4_5_val);
         when l_p = 4 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_6_val);
           l_str := TO_CHAR(l_ds4_6_val);
         when l_p = 4 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_7_val);
           l_str := TO_CHAR(l_ds4_7_val);
         when l_p = 4 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_8_val);
           l_str := TO_CHAR(l_ds4_8_val);
         when l_p = 4 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds4_9_val);
           l_str := TO_CHAR(l_ds4_9_val);
         when l_p = 5 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_0_val);
           l_str := TO_CHAR(l_ds5_0_val);
         when l_p = 5 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_1_val);
           l_str := TO_CHAR(l_ds5_1_val);
         when l_p = 5 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_2_val);
           l_str := TO_CHAR(l_ds5_2_val);
         when l_p = 5 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_3_val);
           l_str := TO_CHAR(l_ds5_3_val);
         when l_p = 5 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_4_val);
           l_str := TO_CHAR(l_ds5_4_val);
         when l_p = 5 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_5_val);
           l_str := TO_CHAR(l_ds5_5_val);
         when l_p = 5 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_6_val);
           l_str := TO_CHAR(l_ds5_6_val);
         when l_p = 5 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_7_val);
           l_str := TO_CHAR(l_ds5_7_val);
         when l_p = 5 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_8_val);
           l_str := TO_CHAR(l_ds5_8_val);
         when l_p = 5 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds5_9_val);
           l_str := TO_CHAR(l_ds5_9_val);
         when l_p = 6 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_0_val);
           l_str := TO_CHAR(l_ds6_0_val);
         when l_p = 6 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_1_val);
           l_str := TO_CHAR(l_ds6_1_val);
         when l_p = 6 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_2_val);
           l_str := TO_CHAR(l_ds6_2_val);
         when l_p = 6 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_3_val);
           l_str := TO_CHAR(l_ds6_3_val);
         when l_p = 6 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_4_val);
           l_str := TO_CHAR(l_ds6_4_val);
         when l_p = 6 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_5_val);
           l_str := TO_CHAR(l_ds6_5_val);
         when l_p = 6 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_6_val);
           l_str := TO_CHAR(l_ds6_6_val);
         when l_p = 6 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_7_val);
           l_str := TO_CHAR(l_ds6_7_val);
         when l_p = 6 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_8_val);
           l_str := TO_CHAR(l_ds6_8_val);
         when l_p = 6 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds6_9_val);
           l_str := TO_CHAR(l_ds6_9_val);
         when l_p = 7 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_0_val);
           l_str := TO_CHAR(l_ds7_0_val);
         when l_p = 7 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_1_val);
           l_str := TO_CHAR(l_ds7_1_val);
         when l_p = 7 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_2_val);
           l_str := TO_CHAR(l_ds7_2_val);
         when l_p = 7 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_3_val);
           l_str := TO_CHAR(l_ds7_3_val);
         when l_p = 7 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_4_val);
           l_str := TO_CHAR(l_ds7_4_val);
         when l_p = 7 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_5_val);
           l_str := TO_CHAR(l_ds7_5_val);
         when l_p = 7 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_6_val);
           l_str := TO_CHAR(l_ds7_6_val);
         when l_p = 7 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_7_val);
           l_str := TO_CHAR(l_ds7_7_val);
         when l_p = 7 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_8_val);
           l_str := TO_CHAR(l_ds7_8_val);
         when l_p = 7 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds7_9_val);
           l_str := TO_CHAR(l_ds7_9_val);
         when l_p = 8 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_0_val);
           l_str := TO_CHAR(l_ds8_0_val);
         when l_p = 8 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_1_val);
           l_str := TO_CHAR(l_ds8_1_val);
         when l_p = 8 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_2_val);
           l_str := TO_CHAR(l_ds8_2_val);
         when l_p = 8 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_3_val);
           l_str := TO_CHAR(l_ds8_3_val);
         when l_p = 8 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_4_val);
           l_str := TO_CHAR(l_ds8_4_val);
         when l_p = 8 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_5_val);
           l_str := TO_CHAR(l_ds8_5_val);
         when l_p = 8 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_6_val);
           l_str := TO_CHAR(l_ds8_6_val);
         when l_p = 8 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_7_val);
           l_str := TO_CHAR(l_ds8_7_val);
         when l_p = 8 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_8_val);
           l_str := TO_CHAR(l_ds8_8_val);
         when l_p = 8 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds8_9_val);
           l_str := TO_CHAR(l_ds8_9_val);
         when l_p = 9 and l_s = 0 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_0_val);
           l_str := TO_CHAR(l_ds8_0_val);
         when l_p = 9 and l_s = 1 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_1_val);
           l_str := TO_CHAR(l_ds9_1_val);
         when l_p = 9 and l_s = 2 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_2_val);
           l_str := TO_CHAR(l_ds9_2_val);
         when l_p = 9 and l_s = 3 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_3_val);
           l_str := TO_CHAR(l_ds9_3_val);
         when l_p = 9 and l_s = 4 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_4_val);
           l_str := TO_CHAR(l_ds9_4_val);
         when l_p = 9 and l_s = 5 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_5_val);
           l_str := TO_CHAR(l_ds9_5_val);
         when l_p = 9 and l_s = 6 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_6_val);
           l_str := TO_CHAR(l_ds9_6_val);
         when l_p = 9 and l_s = 7 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_7_val);
           l_str := TO_CHAR(l_ds9_7_val);
         when l_p = 9 and l_s = 8 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_8_val);
           l_str := TO_CHAR(l_ds9_8_val);
         when l_p = 9 and l_s = 9 then 
           DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_ds9_9_val);
           l_str := TO_CHAR(l_ds9_9_val);
         else
           raise_application_error(-20103, 'Unandled precision='||l_p||' scale='||l_s);
      end case;
      return l_str ;
   end intervalds_as_str;


   function rowid_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_rowid   ROWID;
   begin
      DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_rowid);
      RETURN ROWIDTOCHAR(l_rowid);
   end rowid_as_str;


   function urowid_as_str(
      rcn_io   in out refcursor_number_t, 
      col_in   in     refcursor_column_t
   ) return varchar2
   IS
      l_urowid   UROWID;
   begin
      DBMS_SQL.COLUMN_VALUE (rcn_io, col_in, l_urowid);
      RETURN TO_CHAR(l_urowid);
   end urowid_as_str;


      -- Use NOCOPY and track the time needed
   PROCEDURE add_column( 
      row_io   in out VARCHAR2, 
      value_in        VARCHAR2, 
      size_in         BINARY_INTEGER,
      align_in        char
   ) IS

      FUNCTION escape(val_in varchar2) return varchar2 is
      begin
         return replace(val_in, g_encl, g_esc||g_encl);
      end escape;

      FUNCTION enclose(val_in varchar2) return varchar2 is
      BEGIN
         if ( g_encl is null) then
            return val_in;
         end if;
         return g_encl || escape(val_in) || g_encl ;
      END enclose;
      
      FUNCTION fixed_format(val_in varchar2, size_in binary_integer, align_in char) return varchar2 is
      begin
         if ( align_in = 'R' ) then
           return lpad(nvl(val_in, ' '), size_in);
         else
           return rpad(nvl(val_in, ' '), size_in);
         end if;
      end;
   
   BEGIN
      if ( g_sepval ) then
         if ( row_io is not null ) then
            row_io := row_io || g_fs ;
         end if;
         row_io := row_io || enclose(value_in);
      else
         row_io := row_io || fixed_format(value_in, size_in, align_in);
      end if;
   END add_column;

      
   FUNCTION default_headings RETURN headings_ntt IS
      l_headings   headings_ntt := headings_ntt();
   BEGIN
      FOR i in 1 .. g_column_count LOOP
         l_headings.EXTEND;
         l_headings(i) := g_columns_metadata(i).col_name ;
      END LOOP;
      RETURN l_headings;
   END default_headings;   
   
   
   FUNCTION print_headings RETURN VARCHAR2 IS
      l_row   tab_row_t;
      l_ind   headings_ind_t;
      l_lr    char(1) ;
   BEGIN
      l_ind := g_headings.FIRST;
      WHILE (l_ind <= g_headings.LAST) LOOP
         l_lr := 'L';
         if ( is_numeric(l_ind) ) then
            l_lr := 'R';
         end if;
         add_column( l_row, g_headings(l_ind), g_columns_metadata(l_ind).col_max_len, l_lr);
         l_ind := g_headings.NEXT(l_ind);
      END LOOP;
      g_head_printed := TRUE;
      RETURN l_row;
   END print_headings;


   /*
   || Wraps the cursor and initialize the column headings
   || using the cursor column names in case no custom headings were
   || provided and printing of headings is turned on.
   */
   PROCEDURE wrap(rc_in IN OUT sys_refcursor) IS
      l_string_value       tab_row_t;
      l_numeric_value      NUMBER;      
      l_date_value         DATE;
      l_timest_value       TIMESTAMP(9);
      l_timest_tz_value    TIMESTAMP(9) WITH TIME ZONE;
      l_timest_ltz_value   TIMESTAMP(9) WITH LOCAL TIME ZONE;
      l_interval_ds_value  INTERVAL DAY(9) TO SECOND(9);
      l_interval_ym_value  INTERVAL YEAR(9) TO MONTH;
      l_rowid_value        ROWID;
      l_urowid_value       UROWID;
   BEGIN
      reset_cursor ;
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
         ELSIF is_timest_tz (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_timest_tz_value);
         ELSIF is_timest_ltz (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_timest_ltz_value);
         ELSIF is_interval_ds (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_interval_ds_value);
         ELSIF is_interval_ym (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_interval_ym_value);
         ELSIF is_rowid (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_rowid_value);
         ELSIF is_urowid (l_col_idx) THEN
            DBMS_SQL.DEFINE_COLUMN (g_rcn, l_col_idx, l_urowid_value);
         ELSE
            raise_application_error(-20102, '<UNH-TYPE-'||g_columns_metadata(l_col_idx).col_type||'>');
         END IF;
      END LOOP;

      if ( g_head_on AND g_headings.COUNT = 0 ) then
         g_headings := default_headings;
      end if;
   END wrap;
   
   
   PROCEDURE unwrap IS
   BEGIN
      if (dbms_sql.is_open(g_rcn) ) then
         dbms_sql.close_cursor(g_rcn);
      end if;
   END unwrap;
   

   FUNCTION get_row RETURN VARCHAR2 IS
   
      l_row            tab_row_t;
      l_col_idx        INTEGER;
      l_lr             char(1);  -- Left/Right alignment
      l_fdbk           INTEGER;
      
      l_string_value      tab_row_t;
      l_numeric_value     NUMBER;   
      
   BEGIN
      IF ( g_rcn IS NULL ) THEN
         RAISE_NO_CURSOR;
      END IF;
      IF ( g_head_on AND NOT g_head_printed) THEN
         RETURN PRINT_HEADINGS;
      END IF;
      l_fdbk := DBMS_SQL.FETCH_ROWS (g_rcn); 
      IF ( l_fdbk = 0 ) THEN
         unwrap;
         RAISE no_data_found ;
      END IF;
      FOR l_col_idx IN 1 .. g_column_count LOOP
         l_lr := 'L';
         IF is_string (l_col_idx) THEN
            DBMS_SQL.COLUMN_VALUE (g_rcn, l_col_idx, l_string_value);
         ELSIF is_numeric (l_col_idx) THEN
            l_string_value := number_as_str(g_rcn, l_col_idx); 
            l_lr := 'R';
         ELSIF is_date (l_col_idx) THEN
            l_string_value := date_as_str(g_rcn, l_col_idx);
         ELSIF is_timest (l_col_idx) THEN
            l_string_value := timestamp_as_str(g_rcn, l_col_idx);
         ELSIF is_timest_tz (l_col_idx) THEN
            l_string_value := timestamp_tz_as_str(g_rcn, l_col_idx);
         ELSIF is_timest_ltz (l_col_idx) THEN
            l_string_value := timestamp_ltz_as_str(g_rcn, l_col_idx);
         ELSIF is_interval_ds(l_col_idx) THEN
            l_string_value := intervalds_as_str(g_rcn, l_col_idx);
         ELSIF is_interval_ym(l_col_idx) THEN
            l_string_value := intervalym_as_str(g_rcn, l_col_idx);
         ELSIF is_rowid(l_col_idx) THEN
            l_string_value := rowid_as_str (g_rcn, l_col_idx);
         ELSIF is_urowid(l_col_idx) THEN
            l_string_value := urowid_as_str (g_rcn, l_col_idx);
         ELSE
            l_string_value := '<UNH-FMT-'||g_columns_metadata(l_col_idx).col_type||'>';
         END IF;
         add_column(l_row, l_string_value, g_columns_metadata(l_col_idx).col_max_len, l_lr);
      END LOOP;
      RETURN l_row ;
   END get_row;
   
BEGIN
   csv ;
END tabtext;