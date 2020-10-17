select 'creare or replace public synonym '||o.object_name||' for '||o.owner||'.'||o.object_name stmt 
from
(
 select distinct o.owner,  object_name 
    from dba_objects o 
    where owner like  ( 'EFIS%')
    and object_type in ('TABLE', 'VIEW', 'PACKAGE' ,'SEQUENCE')
    and exists 
    (
    select 1 from dba_tab_privs p where p.owner= o.owner 
    and p.table_name = o.object_name 
    )
) o
/


select * from dba_tab_privs p where table_name='OP_DET_TEMPLATE_SEQ'


-- synonym all
begin
 for rec  in 
  (
    select 'create or replace public synonym '||o.object_name||' for '||o.owner||'.'||o.object_name stmt 
    from
    (
     select distinct o.owner,  object_name 
        from dba_objects o 
        where owner like  ( 'EFIS%')
        and object_type in ('TABLE', 'VIEW', 'PACKAGE' ,'SEQUENCE')
        and exists 
        (
        select 1 from dba_tab_privs p where p.owner= o.owner 
        and p.table_name = o.object_name 
        )
    ) o
  ) loop
  dbms_output.put_line(rec.stmt); 
   execute immediate rec.stmt;  
  end loop;
end;
/


select apex_string.format ('creare or replace public synonym %s for %s.%s',1,2,3) from dual


select  apex_string.format('%s+%s=%s', 1, 2, 'three') from dual