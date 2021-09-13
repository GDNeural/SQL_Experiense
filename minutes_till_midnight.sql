with ts_max_min_speed as
(
select tablespace_name,
max((round(free_space/1024/1024))) as MAX_FREE_SPC_MB,
min((round(free_space/1024/1024))) as MIN_FREE_SPC_MB,
case 
   when round((max(round(free_space)) - min(round(free_space)))/30/1024/1024) = 0 then 1
   else round((max(round(free_space)) - min(round(free_space)))/30/1024/1024)
end as SPEED_OF_EXPAND_MB_PER_DAY
from cr_feed_audit.tablespace_stats 
where report_date BETWEEN 
      to_date(to_char(SYSDATE-30, 'DD.MM.YYYY HH24:MI:SS'), 'DD.MM.YYYY HH24:MI:SS') and 
      to_date(to_char(SYSDATE, 'DD.MM.YYYY HH24:MI:SS'), 'DD.MM.YYYY HH24:MI:SS')
group by tablespace_name
order by SPEED_OF_EXPAND_MB_PER_DAY desc
)
select cts.tablespace_name, round(cts.free_space/1024/1024) as CUR_FREE_SPC,
tmms. MAX_FREE_SPC_MB, tmms.MIN_FREE_SPC_MB,SPEED_OF_EXPAND_MB_PER_DAY,
round(round(cts.free_space/1024/1024)/SPEED_OF_EXPAND_MB_PER_DAY) as DAYS_TILL_MIDNIGHT
from cr_feed_audit.tablespace_stats cts
join ts_max_min_speed tmms on cts.tablespace_name = tmms.tablespace_name
where report_date = to_date(to_char(SYSDATE, 'DD.MM.YYYY'), 'DD.MM.YYYY')
