create or replace
package spreadeasy_admin is
/*
███████╗██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗ █████╗ ███████╗██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
███████╗██████╔╝██████╔╝█████╗  ███████║██║  ██║█████╗  ███████║███████╗ ╚████╔╝ 
╚════██║██╔═══╝ ██╔══██╗██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██║╚════██║  ╚██╔╝  
███████║██║     ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║   ██║   
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   

  a software by Massimo Pasquini                                   vers. 1.0-M3
  
  License                                                    Apache version 2.0
  Last update                                                       2016-May-03
  
  Project homepage                          https://github.com/maxpsq/ora-tools

*/

   procedure set_resource_dir(path_in in varchar2);
   
   
   procedure load_ods_builders(charset_in  in varchar2);
   

   procedure load_all_builders(charset_in  in varchar2);
   

end;
/