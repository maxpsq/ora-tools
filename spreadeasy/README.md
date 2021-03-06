# SpreadEasy vers. 1.0-M3 (Milestone 3)


## What SpreadEasy is
It's a simple tool to easily serialize a cursor result set to [Open Document Spreadsheet](https://it.wikipedia.org/wiki/OpenDocument) format (OASIS Open Document Format for Office Applications).
Just define as many cursor variables as you wish, wrap each of them in a named worksheet and build your spreadsheet.


## What SpreadEasy is not
SpreadEasy is not meant to be a set of APIs to create a spreadsheet from scratch. You'll not be able to
move to a specific cell and set its value nor to write formulas or such. Spreadeasy is ways more simple and limited then other products like the Java POI library per say.


## How it works
SpreadEasy relies on Oracle XML DB. The cursors provided are just used to generate XML documents via DBMS_XML package and then transformed to spreadsheet components via XSLT. The files are then zipped to the spreasheet archive you choosed.


## How to use it
Here's an example on how to get a spreadsheet from a couple of queries run against the HR schema

```
declare
  -- This is a ORACLE DIRECTORY you've been granted write permissions
  l_ora_dir  varchar2(30) := 'SPREADEASY_RESOURCES';
  l_emp_cur         SYS_REFCURSOR;
  l_dpt_cur         SYS_REFCURSOR;
  spreadsheet_xml   XMLtype;
  spreadsheet_clob  CLOB;
begin
  -- Initilize your Document (document properties are optional)
  spreadeasy.newODS('Massimo Pasquini', 'ACME Industries'); 

  -- Set a locale (language + territory)
  -- The locale must match a record in SPREADEASY_LOCALES, the
  -- default locale en_US will be set in case of mismatch.
  -- Feel free to add any missing locale to the table
  -- SPREADEASY_LOCALES and contribute to fill the missing 
  -- records sending a pull request to this repository.
  spreadeasy.setLocale('it','IT');

  -- Open some cursor variables... (1)
  Open l_emp_cur for 
    SELECT First_name, Last_Name, salary 
      from hr.employees ;

  Open l_dpt_cur for 
    SELECT department_id, department_name 
      FROM hr.departments ;


  -- Wrap the results of each cursor in a new named worksheet
  spreadeasy.addWorkSheet(l_emp_cur, 'Employees'); 
  spreadeasy.addWorkSheet(l_dpt_cur, 'Departments');

  -- build the XML documents and save them as a ODS zipped archive.
  spreadeasy.build(l_ora_dir, 'hr.ods'); 
  
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

*/
```


## Installation instructions
Before you go further in this section, please notice Spreadeasy relies on tables and other Oracle objects, so the Oracle user you're palnning to host Spreadeasy requires specific privileges to be granted by a DBA.

These are the privileges you need to be granted:
- CREATE TABLE
- CREATE SEQUENCE
- CREATE PROCEDURE
- CREATE ANY DIRECTORY

Before you install or upgrade to a newer version, notice Spreadeasy depends on the package `as_zip` (it's in this same repository). You're required to install `as_zip` in order to compile Spreadeasy on your Oracle dadatabe.

Privided your user has been granted the aformentioned privileges, you can now connect to the Oracle database and follow the instructions whether you're installing SpreadEasy for the first time or you're migrating to a later version.

1. Run the migration script(s)        main/migrations/*.sql
2. create spreadeasy package          main/src/spradeasy.pk*
3. create spreadeasy_admin package    main/src/spradeasy_admin.pk*

finally, run this script

```
begin
  spreadeasy_admin.set_resource_dir('/your/absolute/path/to/ora-tools/spreadeasy/main/resources');
  -- automatically issues a commit in an autonomous transaction
  spreadeasy_admin.load_all_builders;
end;
/
```

now check wheather Spreadeasy runs fine or not, executing the example script at the beginning of this page in SQL Developer (provided you have installed and have access to the HR schema).


## Granting execution privileges to Spreadeasy
Spreadeasy was created to give a straightforward way to export query results as a spreadsheet, so it was designed to be granted to anybody who can access your Oracle DB. Just grant `execute privilege` on SPREADEASY package to any user who need it, or even better, make it available to the whole world granting execution to PUBLIC. 

The SPREADEASY_ADMIN package provides an access layer to administrative tasks and access to its routines MUST BE RESTRICTED to DBAs.


That's all. I expect you'll be loving Spreadeasy a lot. I'll be glad to hearing from you.



Massimo

