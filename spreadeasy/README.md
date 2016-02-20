# SpreadEasy

## What SpreadEasy is
It's a simple tool to easily serialize a cursor result set to Microsoft Office XML Spreadsheet format (Microsoft Excel 2002 / Microsoft Office XP, not to be confused with "Office Open XML Format").
Just define as many cursor variables as you wish, wrap each of them in a named worksheet and build your spreadsheet.

## What SpreadEasy is not
SpreadEasy is not meant to be a set of APIs to create a spreadsheet by scratch. You'll not be able to
move to a specific cell and set its value nor to set formulas or such. Spreadeasy is ways more simple and limited then other products like the Java POI library per say.

## How to use it

```
declare
  l_emp_cur   SYS_REFCURSOR;
  l_dpt_stmt  VARCHAR2(32767);
  l_fh        utl_file.file_type;
begin
  -- Open a cursor variable
  Open l_emp_cur for 
    SELECT First_name, Last_Name, salary 
      from hr.employees ;

  l_dpt_stmt := 'SELECT department_id, department_name from hr.departments' ;

  spreadeasy.newExcel; -- initilizes your Document
  spreadeasy.addWorkSheet('Employees', l_emp_cur); -- Wraps the results of the given cursor in a new worksheet
  spreadeasy.addWorkSheet('Departments', l_dpt_stmt);
  spreadeasy.build; -- builds the XML document

  l_fh := utl_file.fopen('C:\temp', 'employees.xls', 'w');
  spreadeasy.send(l_fh); --> TODO: ** NOT YET IMPLEMENTED **
  utl_file.fclose(l_fh);
  
  spreadeasy.reset;
exception
  when others then
    spreadeasy.reset;
    raise;
end;
/
```

Just in case you need to find out more about the MS Office XML format, follow the links below:

https://en.wikipedia.org/wiki/Microsoft_Office_XML_formats

https://msdn.microsoft.com/en-us/library/aa140066(office.10).aspx




http://docs.oracle.com/cd/B28359_01/appdev.111/b28369/xdb03usg.htm#sthref270
http://aspalliance.com/471_Convert_XML_To_an_Excel_Spreadsheet_Using_XSL.all

https://github.com/OfficeDev/office-content/blob/master/en-us/OpenXMLCon/articles/3b35a153-c8ff-4dc7-96d5-02c515f31770.md


## Installation guide

Connect as the user whose schema will host Spreadeasy, then

1. Run the migration script
2. create spreadeasy package
3. create spreadeasy_admin package

finally, run this script

```
begin
  spreadeasy_admin.set_resource_dir('/your/path/to/spreadeasy/main/resources');
  spreadeasy_admin.load_excel_xslt; -- automatically issues a commit in an autonomous transaction
end;
/
```

now check wheather Spreadeasy runs fine or not, for example copy an paste the sample script at the beginning of this page in SQL Developer.


That's all. I expect you'll be loving Spreadeasy a lot, I hope I can hear from you.
