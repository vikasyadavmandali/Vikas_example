To check Tablespace free space:
SELECT TABLESPACE_NAME, SUM(BYTES/1024/1024) "Size (MB)"  FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME;

To check Tablespace by datafile:
SELECT tablespace_name, File_id, SUM(bytes/1024/1024)"Size (MB)" FROM DBA_FREE_SPACE
group by tablespace_name, file_id;
To Check Tablespace used and free space %:
SELECT /* + RULE */  df.tablespace_name "Tablespace",
df.bytes / (1024 * 1024) "Size (MB)", SUM(fs.bytes) / (1024 * 1024) "Free (MB)",
Nvl(Round(SUM(fs.bytes) * 100 / df.bytes),1) "% Free",
Round((df.bytes - SUM(fs.bytes)) * 100 / df.bytes) "% Used"
FROM dba_free_space fs,
(SELECT tablespace_name,SUM(bytes) bytes
FROM dba_data_files
GROUP BY tablespace_name) df
WHERE fs.tablespace_name (+)  = df.tablespace_name
GROUP BY df.tablespace_name,df.bytes
UNION ALL
SELECT /* + RULE */ df.tablespace_name tspace,
fs.bytes / (1024 * 1024), SUM(df.bytes_free) / (1024 * 1024),
Nvl(Round((SUM(fs.bytes) - df.bytes_used) * 100 / fs.bytes), 1),
Round((SUM(fs.bytes) - df.bytes_free) * 100 / fs.bytes)
FROM dba_temp_files fs,
(SELECT tablespace_name,bytes_free,bytes_used
 FROM v$temp_space_header
GROUP BY tablespace_name,bytes_free,bytes_used) df
 WHERE fs.tablespace_name (+)  = df.tablespace_name
 GROUP BY df.tablespace_name,fs.bytes,df.bytes_free,df.bytes_used
 ORDER BY 4 DESC;
--or--
Select t.tablespace, t.totalspace as " Totalspace(MB)", round((t.totalspace-fs.freespace),2) as "Used Space(MB)", fs.freespace as "Freespace(MB)", round(((t.totalspace-fs.freespace)/t.totalspace)*100,2) as "% Used", round((fs.freespace/t.totalspace)*100,2) as "% Free" from (select round(sum(d.bytes)/(1024*1024)) as totalspace, d.tablespace_name tablespace from dba_data_files d group by d.tablespace_name) t, (select round(sum(f.bytes)/(1024*1024)) as freespace, f.tablespace_name tablespace from dba_free_space f group by f.tablespace_name) fs where t.tablespace=fs.tablespace order by t.tablespace;
Tablespace (File wise) used and Free space
SELECT SUBSTR (df.NAME, 1, 40) file_name,dfs.tablespace_name, df.bytes / 1024 / 1024 allocated_mb, ((df.bytes / 1024 / 1024) -  NVL (SUM (dfs.bytes) / 1024 / 1024, 0)) used_mb,
NVL (SUM (dfs.bytes) / 1024 / 1024, 0) free_space_mb
FROM v$datafile df, dba_free_space dfs
WHERE df.file# = dfs.file_id(+)
GROUP BY dfs.file_id, df.NAME, df.file#, df.bytes,dfs.tablespace_name
ORDER BY file_name;
To check Growth rate of  Tablespace
Note: The script will not show the growth rate of the SYS, SYSAUX Tablespace. T
he script is used in Oracle version 10g onwards.
SELECT TO_CHAR (sp.begin_interval_time,'DD-MM-YYYY') days,
 ts.tsname , max(round((tsu.tablespace_size* dt.block_size )/(1024*1024),2) ) cur_size_MB,
 max(round((tsu.tablespace_usedsize* dt.block_size )/(1024*1024),2)) usedsize_MB
 FROM DBA_HIST_TBSPC_SPACE_USAGE tsu, DBA_HIST_TABLESPACE_STAT ts, DBA_HIST_SNAPSHOT sp,
 DBA_TABLESPACES dt
 WHERE tsu.tablespace_id= ts.ts# AND tsu.snap_id = sp.snap_id
 AND ts.tsname = dt.tablespace_name AND ts.tsname NOT IN ('SYSAUX','SYSTEM')
 GROUP BY TO_CHAR (sp.begin_interval_time,'DD-MM-YYYY'), ts.tsname
 ORDER BY ts.tsname, days;
List all Tablespaces with free space < 10% or full space> 90%
Select a.tablespace_name,sum(a.tots/1048576) Tot_Size,
sum(a.sumb/1024) Tot_Free, sum(a.sumb)*100/sum(a.tots) Pct_Free,
ceil((((sum(a.tots) * 15) - (sum(a.sumb)*100))/85 )/1048576) Min_Add
from (select tablespace_name,0 tots,sum(bytes) sumb
from dba_free_space a
group by tablespace_name
union
Select tablespace_name,sum(bytes) tots,0 from
dba_data_files
group by tablespace_name) a
group by a.tablespace_name
having sum(a.sumb)*100/sum(a.tots) < 10
order by pct_free;
Script to find all object Occupied space for a Tablespace
Select OWNER, SEGMENT_NAME, SUM(BYTES)/1024/1024 "SZIE IN MB" from dba_segments
where TABLESPACE_NAME = 'SDH_HRMS_DBF'
group by OWNER, SEGMENT_NAME;
Which schema are taking how much space
Select obj.owner "Owner", obj_cnt "Objects", decode(seg_size, NULL, 0, seg_size) "size MB"
from (select owner, count(*) obj_cnt from dba_objects group by owner) obj,
 (select owner, ceil(sum(bytes)/1024/1024) seg_size  from dba_segments group by owner) seg
  where obj.owner  = seg.owner(+)
  order    by 3 desc ,2 desc, 1;
To Check Default Temporary Tablespace Name:
Select * from database_properties where PROPERTY_NAME like '%DEFAULT%';
To know default and Temporary Tablespace for particualr User:
Select username,temporary_tablespace,default_tablespace from dba_users where username='HRMS';
To know Default Tablespace for All User:
Select default_tablespace,temporary_tablespace,username from dba_users;
To Check Datafiles used and Free Space:
SELECT SUBSTR (df.NAME, 1, 40) file_name,dfs.tablespace_name, df.bytes / 1024 / 1024 allocated_mb,
((df.bytes / 1024 / 1024) -  NVL (SUM (dfs.bytes) / 1024 / 1024, 0)) used_mb,
NVL (SUM (dfs.bytes) / 1024 / 1024, 0) free_space_mb
FROM v$datafile df, dba_free_space dfs
WHERE df.file# = dfs.file_id(+)
GROUP BY dfs.file_id, df.NAME, df.file#, df.bytes,dfs.tablespace_name
ORDER BY file_name;
To check Used free space in Temporary Tablespace:
SELECT tablespace_name, SUM(bytes_used/1024/1024) USED, SUM(bytes_free/1024/1024) FREE
FROM   V$temp_space_header GROUP  BY tablespace_name;
SELECT   A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
         ( SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;
Sort (Temp) space used by Session
SELECT   S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, P.spid, S.module, S.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used,
T.tablespace, COUNT(*) sort_ops
FROM v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE T.session_addr = S.saddr
AND S.paddr = P.addr AND T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module, S.program, TBS.block_size, T.tablespace ORDER BY sid_serial;
Sort (Temp) Space Usage by Statement
SELECT S.sid || ',' || S.serial# sid_serial, S.username, T.blocks * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,T.sqladdr address, Q.hash_value, Q.sql_text
FROM v$sort_usage T, v$session S, v$sqlarea Q, dba_tablespaces TBS
WHERE T.session_addr = S.saddr
AND T.sqladdr = Q.address (+) AND T.tablespace = TBS.tablespace_name
ORDER BY S.sid;
Who is using which UNDO or TEMP segment?
SELECT TO_CHAR(s.sid)||','||TO_CHAR(s.serial#) sid_serial,
NVL(s.username, 'None') orauser,s.program, r.name undoseg,
t.used_ublk * TO_NUMBER(x.value)/1024||'K' "Undo"
FROM sys.v_$rollname r, sys.v_$session s, sys.v_$transaction t, sys.v_$parameter   x
WHERE s.taddr = t.addr AND r.usn   = t.xidusn(+) AND x.name  = 'db_block_size';
Who is using the Temp Segment?
SELECT b.tablespace, ROUND(((b.blocks*p.value)/1024/1024),2)||'M' "SIZE",
a.sid||','||a.serial# SID_SERIAL, a.username, a.program
FROM sys.v_$session a,
sys.v_$sort_usage b, sys.v_$parameter p
WHERE p.name  = 'db_block_size' AND a.saddr = b.session_addr
ORDER BY b.tablespace, b.blocks;
Total Size and Free Size of Database:
Select round(sum(used.bytes) / 1024 / 1024/1024 ) || ' GB' "Database Size",
round(free.p / 1024 / 1024/1024) || ' GB' "Free space"
from (select bytes from v$datafile
      union all
      select bytes from v$tempfile
      union all
      select bytes from v$log) used,   
(select sum(bytes) as p from dba_free_space) free
group by free.p;
To find used space of datafiles:
SELECT SUM(bytes)/1024/1024/1024 "GB" FROM dba_segments;
IO status of all of the datafiles in database:
WITH total_io AS
     (SELECT SUM (phyrds + phywrts) sum_io
        FROM v$filestat)
SELECT   NAME, phyrds, phywrts, ((phyrds + phywrts) / c.sum_io) * 100 PERCENT,
         phyblkrd, (phyblkrd / GREATEST (phyrds, 1)) ratio
    FROM SYS.v_$filestat a, SYS.v_$dbfile b, total_io c
   WHERE a.file# = b.file#
ORDER BY a.file#;
Displays Smallest size the datafiles can shrink to without a re-organize.
SELECT a.tablespace_name, a.file_name, a.bytes AS current_bytes, a.bytes - b.resize_to AS shrink_by_bytes, b.resize_to AS resize_to_bytes
FROM   dba_data_files a, (SELECT file_id, MAX((block_id+blocks-1)*&v_block_size) AS resize_to
        FROM   dba_extents
        GROUP by file_id) b
        WHERE  a.file_id = b.file_id
        ORDER BY a.tablespace_name, a.file_name;
Scripts to Find datafiles increment details:
Select  SUBSTR(fn.name,1,DECODE(INSTR(fn.name,'/',2),0,INSTR(fn.name,':',1),INSTR(fn.name,'/',2))) mount_point,tn.name   tabsp_name,fn.name   file_name,
ddf.bytes/1024/1024 cur_size, decode(fex.maxextend,
NULL,ddf.bytes/1024/1024,fex.maxextend*tn.blocksize/1024/1024) max_size,
nvl(fex.maxextend,0)*tn.blocksize/1024/1024 - decode(fex.maxextend,NULL,0,ddf.bytes/1024/1024)   unallocated,nvl(fex.inc,0)*tn.blocksize/1024/1024  inc_by
from  sys.v_$dbfile fn,    sys.ts$  tn,    sys.filext$ fex,    sys.file$  ft,    dba_data_files ddf
where    fn.file# = ft.file# and  fn.file# = ddf.file_id
and    tn.ts# = ft.ts# and    fn.file# = fex.file#(+)
order by 1;
