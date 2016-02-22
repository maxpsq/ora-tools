# SpreadEasy vers. 0.1-M1 (Milestone 1)


## What SpreadEasy is
It's a simple tool to easily serialize a cursor result set to [Microsoft Office XML Spreadsheet](https://en.wikipedia.org/wiki/Microsoft_Office_XML_formats) format (Microsoft Excel 2002 / Microsoft Office XP, not to be confused with "Office Open XML Format").
Just define as many cursor variables as you wish, wrap each of them in a named worksheet and build your spreadsheet.


## What SpreadEasy is not
SpreadEasy is not meant to be a set of APIs to create a spreadsheet from scratch. You'll not be able to
move to a specific cell and set its value nor to write formulas or such. Spreadeasy is ways more simple and limited then other products like the Java POI library per say.


## How it works
SpreadEasy relies on Oracle XML DB. The cursors provided are just used to generate XML documents
via DBMS_XML package and then transformed to a spreadsheet via XSLT.


## How to use it
Here's an example on how to get a spreadsheet from a couple of queries run against the HR schema

```
declare
  l_emp_cur         SYS_REFCURSOR;
  l_dpt_stmt        VARCHAR2(400);
  spreadsheet_xml   XMLtype;
  spreadsheet_clob  CLOB;
begin
  -- Initilize your Document (document properties are optional)
  spreadeasy.newExcel('Massimo Pasquini', 'ACME Industries'); 

  -- Open a cursor variable... (1)
  Open l_emp_cur for 
    SELECT First_name, Last_Name, salary 
      from hr.employees ;

  -- ...or just fill a string with a SQL statement
  l_dpt_stmt := 'SELECT department_id, department_name FROM hr.departments' ;

  -- Wrap the results of each cursor in a new named worksheet
  spreadeasy.addWorkSheet(l_emp_cur, 'Employees'); 
  spreadeasy.addWorkSheet(l_dpt_stmt, 'Departments');

  -- build the XML document
  spreadeasy.build; 

  -- Now get your spreadsheet either as an XMLType...
  spreadsheet_xml := spreadeasy.getAsXMLType  
  -- ... or as a CLOB
  spreadsheet_clob := spreadeasy.getAsCLOB  

  -- [just do what you want with your spreadsheet here (2)]
  
  -- Finally, it's a good practice to clear all package
  -- variables after use...
  spreadeasy.reset;

exception
  when others then
  -- ... even when something unexpected happens
    spreadeasy.reset;
    raise;
end;
/

/**

(1) SpreadEasy is designed to format the data retrieved from
your cursor by setting NLS_* variables issuing a set of
ALTER SESSION commands on call to `newExcel`. It's important
to open all the cursor variables after the session is altered.
Cursors eventually opened before the ALTER SESSION takes place,
won't be affected by the new setting of NLS_NUMERIC_CHARACTERS.
You won't notice this issue if your default locale uses a point
as decimal separator, but I strongly suggest to make your 
application portable by obeying this rule.
Passing a string containing a SQL statement instead of a cursor
variable, relieves you from using this workaround.
Notice also your session settings are brought back to the 
original settings after the spreadsheet is built (after call
to `build`).


(2) DISCLAIMER 
how to write your spreadsheet to a file is out of the scope
of Spreadeasy. You'll probably already have a routine to get
the job done, so I just wanted to avoid this package to grow
over the necessary size.
In case you don't have such a routine, just google for:
'Oracle save CLOB to file'.

*/
```


## Installation instructions
Before you go further in this section, please notice Spreadeasy relies on tables and other Oracle objects, so the Oracle user you're palnning to host Spreadeasy requires specific privileges to be granted by a DBA.

These are the privileges you need to be granted:
- CREATE TABLE
- CREATE SEQUENCE
- CREATE PROCEDURE
- CREATE ANY DIRECTORY

Privided your user has been granted the aformentioned privileges, you can now connect to the Oracle database and follow the instructions whether you're installing SpreadEasy for the first time or you're migrating to a later version.

1. Run the migration script(s)        main/migrations/*.sql
2. create spreadeasy package          main/src/spradeasy.pk*
3. create spreadeasy_admin package    main/src/spradeasy_admin.pk*

finally, run this script

```
begin
  spreadeasy_admin.set_resource_dir('/your/absolute/path/to/ora-tools/spreadeasy/main/resources');
  -- automatically issues a commit in an autonomous transaction
  spreadeasy_admin.load_excel_xslt; 
end;
/
```

now check wheather Spreadeasy runs fine or not, executing the example script at the beginning of this page in SQL Developer (provided you have installed and have access to the HR schema).


## Granting execution privileges to Spreadeasy
Spreadeasy was created to give a straightforward way to export query results as a spreadsheet, so it was designed to be granted to anybody who can access your Oracle DB. Just grant `execute privilege` on SPREADEASY package to any user who need it, or even better, make it available to the whole world granting execution to PUBLIC. 

The SPREADEASY_ADMIN package provides an access layer to administrative tasks and access to its routines MUST BE RESTRICTED to DBAs.


That's all. I expect you'll be loving Spreadeasy a lot. I'll be glad to hearing from you.



Massimo

