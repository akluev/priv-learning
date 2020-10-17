/*
ORA-65114: space usage in container is too high
*/


select 
round(( sum(a.bytes) over())/(1024*1024*1024),2) total_gb,
owner, segment_name, segment_type, partition_name, round(bytes/(1024*1024),2) mb  
from dba_segments a 
where --owner like 'EFIS%'
  tablespace_name = 'DATA'  
--  tablespace_name = 'SYSAUX'  
--and segment_type ='TABLE PARTITION'
--and bytes >= 1024*1024*20
order by bytes desc 
/

select * from dba_lobs l 
where L.SEGMENT_NAME = 'SYS_LOB0000008630C00008$$'


--- HWM 

--- tablespace sizes 

select 
round(( sum(a.user_bytes) over())/(1024*1024*1024),2) total_gb,
round(a.user_bytes/(1024*1024*1024),2) gb,  
a.* from dba_data_files a
where tablespace_name != 'SAMPLESCHEMA'

--- real highwater 
select a.tablespace_name
,a.file_name
,(b.maximum+c.blocks-1)*d.db_block_size highwater
from dba_data_files a
,(select file_id,max(block_id) maximum
  from dba_extents
  group by file_id
 ) b
,dba_extents c
,(select value db_block_size
from v$parameter
where name='db_block_size') d
where a.file_id = b.file_id
and c.file_id = b.file_id
and c.block_id = b.maximum
order by a.tablespace_name,a.file_name 
/


--- Check objects above desired HWM 

select 
 a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, max(hwm_gb) hwm_gb, max(hwm_mb) hwm_mb 
from 
(
select
((block_id + blocks-1) * 8)/(1024*1024) hwm_gb, 
((block_id + blocks-1) * 8)/(1024) hwm_mb, 
a.* from dba_extents a where tablespace_name = 'DATA'
order by block_id desc
) a,
dba_segments b  
where hwm_gb > 5
and a.segment_name  = b.segment_name
and A.OWNER = b.owner 
and nvl(a.partition_name,'x') = nvl(b.partition_name,'x') 
group by a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE
order by hwm_gb desc
/






---- MOVE TABLES and INDEXES
declare 
 l_found  boolean := true;
begin
 while l_found loop
 l_found := false; 
 for rec in 
  (
    select 
    case when segment_type = 'TABLE' 
     then 
      'ALTER table '||owner||'.'||segment_name||' move /* online */ tablespace '||tablespace_name  
     else 
      'ALTER index '||owner||'.'||segment_name||' rebuild tablespace '||tablespace_name
     end 
      stmt, 
    a.* 
    from 
     (
      select 
         a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name, max(hwm_gb) hwm_gb 
        from 
        (
        select
        ((block_id + blocks-1) * 8)/(1024*1024) hwm_gb, 
        a.* from dba_extents a where tablespace_name = 'DATA'
        order by block_id desc
        ) a,
        dba_segments b  
        where hwm_gb > 7
        and a.segment_name  = b.segment_name
        and A.OWNER = b.owner 
        and nvl(a.partition_name,'x') = nvl(b.partition_name,'x') 
        group by a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name
     ) a
    where
    --owner like 'EFIS%' 
    1 =1
    and segment_type in ('TABLE', 'INDEX')
    --and bytes >= 1024*1024*20
    order by hwm_gb desc
  ) loop
   begin 
    l_found := true;  
    execute immediate rec.stmt;
   exception
    when others then 
     dbms_output.put_line(sqlerrm);  
   end;   
 end loop; 
end loop;  
end;
/

--- rebuild indexes
begin
 for rec in 
  (
    select 'alter index '||owner||'.'||index_name||' rebuild' stmt from dba_indexes where status = 'UNUSABLE'
  ) loop
   begin 
    execute immediate rec.stmt;
   exception
    when others then 
     dbms_output.put_line(sqlerrm);  
   end;   
 end loop; 
end;
/

--- MOVE INDEXES

declare 
 l_found  boolean := true;
begin
 while l_found loop
 l_found := false; 
 for rec in 
  (
    select 
    'ALTER index '||owner||'.'||segment_name||' rebuild tablespace '||tablespace_name  stmt, 
    a.* 
    from 
     (
      select 
         a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name, max(hwm_gb) hwm_gb 
        from 
        (
        select
        ((block_id + blocks-1) * 8)/(1024*1024) hwm_gb, 
        a.* from dba_extents a where tablespace_name = 'DATA'
        order by block_id desc
        ) a,
        dba_segments b  
        where hwm_gb > 7
        and a.segment_name  = b.segment_name
        and A.OWNER = b.owner 
        and nvl(a.partition_name,'x') = nvl(b.partition_name,'x') 
        group by a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name
     ) a
    where
    --owner like 'EFIS%' 
    1 =1
    and segment_type ='INDEX'
    --and bytes >= 1024*1024*20
    order by hwm_gb desc
  ) loop
   begin 
 l_found := true; 
    execute immediate rec.stmt;
   exception
    when others then 
     dbms_output.put_line(sqlerrm);  
   end;   
  end loop; 
 end loop; 
end;
/

-- ALTER TABLE tab1 MOVE LOB(lob_column_name) STORE AS (TABLESPACE new_ts);

--- MOVE LOBS
declare 
 l_found  boolean := true;
begin
 while l_found loop
 l_found := false; 
 for rec in 
  (
    select distinct a.owner, 
    --a.segment_name, 
    a.tablespace_name, b.table_name, b.column_name,  
    --hwm_gb,
    'ALTER table '||a.owner||'.'||table_name||' move lob ( '||column_name||') store as  ( tablespace '||a.tablespace_name||')'  stmt1 ,
    'ALTER table '||a.owner||'.'||table_name||' move  tablespace '||a.tablespace_name  stmt2 
    from
     (  
      select 
          a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name, max(hwm_gb) hwm_gb 
        from 
        (
        select
        ((block_id + blocks-1) * 8)/(1024*1024) hwm_gb, 
        a.* from dba_extents a where tablespace_name = 'DATA'
        order by block_id desc
        ) a,
        dba_segments b  
        where hwm_gb > 7
        and a.segment_name  = b.segment_name
        and A.OWNER = b.owner 
        and nvl(a.partition_name,'x') = nvl(b.partition_name,'x') 
        group by a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name
     ) a,
     dba_lobs b
    where
     1=1
    --owner like 'EFIS%' 
        and a.segment_name  = b.segment_name
        and A.OWNER = b.owner 
--    and a.segment_type =  'LOBSEGMENT'
  ) loop
   begin 
    l_found := true; 
    execute immediate rec.stmt2;
    execute immediate rec.stmt1;
   exception
    when others then 
     dbms_output.put_line(sqlerrm);  
   end;   
 end loop; 
 end loop; 
end;
/


    select distinct a.owner, --a.segment_name, 
    a.tablespace_name, b.table_name, b.column_name,  
    --hwm_gb,
--    'ALTER table '||a.owner||'.'||table_name||' move lob ( '||column_name||') store as  ( tablespace '||a.tablespace_name||')'  stmt 
    'ALTER table '||a.owner||'.'||table_name||' move  tablespace '||a.tablespace_name  stmt 
    from
     (  
      select 
          a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name, max(hwm_gb) hwm_gb 
        from 
        (
        select
        ((block_id + blocks-1) * 8)/(1024*1024) hwm_gb, 
        a.* from dba_extents a where tablespace_name = 'DATA'
        order by block_id desc
        ) a,
        dba_segments b  
        where hwm_gb > 7
        and a.segment_name  = b.segment_name
        and A.OWNER = b.owner 
        and nvl(a.partition_name,'x') = nvl(b.partition_name,'x') 
        group by a.owner, a.segment_name, A.PARTITION_NAME,  b.SEGMENT_TYPE, a.tablespace_name
     ) a,
     dba_lobs b
    where
     1=1
    --owner like 'EFIS%' 
        and a.segment_name  = b.segment_name
        and A.OWNER = b.owner 
--    and a.segment_type =  'LOBSEGMENT'




ALTER table EFIS.OP_SECURITY_REQUEST move lob ( SYSTEM_NOTE) store as  ( tablespace DATA) online
/

ALTER table EFIS.OP_SECURITY_REQUEST move  tablespace DATA online
/


select * from dba_lobs a where  A.SEGMENT_NAME ='SYS_LOB0000041354C00031$$'





select * 
from dba_segments a 
where
TABLESPACE_NAME ='DATA' 
--owner like 'EFIS%' 
and segment_name  like 'QC%'
--and bytes >= 1024*1024*20
order by HEADER_BLOCK desc 


ALTER INDEX bc.qc_pk REBUILD
/ 

ALTER table bc.paint_qc move tablespace data
/ 

select * from dba_indexes where status = 'UNUSABLE'

alter taBLE EFIS.SUBMISSION_LINE SHRINK SPACE CASCADE
/



select 
 'alter table '||table_owner||'.'||table_name||' drop partition '||partition_name||' update indexes' stmt 
from dba_tab_partitions
where table_owner like 'EFIS%' 
and segment_created='YES'
/

alter table EFIS.TCAR_ASSET drop primary key cascade
/

begin
 for rec in 
  (
    select 
     'alter table '||table_owner||'.'||table_name||' drop partition '||partition_name||' update indexes' stmt 
    from dba_tab_partitions
    where table_owner like 'EFIS%' 
    and segment_created='YES'
  ) loop
   begin 
    execute immediate rec.stmt;
   exception
    when others then 
     dbms_output.put_line(sqlerrm);  
   end;   
 end loop; 
end;
/


alter table EFIS_DW.LD_EDUMAIN drop partition SYS_P15959 update indexes
/


alter table  efis.CO_ONSIS_DATA drop primary key drop index 
/

select 'alter table '||owner||'.'||segment_name||' drop partition '||partition_name||' update indexes' stmt 
from dba_segments 
where owner like 'EFIS%' 
and segment_type ='TABLE PARTITION'
and bytes >= 1024*1024*20
order by bytes desc 
/


begin
 for rec in 
  (
      select 'alter table '||owner||'.'||segment_name||' drop partition '||partition_name||' update indexes' stmt 
    from dba_segments 
    where owner like 'EFIS%' 
    and segment_type ='TABLE PARTITION'
    and bytes >= 1024*1024*20
    order by bytes desc 
  ) loop
   execute immediate rec.stmt;
 end loop; 
end;
/

ALTER TABLESPACE data COALESCE
/



select *  FROM dba_free_space where tablespace_name ='DATA'
order by block_id desc
/

PURGE DBA_RECYCLEBIN
/


select property_name, property_value, property_value/(1024*1024*1024) from database_properties where property_name ='MAX_PDB_STORAGE';


ALTER DATABASE DATAFILE '+DATA/FEJ41POD/A52EBE2EC899CDFBE0534D10000AEF4E/DATAFILE/data.2631.1040446835'
   RESIZE 5G
/   
  
