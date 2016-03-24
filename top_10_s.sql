Some times you may need to get the top sqls from the history for the proactive tuning purpose. The below information will help you find the top SQLs from the past history ( 7 days).

Run the below query to get the top SQL queries based on CPU and Elapsed time ranking. Ranked 1 being the top cpu consuming query/ top elapsed time taken.

Query to know the ranking:
==================================================================


select * from 
(select s.sql_id, RANK() OVER (ORDER BY (max(s.CPU_TIME_TOTAL/s.executions_total)) DESC) cpu_rank,
RANK() OVER (ORDER BY (max(s.ELAPSED_TIME_TOTAL/s.EXECUTIONS_TOTAL)) DESC) elapsed_rank
from
   dba_hist_sqlstat s,
   dba_hist_snapshot sn
where
   sn.begin_interval_time between to_date('06-aug-2014 0001','dd-mon-yyyy hh24mi')
and
   to_date('13-aug-2014 0600','dd-mon-yyyy hh24mi')
and
   sn.snap_id=s.snap_id and s.executions_total >0
group by
   s.sql_id
   ) where cpu_rank <=100 and elapsed_rank<=100;

  Query to get the sql text based on the ranking given above:
==========================================================


set long 99999999999
set linesize 200
set pagesize 150
select sql_id,sql_text from dba_hist_sqltext where sql_id in ( select sql_id from (select s.sql_id, RANK() OVER (ORDER BY (max(s.CPU_TIME_TOTAL/s.executions_total)) DESC) cpu_rank,
RANK() OVER (ORDER BY (max(s.ELAPSED_TIME_TOTAL/s.executions_total)) DESC) elapsed_rank
from
   dba_hist_sqlstat s,
   dba_hist_snapshot sn
where
   sn.begin_interval_time between to_date('05-oct-2012 0001','dd-mon-yyyy hh24mi')
and
   to_date('12-oct-2012 0600','dd-mon-yyyy hh24mi')
and
   sn.snap_id=s.snap_id and s.s.executions_total >0
group by
   s.sql_id
   ) where cpu_rank <=100 and elapsed_rank<=100);






The sample output will be as below: based on the query ranking.


SQLID                                                   CPU RANK                 ELAPSED TIME RANK
gmm656xh2884y          1            1
7up1u72k4zun0          2            4
8fm60rmuw4wrt          3            3
86k5ya80n9n1k          4            5
1hbzk5natb6r9          5            2
4dphbmad3m9ad          6            6
afan5v28p4365          7            7
7wy6kypqu1awn          8           16
89f3t81hvywkz          9           11
fr4hyknbg7zxp         10            8
gz681zb2cd9sq         11           14
9xagqmxx3ut1g         12           13
ffw986majuc95         13           15
0d6y3jbjcwsvv         14           10
9wgxjr79xg9qm         15           20
3q0s90gz65w3r         16           17
aat38db829q5x         17           38
3779yab460hb5         18           21
gtm6vyfuy51a4         19           12
3vs4y442rc0by         20            9
b3up7jgz76m41         21           29
5x0dh99uwqd53         22           24
aawfz3yakqbfh         23           27
496pzxrnrn03y         24           34
4r8jrhb7q2jfp         25           28
cd20fdgw4jqb2         26           18
fc9z69r8ngjy5         27           43
fk6j30k2uxs84         28           19
7tudd6h1rm4zx         29           33
91zaypwh5y5zg         30           39
718cgu0qrhzpz         31           57
35p9tbp6m42wq         32           61
9p51wy69m82yd         33           84
du365zx8scxf6         34           23
4g0rdzduz5cbq         35           49
30y3k65cvu18g         36           48
1mvc1x217yamd         37           45
3aupzsqhq5wjg         38           37
14pj5hj184g0x         39           26
2zs24md902gvk         41           32
b6usrg82hwsa3         42           46
7tdr83rw4xz0m         43           30
fbx4321jwsbgc         44           53
6ssc6kbz2xauz         45           83
aabzaygbkv0cj         46           59
cgc94fct65433         47           51
dtu9ykbgh380k         48           52
2v9rg593vkq5x         50           91
1nny910vab4hj         52           63
c6dbk3jtafmf7         53           67
dnpp3akugkk9n         54           64
3pf39b8mdykxk         56           22
cjwbmcj37g2xw         57           73
2mhwrbdskbj1f         59           62
0x61tfsf13221         61           94
93ywv5gmrnk90         62           92
brpf4a37mz00r         63           79
39z4y031pyy7x         64           98
a8q1k8hwruh4v         66           81
6mcpb06rctk0x         67           68
9yvphgs9mx1t7         68           95
crpnhdgjzxdp2         73           97
362kvaybr3mhy         75           99
a77n3yysmb9my         76           35
4mw5mr508xb7c         77          100
3mxrk7v6cyxf8         78           50
4pgz7zm9ha8dz         83           31
5yz4xa1gmj3qn         84           40
cgrshhdgq7m9c         85           70
27dptu66g5sq9         86           74
25qvzpmg6c59t         87           41
c6stacabxw17n         90           36
d4tja50vfs7bg         91           65
9mn6xt81ts9d4         93           60
09ym6qtmbsnm4         94           42
ca9ngy3yjja11         96           47



The second query output:

SQL_ID        SQL_TEXT

------------- --------------------------------------------------------------------------------

gmm656xh2884y SELECT * FROM ( SELECT vtf.time_dmkey time_dmkey, vtf.company_name company_name,

               vtf.trans_no trans_no, vtf.store_no store_no, vtf.store_name store_name,  vtf.t

              rans_date trans_date, vtf.customer_id customer_id, vtf.first_name first_name, vt

              f.last_name last_name,  SUM(vtf.amount) amount , vtf.tender_type tender_type, vt

              f.tender_desc tender_desc , substr(lpad(to_char(vtf.account_no),20,'0'),-4) acco

              unt_no  FROM dwse.v_tender_fct vtf, dwse.v_sku_sales_fct vssf  WHERE 1 = 1  AND

              vtf.time_dmkey BETWEEN '20100103' AND '20121003'  AND UPPER(vtf.first_name) LIKE

               UPPER('% %')  AND UPPER(vtf.last_name) LIKE UPPER('%giulitto%')  AND vssf.sku =

               '3020504'  AND vtf.store_no = 679  AND tender_type = 040  AND vtf.store_no=vssf

              .store_no  AND vtf.trans_no=vssf.trans_no  AND vssf.time_dmkey = vtf.time_dmkey

               GROUP BY vtf.time_dmkey,vtf.company_name,vtf.trans_no,vtf.store_no,  vtf.store_

              name,vtf.trans_date,vtf.customer_id,vtf.first_name,vtf.last_name , vtf.tender_ty

              pe, vtf.tender_desc , vtf.account_no  ) a  WHERE a.amount BETWEEN 1.0 AND 800.0



7up1u72k4zun0 declare

              begin

                      PRDSUM.App_Load_Marc.LOAD_MARC;

                      commit;

--More--
