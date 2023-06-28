/*
- Given a longform table of percentile rankings of a given author each yr,
  create a wideform table of the percentile ranking of a given author for their first 20 yrs

Parameters:
Rank table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | OpenAlex ID for author
    concept_0       | STRING    | 1st level 0 concept most frequently applied to author's works
    age             | INT       | academic age of author, with age 0 being the year of their 1st publication
    per_rank        | FLOAT     | percentile rank of given author relative to others with the same concept, start yr, and age 

Returns:
Table with percentile ranking of each author in their first 20 yrs:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | Unique OpenAlex ID for author
    age_0           | INT       | percentile ranking of each author at age 0 (yr of 1st publication)
    age_1           | INT       | percentile ranking of each author at age 1 (1 yr since yr of 1st publication)
    age_2           | INT       | percentile ranking of each author at age 2 (2 yrs since yr of 1st publication)
    ...
    age_19          | INT       | percentile ranking of each author at age 19 (19 yrs since yr of 1st publication)
*/

SELECT
author_id,
concept_0,
  MAX(IF(age = 0, per_rank, NULL)) AS age_0,
  MAX(IF(age = 1, per_rank, NULL)) AS age_1,
  MAX(IF(age = 2, per_rank, NULL)) AS age_2,
  MAX(IF(age = 3, per_rank, NULL)) AS age_3,
  MAX(IF(age = 4, per_rank, NULL)) AS age_4,
  MAX(IF(age = 5, per_rank, NULL)) AS age_5,
  MAX(IF(age = 6, per_rank, NULL)) AS age_6,
  MAX(IF(age = 7, per_rank, NULL)) AS age_7,
  MAX(IF(age = 8, per_rank, NULL)) AS age_8,
  MAX(IF(age = 9, per_rank, NULL)) AS age_9,
  MAX(IF(age = 10, per_rank, NULL)) AS age_10,
  MAX(IF(age = 11, per_rank, NULL)) AS age_11,
  MAX(IF(age = 12, per_rank, NULL)) AS age_12,
  MAX(IF(age = 13, per_rank, NULL)) AS age_13,
  MAX(IF(age = 14, per_rank, NULL)) AS age_14,
  MAX(IF(age = 15, per_rank, NULL)) AS age_15,
  MAX(IF(age = 16, per_rank, NULL)) AS age_16,
  MAX(IF(age = 17, per_rank, NULL)) AS age_17,
  MAX(IF(age = 18, per_rank, NULL)) AS age_18,
  MAX(IF(age = 19, per_rank, NULL)) AS age_19
FROM `RANK_TABLE`
GROUP BY author_id, concept_0
ORDER BY author_id