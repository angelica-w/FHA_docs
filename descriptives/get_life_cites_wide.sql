/*
- Given a longform table of # total lifetime citations a given author receives each yr,
  create a wideform table of the # total lifetime citations a given author receives in their first 20 yrs
  - only include authors who started publishing in 1665-2012

Parameters:
Citations table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | Unique OpenAlex ID for author
    yr              | INT       | year (from year of 1st publication - 2023)
    total_cites     | INT       | # total citations this author received across all their works in a given yr

Returns:
Table with the # total lifetime citations each author receives in first 20 yrs:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | Unique OpenAlex ID for author
    age_0           | INT       | # total lifetime citations each author received at age 0 (yr of 1st publication)
    age_1           | INT       | # total lifetime citations each author received at age 1 (1 yr since yr of 1st publication)
    age_2           | INT       | # total lifetime citations each author received at age 2 (2 yrs since yr of 1st publication)
    ...
    age_19          | INT       | # citations each author received at age 19 (19 yrs since yr of 1st publication)
*/

SELECT
  author_id,
  MAX(IF(academic_age = 0, total_lifetime_cites, NULL)) AS age_0,
  MAX(IF(academic_age = 1, total_lifetime_cites, NULL)) AS age_1,
  MAX(IF(academic_age = 2, total_lifetime_cites, NULL)) AS age_2,
  MAX(IF(academic_age = 3, total_lifetime_cites, NULL)) AS age_3,
  MAX(IF(academic_age = 4, total_lifetime_cites, NULL)) AS age_4,
  MAX(IF(academic_age = 5, total_lifetime_cites, NULL)) AS age_5,
  MAX(IF(academic_age = 6, total_lifetime_cites, NULL)) AS age_6,
  MAX(IF(academic_age = 7, total_lifetime_cites, NULL)) AS age_7,
  MAX(IF(academic_age = 8, total_lifetime_cites, NULL)) AS age_8,
  MAX(IF(academic_age = 9, total_lifetime_cites, NULL)) AS age_9,
  MAX(IF(academic_age = 10, total_lifetime_cites, NULL)) AS age_10,
  MAX(IF(academic_age = 11, total_lifetime_cites, NULL)) AS age_11,
  MAX(IF(academic_age = 12, total_lifetime_cites, NULL)) AS age_12,
  MAX(IF(academic_age = 13, total_lifetime_cites, NULL)) AS age_13,
  MAX(IF(academic_age = 14, total_lifetime_cites, NULL)) AS age_14,
  MAX(IF(academic_age = 15, total_lifetime_cites, NULL)) AS age_15,
  MAX(IF(academic_age = 16, total_lifetime_cites, NULL)) AS age_16,
  MAX(IF(academic_age = 17, total_lifetime_cites, NULL)) AS age_17,
  MAX(IF(academic_age = 18, total_lifetime_cites, NULL)) AS age_18,
  MAX(IF(academic_age = 19, total_lifetime_cites, NULL)) AS age_19
FROM (
  SELECT author_id, academic_age, num_works, total_lifetime_cites
  FROM `CITATIONS_TABLE` 
  WHERE (start_yr >= 1665) AND (start_yr <= 2012)
)
GROUP BY author_id
ORDER BY author_id