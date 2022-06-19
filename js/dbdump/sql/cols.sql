select 
table_name,
column_name,
ordinal_position,
data_type
from information_schema.columns
where table_schema = 'public'
order by "table_name", "ordinal_position"


