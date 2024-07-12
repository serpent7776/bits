SELECT schemaname || '.' || tablename AS table_name,
       pg_size_pretty(table_size) AS table_size,
       pg_size_pretty(indexes_size) AS indexes_size,
       pg_size_pretty(total_size) AS total_size
FROM
  (SELECT schemaname,
          tablename,
          pg_table_size(schemaname || '.' || tablename) AS table_size,
          pg_indexes_size(schemaname || '.' || tablename) AS indexes_size,
          pg_total_relation_size(schemaname || '.' || tablename) AS total_size
   FROM pg_catalog.pg_tables
   WHERE schemaname NOT IN ('pg_catalog',
                            'information_schema')
   ORDER BY 4 DESC) AS table_sizes
