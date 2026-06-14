WITH DEDUPID as
(
select * 
,
row_number() over (partition by id order by updateDate DESC) as DEDUP

from {{source('source','items')}}

)
SELECT id ,name,category,updateDate FROM DEDUPID WHERE DEDUP=1