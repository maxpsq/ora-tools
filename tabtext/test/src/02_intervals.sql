
CREATE TABLE TEST_TABTEXT_INTERVAL_DS(
   interval0_0        INTERVAL DAY(0) TO SECOND(0),
   interval0_1        INTERVAL DAY(0) TO SECOND(1),
   interval0_2        INTERVAL DAY(0) TO SECOND(2),
   interval0_3        INTERVAL DAY(0) TO SECOND(3),
   interval0_4        INTERVAL DAY(0) TO SECOND(4),
   interval0_5        INTERVAL DAY(0) TO SECOND(5),
   interval0_6        INTERVAL DAY(0) TO SECOND(6),
   interval0_7        INTERVAL DAY(0) TO SECOND(7),
   interval0_8        INTERVAL DAY(0) TO SECOND(8),
   interval0_9        INTERVAL DAY(0) TO SECOND(9),
   interval1_0        INTERVAL DAY(1) TO SECOND(0),
   interval1_1        INTERVAL DAY(1) TO SECOND(1),
   interval1_2        INTERVAL DAY(1) TO SECOND(2),
   interval1_3        INTERVAL DAY(1) TO SECOND(3),
   interval1_4        INTERVAL DAY(1) TO SECOND(4),
   interval1_5        INTERVAL DAY(1) TO SECOND(5),
   interval1_6        INTERVAL DAY(1) TO SECOND(6),
   interval1_7        INTERVAL DAY(1) TO SECOND(7),
   interval1_8        INTERVAL DAY(1) TO SECOND(8),
   interval1_9        INTERVAL DAY(1) TO SECOND(9),
   interval2_0        INTERVAL DAY(2) TO SECOND(0),
   interval2_1        INTERVAL DAY(2) TO SECOND(1),
   interval2_2        INTERVAL DAY(2) TO SECOND(2),
   interval2_3        INTERVAL DAY(2) TO SECOND(3),
   interval2_4        INTERVAL DAY(2) TO SECOND(4),
   interval2_5        INTERVAL DAY(2) TO SECOND(5),
   interval2_6        INTERVAL DAY(2) TO SECOND(6),
   interval2_7        INTERVAL DAY(2) TO SECOND(7),
   interval2_8        INTERVAL DAY(2) TO SECOND(8),
   interval2_9        INTERVAL DAY(2) TO SECOND(9),
   interval3_0        INTERVAL DAY(3) TO SECOND(0),
   interval3_1        INTERVAL DAY(3) TO SECOND(1),
   interval3_2        INTERVAL DAY(3) TO SECOND(2),
   interval3_3        INTERVAL DAY(3) TO SECOND(3),
   interval3_4        INTERVAL DAY(3) TO SECOND(4),
   interval3_5        INTERVAL DAY(3) TO SECOND(5),
   interval3_6        INTERVAL DAY(3) TO SECOND(6),
   interval3_7        INTERVAL DAY(3) TO SECOND(7),
   interval3_8        INTERVAL DAY(3) TO SECOND(8),
   interval3_9        INTERVAL DAY(3) TO SECOND(9),
   interval4_0        INTERVAL DAY(4) TO SECOND(0),
   interval4_1        INTERVAL DAY(4) TO SECOND(1),
   interval4_2        INTERVAL DAY(4) TO SECOND(2),
   interval4_3        INTERVAL DAY(4) TO SECOND(3),
   interval4_4        INTERVAL DAY(4) TO SECOND(4),
   interval4_5        INTERVAL DAY(4) TO SECOND(5),
   interval4_6        INTERVAL DAY(4) TO SECOND(6),
   interval4_7        INTERVAL DAY(4) TO SECOND(7),
   interval4_8        INTERVAL DAY(4) TO SECOND(8),
   interval4_9        INTERVAL DAY(4) TO SECOND(9),
   interval5_0        INTERVAL DAY(5) TO SECOND(0),
   interval5_1        INTERVAL DAY(5) TO SECOND(1),
   interval5_2        INTERVAL DAY(5) TO SECOND(2),
   interval5_3        INTERVAL DAY(5) TO SECOND(3),
   interval5_4        INTERVAL DAY(5) TO SECOND(4),
   interval5_5        INTERVAL DAY(5) TO SECOND(5),
   interval5_6        INTERVAL DAY(5) TO SECOND(6),
   interval5_7        INTERVAL DAY(5) TO SECOND(7),
   interval5_8        INTERVAL DAY(5) TO SECOND(8),
   interval5_9        INTERVAL DAY(5) TO SECOND(9),
   interval6_0        INTERVAL DAY(6) TO SECOND(0),
   interval6_1        INTERVAL DAY(6) TO SECOND(1),
   interval6_2        INTERVAL DAY(6) TO SECOND(2),
   interval6_3        INTERVAL DAY(6) TO SECOND(3),
   interval6_4        INTERVAL DAY(6) TO SECOND(4),
   interval6_5        INTERVAL DAY(6) TO SECOND(5),
   interval6_6        INTERVAL DAY(6) TO SECOND(6),
   interval6_7        INTERVAL DAY(6) TO SECOND(7),
   interval6_8        INTERVAL DAY(6) TO SECOND(8),
   interval6_9        INTERVAL DAY(6) TO SECOND(9),
   interval7_0        INTERVAL DAY(7) TO SECOND(0),
   interval7_1        INTERVAL DAY(7) TO SECOND(1),
   interval7_2        INTERVAL DAY(7) TO SECOND(2),
   interval7_3        INTERVAL DAY(7) TO SECOND(3),
   interval7_4        INTERVAL DAY(7) TO SECOND(4),
   interval7_5        INTERVAL DAY(7) TO SECOND(5),
   interval7_6        INTERVAL DAY(7) TO SECOND(6),
   interval7_7        INTERVAL DAY(7) TO SECOND(7),
   interval7_8        INTERVAL DAY(7) TO SECOND(8),
   interval7_9        INTERVAL DAY(7) TO SECOND(9),
   interval8_0        INTERVAL DAY(8) TO SECOND(0),
   interval8_1        INTERVAL DAY(8) TO SECOND(1),
   interval8_2        INTERVAL DAY(8) TO SECOND(2),
   interval8_3        INTERVAL DAY(8) TO SECOND(3),
   interval8_4        INTERVAL DAY(8) TO SECOND(4),
   interval8_5        INTERVAL DAY(8) TO SECOND(5),
   interval8_6        INTERVAL DAY(8) TO SECOND(6),
   interval8_7        INTERVAL DAY(8) TO SECOND(7),
   interval8_8        INTERVAL DAY(8) TO SECOND(8),
   interval8_9        INTERVAL DAY(8) TO SECOND(9),
   interval9_0        INTERVAL DAY(9) TO SECOND(0),
   interval9_1        INTERVAL DAY(9) TO SECOND(1),
   interval9_2        INTERVAL DAY(9) TO SECOND(2),
   interval9_3        INTERVAL DAY(9) TO SECOND(3),
   interval9_4        INTERVAL DAY(9) TO SECOND(4),
   interval9_5        INTERVAL DAY(9) TO SECOND(5),
   interval9_6        INTERVAL DAY(9) TO SECOND(6),
   interval9_7        INTERVAL DAY(9) TO SECOND(7),
   interval9_8        INTERVAL DAY(9) TO SECOND(8),
   interval9_9        INTERVAL DAY(9) TO SECOND(9)
);

insert into TEST_TABTEXT_INTERVAL_DS
select    
   INTERVAL '0 3:04:11' DAY(0) TO SECOND(0),
   INTERVAL '0 3:04:11.3' DAY(0) TO SECOND(1),
   INTERVAL '0 3:04:11.33' DAY(0) TO SECOND(2),
   INTERVAL '0 3:04:11.333' DAY(0) TO SECOND(3),
   INTERVAL '0 3:04:11.3333' DAY(0) TO SECOND(4),
   INTERVAL '0 3:04:11.33333' DAY(0) TO SECOND(5),
   INTERVAL '0 3:04:11.333333' DAY(0) TO SECOND(6),
   INTERVAL '0 3:04:11.3333333' DAY(0) TO SECOND(7),
   INTERVAL '0 3:04:11.33333333' DAY(0) TO SECOND(8),
   INTERVAL '0 3:04:11.333333333' DAY(0) TO SECOND(9),
   INTERVAL '2 3:04:11' DAY(1) TO SECOND(0),
   INTERVAL '2 3:04:11.3' DAY(1) TO SECOND(1),
   INTERVAL '2 3:04:11.33' DAY(1) TO SECOND(2),
   INTERVAL '2 3:04:11.333' DAY(1) TO SECOND(3),
   INTERVAL '2 3:04:11.3333' DAY(1) TO SECOND(4),
   INTERVAL '2 3:04:11.33333' DAY(1) TO SECOND(5),
   INTERVAL '2 3:04:11.333333' DAY(1) TO SECOND(6),
   INTERVAL '2 3:04:11.3333333' DAY(1) TO SECOND(7),
   INTERVAL '2 3:04:11.33333333' DAY(1) TO SECOND(8),
   INTERVAL '2 3:04:11.333333333' DAY(1) TO SECOND(9),
   INTERVAL '22 3:04:11' DAY(2) TO SECOND(0),
   INTERVAL '22 3:04:11.3' DAY(2) TO SECOND(1),
   INTERVAL '22 3:04:11.33' DAY(2) TO SECOND(2),
   INTERVAL '22 3:04:11.333' DAY(2) TO SECOND(3),
   INTERVAL '22 3:04:11.3333' DAY(2) TO SECOND(4),
   INTERVAL '22 3:04:11.33333' DAY(2) TO SECOND(5),
   INTERVAL '22 3:04:11.333333' DAY(2) TO SECOND(6),
   INTERVAL '22 3:04:11.3333333' DAY(2) TO SECOND(7),
   INTERVAL '22 3:04:11.33333333' DAY(2) TO SECOND(8),
   INTERVAL '22 3:04:11.333333333' DAY(2) TO SECOND(9),
   INTERVAL '222 3:04:11' DAY(3) TO SECOND(0),
   INTERVAL '222 3:04:11.3' DAY(3) TO SECOND(1),
   INTERVAL '222 3:04:11.33' DAY(3) TO SECOND(2),
   INTERVAL '222 3:04:11.333' DAY(3) TO SECOND(3),
   INTERVAL '222 3:04:11.3333' DAY(3) TO SECOND(4),
   INTERVAL '222 3:04:11.33333' DAY(3) TO SECOND(5),
   INTERVAL '222 3:04:11.333333' DAY(3) TO SECOND(6),
   INTERVAL '222 3:04:11.3333333' DAY(3) TO SECOND(7),
   INTERVAL '222 3:04:11.33333333' DAY(3) TO SECOND(8),
   INTERVAL '222 3:04:11.333333333' DAY(3) TO SECOND(9),
   INTERVAL '2222 3:04:11' DAY(4) TO SECOND(0),
   INTERVAL '2222 3:04:11.3' DAY(4) TO SECOND(1),
   INTERVAL '2222 3:04:11.33' DAY(4) TO SECOND(2),
   INTERVAL '2222 3:04:11.333' DAY(4) TO SECOND(3),
   INTERVAL '2222 3:04:11.3333' DAY(4) TO SECOND(4),
   INTERVAL '2222 3:04:11.33333' DAY(4) TO SECOND(5),
   INTERVAL '2222 3:04:11.333333' DAY(4) TO SECOND(6),
   INTERVAL '2222 3:04:11.3333333' DAY(4) TO SECOND(7),
   INTERVAL '2222 3:04:11.33333333' DAY(4) TO SECOND(8),
   INTERVAL '2222 3:04:11.333333333' DAY(4) TO SECOND(9),
   INTERVAL '22222 3:04:11' DAY(5) TO SECOND(0),
   INTERVAL '22222 3:04:11.3' DAY(5) TO SECOND(1),
   INTERVAL '22222 3:04:11.33' DAY(5) TO SECOND(2),
   INTERVAL '22222 3:04:11.333' DAY(5) TO SECOND(3),
   INTERVAL '22222 3:04:11.3333' DAY(5) TO SECOND(4),
   INTERVAL '22222 3:04:11.33333' DAY(5) TO SECOND(5),
   INTERVAL '22222 3:04:11.333333' DAY(5) TO SECOND(6),
   INTERVAL '22222 3:04:11.3333333' DAY(5) TO SECOND(7),
   INTERVAL '22222 3:04:11.33333333' DAY(5) TO SECOND(8),
   INTERVAL '22222 3:04:11.333333333' DAY(5) TO SECOND(9),
   INTERVAL '222222 3:04:11' DAY(6) TO SECOND(0),
   INTERVAL '222222 3:04:11.3' DAY(6) TO SECOND(1),
   INTERVAL '222222 3:04:11.33' DAY(6) TO SECOND(2),
   INTERVAL '222222 3:04:11.333' DAY(6) TO SECOND(3),
   INTERVAL '222222 3:04:11.3333' DAY(6) TO SECOND(4),
   INTERVAL '222222 3:04:11.33333' DAY(6) TO SECOND(5),
   INTERVAL '222222 3:04:11.333333' DAY(6) TO SECOND(6),
   INTERVAL '222222 3:04:11.3333333' DAY(6) TO SECOND(7),
   INTERVAL '222222 3:04:11.33333333' DAY(6) TO SECOND(8),
   INTERVAL '222222 3:04:11.333333333' DAY(6) TO SECOND(9),
   INTERVAL '2222222 3:04:11' DAY(7) TO SECOND(0),
   INTERVAL '2222222 3:04:11.3' DAY(7) TO SECOND(1),
   INTERVAL '2222222 3:04:11.33' DAY(7) TO SECOND(2),
   INTERVAL '2222222 3:04:11.333' DAY(7) TO SECOND(3),
   INTERVAL '2222222 3:04:11.3333' DAY(7) TO SECOND(4),
   INTERVAL '2222222 3:04:11.33333' DAY(7) TO SECOND(5),
   INTERVAL '2222222 3:04:11.333333' DAY(7) TO SECOND(6),
   INTERVAL '2222222 3:04:11.3333333' DAY(7) TO SECOND(7),
   INTERVAL '2222222 3:04:11.33333333' DAY(7) TO SECOND(8),
   INTERVAL '2222222 3:04:11.333333333' DAY(7) TO SECOND(9),
   INTERVAL '22222222 3:04:11' DAY(8) TO SECOND(0),
   INTERVAL '22222222 3:04:11.3' DAY(8) TO SECOND(1),
   INTERVAL '22222222 3:04:11.33' DAY(8) TO SECOND(2),
   INTERVAL '22222222 3:04:11.333' DAY(8) TO SECOND(3),
   INTERVAL '22222222 3:04:11.3333' DAY(8) TO SECOND(4),
   INTERVAL '22222222 3:04:11.33333' DAY(8) TO SECOND(5),
   INTERVAL '22222222 3:04:11.333333' DAY(8) TO SECOND(6),
   INTERVAL '22222222 3:04:11.3333333' DAY(8) TO SECOND(7),
   INTERVAL '22222222 3:04:11.33333333' DAY(8) TO SECOND(8),
   INTERVAL '22222222 3:04:11.333333333' DAY(8) TO SECOND(9),
   INTERVAL '222222222 3:04:11' DAY(9) TO SECOND(0),
   INTERVAL '222222222 3:04:11.3' DAY(9) TO SECOND(1),
   INTERVAL '222222222 3:04:11.33' DAY(9) TO SECOND(2),
   INTERVAL '222222222 3:04:11.333' DAY(9) TO SECOND(3),
   INTERVAL '222222222 3:04:11.3333' DAY(9) TO SECOND(4),
   INTERVAL '222222222 3:04:11.33333' DAY(9) TO SECOND(5),
   INTERVAL '222222222 3:04:11.333333' DAY(9) TO SECOND(6),
   INTERVAL '222222222 3:04:11.3333333' DAY(9) TO SECOND(7),
   INTERVAL '222222222 3:04:11.33333333' DAY(9) TO SECOND(8),
   INTERVAL '222222222 3:04:11.333333333' DAY(9) TO SECOND(9)
from dual;
commit;


set serveroutput on;
DECLARE
   l_cur   sys_refcursor ;
   l_res   VARCHAR2(32767);
   l_stmt  VARCHAR2(32767);
   l_regex VARCHAR2(100);
BEGIN
  for i in 0 .. 9 loop
    for j in 0 .. 9 loop
      l_stmt := 'select interval'||i||'_'||j||' from TEST_TABTEXT_INTERVAL_DS';
      OPEN l_cur FOR l_stmt ;
	    tabtext.csv('',''); 
      tabtext.headings_off;
	    tabtext.wrap(l_cur);
      l_res := tabtext.get_row;
      tabtext.unwrap;
      dbms_output.put_line(l_res);
      if ( i = 0 ) then
        l_regex := '^\+0';
      else  
        l_regex := '^\+\d{'||i||'}';
      end if;
      if ( j = 0 ) then
         l_regex := l_regex||' 03:04:\d\d$';
      else
         l_regex := l_regex||' 03:04:11\.\d{'||j||'}$';
      end if;
      if ( NOT REGEXP_LIKE(l_res, l_regex) ) then
        raise_application_error(-20999, 'TEST FAILED :(');
      end if;
    end loop;
  end loop;
  dbms_output.put_line('SUCCESS!');
END;
/

drop table TEST_TABTEXT_INTERVAL_DS purge;



--==============================================================================
--
--==============================================================================
CREATE TABLE TEST_TABTEXT_INTERVALS_YM(
   INTERVAL0          INTERVAL YEAR(0) TO MONTH,
   INTERVAL1          INTERVAL YEAR(1) TO MONTH,
   INTERVAL2          INTERVAL YEAR(2) TO MONTH,
   INTERVAL3          INTERVAL YEAR(3) TO MONTH,
   INTERVAL4          INTERVAL YEAR(4) TO MONTH,
   INTERVAL5          INTERVAL YEAR(5) TO MONTH,
   INTERVAL6          INTERVAL YEAR(6) TO MONTH,
   INTERVAL7          INTERVAL YEAR(7) TO MONTH,
   INTERVAL8          INTERVAL YEAR(8) TO MONTH,
   INTERVAL9          INTERVAL YEAR(9) TO MONTH
);

insert into TEST_TABTEXT_INTERVALS_YM
select INTERVAL '1' MONTH,
       INTERVAL '2-1' YEAR(1) TO MONTH,
       INTERVAL '22-1' YEAR(2) TO MONTH,
       INTERVAL '222-1' YEAR(3) TO MONTH,
       INTERVAL '2222-1' YEAR(4) TO MONTH,
       INTERVAL '22222-1' YEAR(5) TO MONTH,
       INTERVAL '222222-1' YEAR(6) TO MONTH,
       INTERVAL '2222222-1' YEAR(7) TO MONTH,
       INTERVAL '22222222-1' YEAR(8) TO MONTH,
       INTERVAL '222222222-1' YEAR(9) TO MONTH
from dual;
commit;


set serveroutput on;
DECLARE
   l_cur   sys_refcursor ;
   l_res   VARCHAR2(32767);
   l_stmt  VARCHAR2(32767);
   l_regex VARCHAR2(255);
BEGIN
   for i in 0 .. 9 loop
      l_stmt := 'select interval'||i||' from TEST_TABTEXT_INTERVALS_YM';
      OPEN l_cur FOR l_stmt ;
      tabtext.csv('',''); 
      tabtext.headings_off;
	    tabtext.wrap(l_cur);
      l_res := tabtext.get_row;
      tabtext.unwrap;
      dbms_output.put_line(l_res);
      if ( i = 0 ) then
         l_regex := '^\+0-01$';
      else
         l_regex := '^\+\d{'||i||'}-01$';
      end if;
      if ( NOT REGEXP_LIKE(l_res, l_regex) ) then
        raise_application_error(-20999, 'TEST FAILED :(');
      end if;
   end loop;
   dbms_output.put_line('SUCCESS!');
END;
/

drop table TEST_TABTEXT_INTERVALS_YM purge;

