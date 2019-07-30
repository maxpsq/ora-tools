create user speasy identified by spreadeasy 
default tablespace spreadeasy_tbs;

grant unlimited tablespace to speasy;
grant connect to speasy;
grant create table to speasy;
grant create sequence to speasy;
grant create procedure to speasy;
grant create any directory to speasy;
grant drop any directory to speasy;