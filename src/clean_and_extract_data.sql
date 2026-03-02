CREATE TABLE stage_table(
  dummy TEXT,
  tsp TEXT,
  tgt TEXT,
  src TEXT
);


-- In psql: 
\copy edges_stage FROM '/path/to/10kdata_size.csv' WITH (FORMAT csv, HEADER false);

CREATE TABLE edges_table(
  timestamp BIGINT,
  source BIGINT,
  target BIGINT
);
INSERT INTO edges_table(
  timestamp, source, target
)


# create the birth_size column
ALTER TABLE edges_table ADD COLUMN "size" INTEGER;
UPDATE edges_table
SET size = result.size
FROM(
  SELECT tgt,
  src,
  tsp,
  COUNT(DISTINCT node) OVER (ORDER BY tgt,src,tsp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS size
  FROM (
  SELECT tgt,
  src,
  tsp
  FROM edges_table
  ORDER BY tgt, src, tsp
  ) AS edge
  CROSS JOIN LATERAL 
  (SELECT src AS node UNION ALL SELECT tgt) AS nodes
) AS results
WHERE edges_table.tgt = results.tgt
AND edges_table.src = results.src
AND edges_table.tsp = results.tsp

CREATE TABLE node_property AS
WITH outdeg AS (
  SELECT source AS node, COUNT(*) AS outdegree
  FROM edges_table
  GROUP BY source
),
indeg AS (
  SELECT target AS node, COUNT(*) AS indegree
  FROM edges_table
  GROUP BY target
)
birth_size AS (
  SELECT src AS node, MIN(size) AS birth_size
  FROM edges_table
  GROUP BY src
  
  UNION ALL
  
  SELECT tgt AS node, MIN(size) AS birth_size
  FROM edges_table
  GROUP BY tgt
)
SELECT 
  COALESCE (i.node, o.node) AS node,
  COALESCE (i.indegree, 0) AS indegree,
  COALESCE (o.outdegree,0) AS outdegree
FROM outdeg o
FULL OUTER JOIN indeg i
ON o.node = i.node,
