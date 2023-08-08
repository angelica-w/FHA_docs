/*
- Given a longform table of # citations a given author receives each yr,
  create a wideform table of the # citations a given author receives in their first 20 yrs
  - only include authors who started publishing in 1665-2012

Parameters:
Citations table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | OpenAlex ID for author
    yr              | INT       | year (from year of 1st publication - 2023)
    total_cites     | INT       | # total citations this author received across all their works in a given yr

Returns:
Table with the # citations each author receives in first 20 yrs:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | Unique OpenAlex ID for author
    age_0           | INT       | # citations each author received at age 0 (yr of 1st publication)
    age_1           | INT       | # citations each author received at age 1 (1 yr since yr of 1st publication)
    age_2           | INT       | # citations each author received at age 2 (2 yrs since yr of 1st publication)
    ...
    age_19          | INT       | # citations each author received at age 19 (19 yrs since yr of 1st publication)
*/

WITH long AS (
  WITH start_yrs AS (
  SELECT author_id, MIN(yr) AS start_yr
  FROM `CITATIONS_TABLE` 
  GROUP BY author_id
  )
  -- filter to only include authors who started in 1665-2012
  SELECT cites.author_id, (cites.yr - start_yrs.start_yr) AS age, cites.total_cites 
  FROM `CITATIONS_TABLE` AS cites, start_yrs
  WHERE (cites.author_id = start_yrs.author_id) AND (start_yr >= 1665) AND (start_yr <= 2012)
  ORDER BY cites.author_id, yr
)
SELECT
author_id,
  MAX(IF(age = 0, total_cites, NULL)) AS age_0,
  MAX(IF(age = 1, total_cites, NULL)) AS age_1,
  MAX(IF(age = 2, total_cites, NULL)) AS age_2,
  MAX(IF(age = 3, total_cites, NULL)) AS age_3,
  MAX(IF(age = 4, total_cites, NULL)) AS age_4,
  MAX(IF(age = 5, total_cites, NULL)) AS age_5,
  MAX(IF(age = 6, total_cites, NULL)) AS age_6,
  MAX(IF(age = 7, total_cites, NULL)) AS age_7,
  MAX(IF(age = 8, total_cites, NULL)) AS age_8,
  MAX(IF(age = 9, total_cites, NULL)) AS age_9,
  MAX(IF(age = 10, total_cites, NULL)) AS age_10,
  MAX(IF(age = 11, total_cites, NULL)) AS age_11,
  MAX(IF(age = 12, total_cites, NULL)) AS age_12,
  MAX(IF(age = 13, total_cites, NULL)) AS age_13,
  MAX(IF(age = 14, total_cites, NULL)) AS age_14,
  MAX(IF(age = 15, total_cites, NULL)) AS age_15,
  MAX(IF(age = 16, total_cites, NULL)) AS age_16,
  MAX(IF(age = 17, total_cites, NULL)) AS age_17,
  MAX(IF(age = 18, total_cites, NULL)) AS age_18,
  MAX(IF(age = 19, total_cites, NULL)) AS age_19
FROM long
GROUP BY author_id
ORDER BY author_id