/*
 Polymprphic table functions (PTF)
*/

CREATE OR REPLACE PACKAGE poly_pkg AUTHID DEFINER
AS
  FUNCTION describe (p_tbl IN OUT DBMS_TF.TABLE_T )
           RETURN DBMS_TF.DESCRIBE_T;
  PROCEDURE fetch_rows;
END;
/



CREATE OR REPLACE PACKAGE BODY poly_pkg AS

  FUNCTION describe (p_tbl IN OUT DBMS_TF.TABLE_T )
           RETURN DBMS_TF.DESCRIBE_T 
  AS
    v_new_col1 DBMS_TF.COLUMN_METADATA_T;
    v_new_cols DBMS_TF.COLUMNS_NEW_T;
  BEGIN
    v_new_col1  := DBMS_TF.COLUMN_METADATA_T( type    => DBMS_TF.TYPE_VARCHAR2,
                                              name    => 'ADDED_COL',
                                              max_len => 15 );
    v_new_cols := DBMS_TF.COLUMNS_NEW_T( 1 => v_new_col1 );
    RETURN DBMS_TF.DESCRIBE_T ( new_columns => v_new_cols );
  END;

  PROCEDURE fetch_rows IS
    v_rowset DBMS_TF.ROW_SET_T;
    v_added  DBMS_TF.tab_varchar2_t;
    v_cnt int;
  BEGIN
  DBMS_TF.GET_ROW_SET(v_rowset, row_count => v_cnt);
    for i in 1.. v_cnt  loop
     v_added(i) := 'Added Col '||i;
    end loop; 
    DBMS_TF.PUT_COL( 1,v_added);
  END;
END;
/

