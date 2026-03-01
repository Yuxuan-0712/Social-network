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
SELECT DISTINCT ON(src, tgt) tsp, src, tgt
FROM edges_stage
ORDER BY tgt, src, tsp DESC;

CREATE TABLE node_degree AS
WITH outdeg AS (
  SELECT source AS node, COUNT(*) AS outdegree
  FROM edges_table
  GROUP BY source
)
indeg AS (
  SELECT target AS node, COUNT(*) AS indegree
  FROM edges_table
  GROUP BY target
)
SELECT 
  COALESCE (i.node, o.node)
  COALESCE (i.indegree, 0)
  COALESCE (0,o.outdegree)
FROM outdeg o
FULL OUTER JOIN indeg i
o.node = i.node,
