

CREATE TABLE TEST_TABTEXT_TIMESTAMP(
   TIMESTAMP0         TIMESTAMP(0),
   TIMESTAMP1         TIMESTAMP(1),
   TIMESTAMP2         TIMESTAMP(2),
   TIMESTAMP3         TIMESTAMP(3),
   TIMESTAMP4         TIMESTAMP(4),
   TIMESTAMP5         TIMESTAMP(5),
   TIMESTAMP6         TIMESTAMP(6),
   TIMESTAMP7         TIMESTAMP(7),
   TIMESTAMP8         TIMESTAMP(8),
   TIMESTAMP9         TIMESTAMP(9)
);

insert into TEST_TABTEXT_TIMESTAMP
select localtimestamp(0),
       localtimestamp(1),
       localtimestamp(2),
       localtimestamp(3),
       localtimestamp(4),
       localtimestamp(5),
       localtimestamp(6),
       localtimestamp(7),
       localtimestamp(8),
       localtimestamp(9)
from dual;
commit;


set serveroutput on;
DECLARE
   l_cur   sys_refcursor ;
   l_res   VARCHAR2(32767);
   l_stmt  VARCHAR2(32767);
   l_regex VARCHAR2(20);
BEGIN
   for i in 0 .. 9 loop
      l_stmt := 'select timestamp'||i||' from TEST_TABTEXT_TIMESTAMP';
      OPEN l_cur FOR l_stmt ;
	    tabtext.tsv; 
      tabtext.headings_off;
	    tabtext.wrap(l_cur);
      l_res := tabtext.get_row;
	    tabtext.unwrap;
      dbms_output.put_line(l_res);
      if ( i = 0 ) then
         l_regex := ':\d\d$';
      else
         l_regex := ',\d{'||i||'}$';
      end if;
      if ( NOT REGEXP_LIKE(l_res, l_regex) ) then
        raise_application_error(-20999, 'TEST FAILED :(');
      end if;
   end loop;
   dbms_output.put_line('SUCCESS!');
END;
/

drop table TEST_TABTEXT_TIMESTAMP purge;


--==============================================================================
--
--==============================================================================
CREATE TABLE TEST_TABTEXT_TIMESTAMP_TZ(
   TIMESTAMP0         TIMESTAMP(0) WITH TIME ZONE,
   TIMESTAMP1         TIMESTAMP(1) WITH TIME ZONE,
   TIMESTAMP2         TIMESTAMP(2) WITH TIME ZONE,
   TIMESTAMP3         TIMESTAMP(3) WITH TIME ZONE,
   TIMESTAMP4         TIMESTAMP(4) WITH TIME ZONE,
   TIMESTAMP5         TIMESTAMP(5) WITH TIME ZONE,
   TIMESTAMP6         TIMESTAMP(6) WITH TIME ZONE,
   TIMESTAMP7         TIMESTAMP(7) WITH TIME ZONE,
   TIMESTAMP8         TIMESTAMP(8) WITH TIME ZONE,
   TIMESTAMP9         TIMESTAMP(9) WITH TIME ZONE
);

insert into TEST_TABTEXT_TIMESTAMP_TZ
select current_timestamp(0),
       current_timestamp(1),
       current_timestamp(2),
       current_timestamp(3),
       current_timestamp(4),
       current_timestamp(5),
       current_timestamp(6),
       current_timestamp(7),
       current_timestamp(8),
       current_timestamp(9)
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
      l_stmt := 'select timestamp'||i||' from TEST_TABTEXT_TIMESTAMP_TZ';
      OPEN l_cur FOR l_stmt ;
	    tabtext.tsv; 
      tabtext.headings_off;
	    tabtext.wrap(l_cur);
      l_res := tabtext.get_row;
	    tabtext.unwrap;
      dbms_output.put_line(l_res);
      if ( i = 0 ) then
         l_regex := ':\d\d [A-Z]+/[A-Z]+$';
      else
         l_regex := ',\d{'||i||'} [A-Z]+/[A-Z]+$';
      end if;
      if ( NOT REGEXP_LIKE(l_res, l_regex) ) then
        raise_application_error(-20999, 'TEST FAILED :(');
      end if;
   end loop;
   dbms_output.put_line('SUCCESS!');
END;
/

drop table TEST_TABTEXT_TIMESTAMP_TZ purge;


--==============================================================================
--
--==============================================================================
CREATE TABLE TEST_TABTEXT_TIMESTAMP_LTZ(
   TIMESTAMP0         TIMESTAMP(0) WITH LOCAL TIME ZONE,
   TIMESTAMP1         TIMESTAMP(1) WITH LOCAL TIME ZONE,
   TIMESTAMP2         TIMESTAMP(2) WITH LOCAL TIME ZONE,
   TIMESTAMP3         TIMESTAMP(3) WITH LOCAL TIME ZONE,
   TIMESTAMP4         TIMESTAMP(4) WITH LOCAL TIME ZONE,
   TIMESTAMP5         TIMESTAMP(5) WITH LOCAL TIME ZONE,
   TIMESTAMP6         TIMESTAMP(6) WITH LOCAL TIME ZONE,
   TIMESTAMP7         TIMESTAMP(7) WITH LOCAL TIME ZONE,
   TIMESTAMP8         TIMESTAMP(8) WITH LOCAL TIME ZONE,
   TIMESTAMP9         TIMESTAMP(9) WITH LOCAL TIME ZONE
);

insert into TEST_TABTEXT_TIMESTAMP_LTZ
select current_timestamp(0),
       current_timestamp(1),
       current_timestamp(2),
       current_timestamp(3),
       current_timestamp(4),
       current_timestamp(5),
       current_timestamp(6),
       current_timestamp(7),
       current_timestamp(8),
       current_timestamp(9)
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
      l_stmt := 'select timestamp'||i||' from TEST_TABTEXT_TIMESTAMP_LTZ';
      OPEN l_cur FOR l_stmt ;
	    tabtext.tsv; 
      tabtext.headings_off;
	    tabtext.wrap(l_cur);
      l_res := tabtext.get_row;
	    tabtext.unwrap;
      dbms_output.put_line(l_res);
      if ( i = 0 ) then
         l_regex := ':\d\d$';
      else
         l_regex := ',\d{'||i||'}$';
      end if;
      if ( NOT REGEXP_LIKE(l_res, l_regex) ) then
        raise_application_error(-20999, 'TEST FAILED :(');
      end if;
   end loop;
   dbms_output.put_line('SUCCESS!');
END;
/

drop table TEST_TABTEXT_TIMESTAMP_LTZ purge;
