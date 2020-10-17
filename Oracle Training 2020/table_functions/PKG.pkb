CREATE OR REPLACE PACKAGE pkg
   AUTHID DEFINER
AS
/* Internal TYPE can be used */

   TYPE customer_pt IS TABLE OF customer%ROWTYPE;

   function get_customers ( p_name varchar2 ) 
   return customer_pt  pipelined;

END;
/


CREATE OR REPLACE PACKAGE BODY pkg
AS
/* Internal TYPE can be used */


   function get_customers ( p_name varchar2 ) 
   return customer_pt  pipelined
  is 
   begin
  for rec in (select * from customer c 
              where C.CUSTOMER_NAME like p_name) loop 
 
    pipe row (rec);
  end loop;
  return;
 end;
 

END;
