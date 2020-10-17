create or replace function get_customers ( p_name varchar2 ) 
return customer_nt  pipelined
as
 begin
  for rec in (select 
              customer_ot 
                (
                  CUSTOMER_ID     ,
                  CUSTOMER_NAME   ,
                  IS_ACTIVE_FLAG  ,
                  EFFECTIVE_DATE  ,
                  END_DATE        ,
                  CREATE_DATE     ,
                  UPDATE_DATE     
                ) c
              from customer c 
              where C.CUSTOMER_NAME like p_name) loop 
 
    pipe row (rec.c);
  end loop;
  return;
 end;
/   
 