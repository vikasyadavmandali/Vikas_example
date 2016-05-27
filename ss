spool sql_with_more_than_1plan.txt
set lines 220 pages 9999 trimspool on
set numformat 999,999,999
column plan_hash_value format 99999999999999
column min_snap format 999999
column max_snap format 999999
column min_avg_ela format 999,999,999,999,999
column avg_ela format 999,999,999,999,999
column ela_gain format 999,999,999,999,999
select sql_id,
       min(min_snap_id) min_snap,
       max(max_snap_id) max_snap,
       max(decode(rw_num,1,plan_hash_value)) plan_hash_value,
       max(decode(rw_num,1,avg_ela)) min_avg_ela,
       avg(avg_ela) avg_ela,
       avg(avg_ela) - max(decode(rw_num,1,avg_ela)) ela_gain,
       -- max(decode(rw_num,1,avg_buffer_gets)) min_avg_buf_gets,
       -- avg(avg_buffer_gets) avg_buf_gets,
       max(decode(rw_num,1,sum_exec))-1 min_exec,
       avg(sum_exec)-1 avg_exec
from (
  select sql_id, plan_hash_value, avg_buffer_gets, avg_ela, sum_exec,
         row_number() over (partition by sql_id order by avg_ela) rw_num , min_snap_id, max_snap_id
  from
  (
    select sql_id, plan_hash_value , sum(BUFFER_GETS_DELTA)/(sum(executions_delta)+1) avg_buffer_gets,
    sum(elapsed_time_delta)/(sum(executions_delta)+1) avg_ela, sum(executions_delta)+1 sum_exec,
    min(snap_id) min_snap_id, max(snap_id) max_snap_id
    from dba_hist_sqlstat a
    where exists  (
       select sql_id from dba_hist_sqlstat b where a.sql_id = b.sql_id
         and  a.plan_hash_value != b.plan_hash_value
         and  b.plan_hash_value > 0)
    and plan_hash_value > 0
    group by sql_id, plan_hash_value
    order by sql_id, avg_ela
  )
  order by sql_id, avg_ela
  )
group by sql_id
having max(decode(rw_num,1,sum_exec)) > 1
order by 7 desc
/
spool off
clear columns
set numformat 9999999999

SQL_ID        MIN_SNAP MAX_SNAP PLAN_HASH_VALUE          MIN_AVG_ELA              AVG_ELA             ELA_GAIN     MIN_EXEC     AVG_EXEC
------------- -------- -------- --------------- -------------------- -------------------- -------------------- ------------ ------------
ba42qdzhu5jb0    65017    67129      2819751536       11,055,899,019       90,136,403,552       79,080,504,532           12            4
2zm7y3tvqygx5    65024    67132       362220407       14,438,575,143       34,350,482,006       19,911,906,864            1            3
74j7px7k16p6q    65029    67134      1695658241       24,049,644,247       30,035,372,306        5,985,728,059           14            7
dz243qq1wft49    65030    67134      3498253836        1,703,657,774        7,249,309,870        5,545,652,097            1            2
