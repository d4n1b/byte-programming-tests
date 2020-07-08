-- DEVELOPER NOTES:
-- * I didn't quite get the `primary key app_events_pkey (event_id)` part of the sql, not sure if it was a hint or...
-- * Optimization is not done, but one of options I have in mind would be:
--    1. Create a separate read-only table with indexed columns bot_id & event_state_name (event_data->'StateName' at root level).
--    2a. Create an index with bot_id and index StateName in event_data (I think is with BTREE and HASH)
--    2b. Create an index with bot_id and either put the JSONB prop to root level.

SET client_encoding = 'utf8';

-- Generate table
DROP TABLE IF EXISTS app_events;

CREATE TABLE app_events (
  bot_id TEXT NOT NULL,
  event_id BIGSERIAL NOT NULL,
  aggregate_type TEXT NOT NULL,
  aggregate_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_data JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Test
-- 1. Add records
INSERT INTO app_events (bot_id, event_id, aggregate_type, aggregate_id, event_type, event_data, created_at)
SELECT
  ((array['1', '2', '3', '4', '5'])[floor(random() * 5 + 1)]),
  i::BIGINT,
  '',
  i::TEXT,
  ((array['VisitState', 'MixState', 'RandomState'])[floor(random() * 3 + 1)]),
  ('{"StateName": "' || (array['reorder-allergy-info', 'reorder', 'reorder-pay'])[floor(random() * 3 + 1)] || '"}')::JSONB,
  ('2020-' || floor(random() * 12 + 1) || '-08 10:35:17')::TIMESTAMP
FROM generate_series(1, 1000000) i;


-- 2. Create function
DROP FUNCTION IF EXISTS visits_by_bot_id_and_month;

CREATE FUNCTION visits_by_bot_id_and_month(TEXT, TIMESTAMP)
RETURNS TABLE (id JSONB, total BIGINT)
AS $$

DECLARE start_day TIMESTAMP := DATE_TRUNC('month', $2::DATE);
DECLARE end_day TIMESTAMP := DATE_TRUNC('month', $2::DATE + INTERVAL '1 month' - INTERVAL '1 day')::DATE;

BEGIN
  RETURN QUERY
  SELECT event_data->'StateName' AS state_name, COUNT(*)
  FROM app_events
  WHERE
    bot_id = $1 AND
    event_type = 'VisitState' AND
    created_at BETWEEN start_day AND end_day AND
    (
      event_data->'StateName' = '"reorder-allergy-info"' OR
      event_data->'StateName' = '"reorder"' OR
      event_data->'StateName' = '"reorder-pay"'
    )
  GROUP BY event_data->'StateName';
END;

$$ LANGUAGE plpgsql;

-- 3. Execute
SELECT * FROM visits_by_bot_id_and_month('1', '2020-06-08 00:00:00');
