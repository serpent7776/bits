SELECT
    pid,
    usename,
    query,
    state,
    pg_catalog.age(clock_timestamp(), query_start) AS duration
FROM
    pg_catalog.pg_stat_activity
WHERE
    state != 'idle'
    AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY
    query_start DESC;
