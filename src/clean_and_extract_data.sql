CREATE TABLE stage_table(
  dummy TEXT,
  tsp TEXT,
  tgt TEXT,
  src TEXT
);


-- In psql: 
\copy stage_table FROM '/path/to/10kdata_size.csv' WITH (FORMAT csv, HEADER false);

CREATE TABLE edges_table(
  timestamp BIGINT,
  source BIGINT,
  target BIGINT
);
INSERT INTO edges_table(
  timestamp, source, target
)
SELECT DISTINCT ON (tgt,src)
  tsp::BIGINT,
  src::BIGINT,
  tgt::BIGINT
FROM stage_table ORDER BY tgt,src,tsp::BIGINT DESC;

--create the birth_size column
ALTER TABLE edges_table ADD COLUMN "size" INTEGER;
WITH first_apperance AS (
SELECT node, MIN(ts) AS first_ts
FROM (
SELECT target as node, timestamp as ts
FROM edges_table
UNION ALL 
SELECT source as node, timestamp as ts
FROM edges_table
) x
GROUP BY node
),
edges_size AS (
SELECT e.target, e.source, e.timestamp, 
(SELECT COUNT(*) from first_apperance fa 
WHERE fa.first_ts <= e.timestamp) AS size
FROM edges_table e
)
UPDATE edges_table e
SET size = ed.size
FROM edges_size ed
WHERE e.target = ed.target
AND e.source = ed.source
AND e.timestamp = ed.timestamp;

-- Create node properties table
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
),
first_timestamp AS (
SELECT node, MIN(ts) AS fs
FROM (
SELECT source AS node, timestamp AS ts FROM edges_table
UNION ALL 
SELECT target AS node, timestamp AS ts FROM edges_table
) x
GROUP BY node
),
node_size AS (
SELECT ft.node, COUNT(*) OVER (ORDER BY fs ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS birth_size
FROM first_timestamp ft
)
 
SELECT 
COALESCE (i.node, o.node) AS node,
COALESCE (i.indegree,0) AS indegree,
COALESCE (o.outdegree,0) AS outdegree,
COALESCE (s.birth_size,0) AS birth_size
FROM indeg i
FULL OUTER JOIN outdeg o ON i.node = o.node
FULL OUTER JOIN node_size s ON COALESCE (i.node, o.node) = s.node;
