WITH RECURSIVE
cnt(x) AS (
	SELECT 1
	UNION ALL
	SELECT x+1 FROM cnt
	where x < 100
) select coalesce(nullif(
		case when n.x%3=0 then 'fizz' else '' end ||
		case when n.x%5=0 then 'buzz' else '' end,
		''),
	CAST(n.x AS text))
from cnt as n;

