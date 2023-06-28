/*
- Given a table of # citations works receive per year, 
  create a table where each row is a work and their percentile ranking based on the 1st 5 yrs of citations
  - Grouped by concept
- Used for replication of Tian & Ipeirotis (2021)
  - sum rank of works over works published between ages 0-4, 5-9, 10-14, 15-20 to get author's percentile rank for these ranges

Parameters:
Citations table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | OpenAlex ID for work
    concept         | STRING    | top level 0 concept assigned to work
    pub_yr          | INT       | yr this work was published
    total_cites     | INT       | # of citations this work received since publication
    age             | INT       | age of work since publication, with age 0 being the year it was published
    num_cites       | INT       | # of citations this work received in the given yr

Returns:
Table with percentile ranking of a work relative to other works in the same concept:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | Unique OpenAlex ID for work
    concept         | STRING    | first level 0 concept assigned to work
    pub_yr          | INT       | yr this work was published
    total_cites_5   | INT       | # total citations given work received in first 5 yrs of publication
    percent_rank    | FLOAT     | percentile rank of given work relative to others in the same concept
*/

-- calc percent rank based on total cites of first 5 yrs, grouped by concept
WITH age_5 AS (
  -- get total citations for first 5 yrs of all works
  WITH age_works AS (
    -- get all works that have been published at least 5 years
    WITH works_max_age AS (
    SELECT cites.id, MAX(age) AS max_age
    FROM `openalex-bigquery.2023_05_03_calcs.cites_per_yr_per_work` AS cites
    GROUP BY cites.id
    )
    SELECT *
    FROM works_max_age
    WHERE max_age >= 4
  )
  SELECT works.id, works.concept, works.pub_yr, SUM(works.num_cites) AS total_cites_5
  FROM age_works, `openalex-bigquery.2023_05_03_calcs.cites_per_yr_per_work` AS works
  WHERE (age_works.id = works.id) AND (works.age < 5)
  GROUP BY works.id, works.concept, works.pub_yr
)
SELECT
  id,
  concept,
  pub_yr,
  total_cites_5,
  PERCENT_RANK() OVER (PARTITION BY concept ORDER BY total_cites_5 ASC) AS percent_rank
FROM age_5
ORDER BY concept, percent_rank