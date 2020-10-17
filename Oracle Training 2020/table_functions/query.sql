/* And in 12.2 and higher, no need for TABLE */

select * from get_customers('A%');


/* 
 No direct use in PL/SQL:

ORA-06550: line 1, column 10:
PLS-00653: aggregate/table functions are not allowed in PL/SQL scope

 */

declare 
 ct customer_nt ;
begin
 ct := get_customers('A%');
 dbms_output.put_line('ct.count='||ct.count); 
end; 
/

/* use via sql and object type in a query*/ 


declare 
 ct customer_nt ;
begin
  select customer_ot 
                (
                  CUSTOMER_ID     ,
                  CUSTOMER_NAME   ,
                  IS_ACTIVE_FLAG  ,
                  EFFECTIVE_DATE  ,
                  END_DATE        ,
                  CREATE_DATE     ,
                  UPDATE_DATE     
                ) c
    bulk collect into ct from  get_customers('A%');
 dbms_output.put_line('ct.count='||ct.count); 
end; 
/

/* with local types */

declare 
 cursor c1 is select * from  get_customers('');
 type crt is table of c1%rowtype;
 ct crt ;
begin
  select *
    bulk collect into ct from  get_customers('A%');
 dbms_output.put_line('ct.count='||ct.count); 
end; 
/


/* session pga */

   SELECT st.VALUE
        FROM v$mystat st, v$statname sn
       WHERE st.statistic# = sn.statistic# AND sn.name = 'session pga memory';
/
 
/* On Autonomus - make sure user has select_catalog_role */
       
grant select_catalog_role to bc
/


/*
The NO_DATA_NEEDED Exception
Sometimes (as in the performance and memory test in the previous section) you will want to terminate the pipelined table function before all rows have been piped back. Oracle will then raise the NO_DATA_NEEDED exception. This will terminate the function, but will not terminate the SELECT statement that called it. You do need to explicitly handle this exception if either of the following applies:

You include an OTHERS exception handler in a block that includes a PIPE ROW statement.
Your code that feeds a PIPE ROW statement must be followed by a clean-up procedure. Typically, the clean-up procedure releases resources that the code no longer needs.
Let's explore this behavior in more detail. In this first section, I only use 1 row, so Oracle raises NO_DATA_NEEDED, but no exception is raised.
*/


CREATE OR REPLACE FUNCTION strings
   RETURN strings_t
   PIPELINED
   AUTHID DEFINER
IS
BEGIN
   PIPE ROW (1);
   PIPE ROW (2);
   RETURN;
EXCEPTION
   WHEN no_data_needed
   THEN
      RAISE;
   WHEN OTHERS
   THEN
      /* Clean up code here! */
      RAISE;
END;
/ 
     

SELECT object_name, object_type
  FROM user_objects
 WHERE object_type IN ('TYPE', 'PACKAGE', 'PACKAGE BODY')
 /
 
 /* Local package type */
 
 select * from pkg.get_customers('B%') 
 /
 
 --- Poly ( PTF)
 --- https://oracle-base.com/articles/18c/polymorphic-table-functions-18c
 
 select * from poly_func(customer)
-- order by 3
 /
 
 where rownum < 10;