create or replace package body nls_mem is
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

  subtype key_t is v$nls_parameters.parameter%type;
  
  subtype val_t is v$nls_parameters.value%type;
  
  type map_aat is table of val_t index by key_t;
  
  type stack_ntt is table of map_aat;
  
  /* The stack (LIFO) containing the copies of the NLS parameters we saved */
  g_stack           stack_ntt := stack_ntt();

  
  /* 
  Return the stack size. This module was made pulic for
  debugging or inspection purpose.
  */
  function stack_size return pls_integer is
  begin
    return g_stack.COUNT;
  end;
  
  /* 
  Add a value to the stack 
  */
  procedure push(map_in in map_aat) is
  begin
    g_stack.EXTEND;
    g_stack(g_stack.LAST) := map_in;
  end;


  /* 
  Take a value out from the stack 
  */
  function pop return map_aat is
    l_map  map_aat;
  begin
    -- Being this module private to the package, I choose to raise
    -- a no_data_found exception in case the stack is empty. 
    -- The `flashback` routine handles this exception.
    if ( stack_size = 0 ) then
      RAISE no_data_found;
    end if;
    l_map := g_stack(g_stack.LAST);
    g_stack.TRIM;
    return l_map;
  end;

  /*
  Ensures 'key' are stored as lowercase in the map
  */
  function to_key(key_in in key_t) return key_t is
  begin
    return lower(key_in);
  end;

  /* 
  Read all the NLS parameters and gives a key/value map back to the caller 
  */
  function read_params return map_aat is
    type nls_parameters_ntt is table of v$nls_parameters%rowtype;
    nls_parameters_t        nls_parameters_ntt;
    l_map                   map_aat;
  begin
    -- Read the whole v$nls_parameters view into a nested table...
    select p.*
    bulk collect into nls_parameters_t
    from v$nls_parameters p ;
    
    -- .. then polulate the key/value (map) structure...
    for i in nls_parameters_t.FIRST .. nls_parameters_t.LAST loop
      l_map(to_key(nls_parameters_t(i).parameter)) := nls_parameters_t(i).value;
    end loop;
    return l_map;
  end;


  /* 
  Issue an alter session statement. Notice this routine is public in order 
  to provide a convenient way to issue an alter session within a PL/SQL block
  */
  procedure altersession(
    paramname_in   in varchar2
  , value_in       in varchar2
  ) is
    l_stmt    varchar2(1000);
  begin
    l_stmt := 'ALTER SESSION SET '||paramname_in||' = '''||value_in||'''';
    execute immediate l_stmt;
  end;


  /*
  Restore the session parameters to the configuration set in the given map.
  */
  procedure set_session(map_in  in map_aat) is
    l_pname      key_t;
  begin
    l_pname := map_in.FIRST;
    while ( l_pname is not null ) loop
      begin
        altersession(l_pname, map_in(l_pname));
      exception
        when others then
        -- Notice there are a few parameters in the `v$nls_parameters`
        -- view that cannot be altered via `ALTER SESSION` but only via
        -- `ALTER SYSTEM`. In case an attempt to modify those parameters
        -- is made a `ORA-00922 invalid option` exception will be raised.
        -- This module is ment to restore the session to a previous state,
        -- so it's required to trap the aformentioned exception and continue
        -- to cycle on the parameters to set back to the previous state.
          if (sqlcode = -00922) then
            null;
          else
            raise;
          end if;  
      end;  
      l_pname := map_in.NEXT(l_pname);
    end loop;
  end;
  
  /* 
  Save the current session settings into the settings stack 
  */
  procedure save is
    l_map  map_aat;
  begin
    -- Read the parameters...
    l_map := read_params();
    -- ... and add the returned map to the stack
    push(l_map);
  end;
  
  
  /* 
  Restore the current session back to the last settings saved 
  */
  procedure flashback is
    l_map  map_aat;
  begin
    -- Get the last saved configuration from the stack...
    l_map := pop();
    -- ... and set the current session to that configuration
    set_session(l_map);
  exception
    when no_data_found then
    -- A call to `pop` may raise a no_data_found exception
    -- in case the stack is empty.
    -- May this ever happen, means the session has already
    -- been set back to its inital state, so there's
    -- nothing left to do.
      null; 
  end;
  

end;
/