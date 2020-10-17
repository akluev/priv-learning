create or replace type customer_ot as object
(
  CUSTOMER_ID     INTEGER,
  CUSTOMER_NAME   VARCHAR2(100 BYTE),
  IS_ACTIVE_FLAG  INTEGER,
  EFFECTIVE_DATE  DATE,
  END_DATE        DATE,
  CREATE_DATE     DATE,
  UPDATE_DATE     DATE
)
/


create or replace type customer_nt as table of customer_ot
/ 
