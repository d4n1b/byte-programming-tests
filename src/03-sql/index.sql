-- DEVELOPER NOTES:
-- There is probably a better way to comply with the `updated_at`. I know it's possible in MySQL
-- adding `ON UPDATE` in `CREATE TABLE` the statement.


SET client_encoding = 'utf8';

-- Generate table
DROP TABLE IF EXISTS facebook_profiles;

CREATE TABLE facebook_profiles
(
  psid TEXT NOT NULL PRIMARY KEY,
  first_name VARCHAR (50) NOT NULL,
  last_name VARCHAR (50) NOT NULL,
  profile_pic TEXT,
  locale VARCHAR (8) NOT NULL,
  timezone INTEGER NOT NULL,
  gender TEXT,
  last_ad_referral JSONB,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Create triggers
DROP FUNCTION IF EXISTS updated_at;

CREATE FUNCTION updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';


-- Add update trigger to facebook_profiles
CREATE TRIGGER facebook_profiles_updated_at
  BEFORE UPDATE ON facebook_profiles FOR EACH ROW EXECUTE PROCEDURE  updated_at();


-- Test
-- 1. Add record
INSERT INTO facebook_profiles (psid, first_name, last_name, profile_pic, locale, timezone, gender, last_ad_referral) VALUES
  ('MQo=', 'Peter', 'Chang', 'https://example.com/13055603_10105219398495383_8237637584159975445_n.jpg', 'en_US', -7, 'male', '{"source": "ADS", "type": "OPEN_THREAD", "ad_id": "6045246247433"}'),
  ('Mgo=', 'Dani', 'M', 'https://example.com/13055603_10105219398495383_8237637584159975445_n.jpg', 'en_US', -7, 'male', '{"source": "ADS", "type": "OPEN_THREAD", "ad_id": "3347426425406"}');

-- 2. Wait 5 seconds
SELECT pg_sleep(5);

-- 3. Update record
UPDATE facebook_profiles
  SET last_name = 'Chang Min'
WHERE psid = 'MQo=';

-- 4. Select record & updated_at should be created_at + 5 sec
SELECT * FROM facebook_profiles WHERE psid = 'MQo=';
