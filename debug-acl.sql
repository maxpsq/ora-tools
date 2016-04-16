/**

In order to allow debugging on 12c, you need to manage Oracle ACL.

Configure network access for JDWP operations.

https://galobalda.wordpress.com/2014/02/17/sql-developers-plsql-debugger-and-oracle-12c/
*/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host => '192.168.0.101', --> Add here the IP of the machine where Oracle is running
      lower_port => null,
      upper_port => null,
      ace => xs$ace_type(privilege_list => xs$name_list('jdwp'),
      principal_name => 'SPREADEASY',  --> Add the owner of the objects you want to debug
      principal_type => xs_acl.ptype_db)
  );
END;
/
