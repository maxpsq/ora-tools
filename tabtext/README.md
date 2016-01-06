# Tabular Text (tabtext)

This package provides a simple way to convert a cursor to tabular plain text file (like CSV or TSV).

Here's a snippet showing how o use it

```
DECLARE
   /* l_employees_rc ref_cursor */
   type headings_vat	is VARRAY(3) of varchar2(30);
   l_headings   headings_vat := headings_vat('aaa', 'bbb', 'ccc');

	l_fh     utl_file.file_type ;
	l_dir    varchar2(255) := '/path/to/write' ;
	l_file   varchar2(255) := 'tab.csv' ;
BEGIN
	tabtext.init(fs_in => ';', enc_in => '"'); --
	tabtext.headings(l_headings);  -- or even  tabtext.no_headings;
	tabtext.data(l_employees_rc);
	l_fh := utl_file.fopen(l_dir, l_file, 'w');
	tabtext.spool(l_fh);


    -- or even better
	tabtext.init(fs_in => ';', enc_in => '"'); --
	tabtext.headings(l_headings);  -- or even  tabtext.no_headings;
	tabtext.data(l_employees_rc);
	l_fh := utl_file.fopen(l_dir, l_file, 'w');
	loop
		begin
			utl_file.put_line(tabtext.get_row);
		exception
			when no_data_found then
				exit;
		end;
	end loop;
	utl_file.fclose(l_fh);
END;
/
```

