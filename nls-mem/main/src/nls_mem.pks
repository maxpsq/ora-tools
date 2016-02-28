create or replace package nls_mem authid current_user is
/*
      o.     O  o      .oOOOo.            Oo      oO o.OOoOoo Oo      oO 
      Oo     o O       o     o            O O    o o  O       O O    o o 
      O O    O o       O.                 o  o  O  O  o       o  o  O  O 
      O  o   o o        `OOoo.            O   Oo   O  ooOO    O   Oo   O 
      O   o  O O             `O           O        o  O       O        o 
      o    O O O              o           o        O  o       o        O 
      o     Oo o     . O.    .O           o        O  O       o        O 
      O     `o OOoOooO  `oooO'            O        o ooOooOoO O        o 
                                ooooooooo                                
                                                                   
  a software by Massimo Pasquini                                       vers. 1.0
  
  License                                                     Apache version 2.0                        
  Last update                                                        2016-Feb-28
  
  Project homepage                           https://github.com/maxpsq/ora-tools
*/

  procedure altersession(
    paramname_in    varchar2
  , value_in        varchar2
  );


  function stack_size return pls_integer;


  procedure save;


  procedure flashback ;
  
  
end;
/