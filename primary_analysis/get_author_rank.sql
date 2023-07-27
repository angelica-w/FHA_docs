/*
- Given a table of authors and a table of the # citations authors receive per year,
  create a table where each row is an author, academic age, and their percentile ranking at that age
  - Percentile rank calculated based on the total number of citations an author received for a given yr
  - Grouped by concept, start year, and age

Parameters:
Authors table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | Unique OpenAlex ID for author
    concept_0       | STRING    | 1st level 0 concept most frequently applied to author's works
    etc.

Citations table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | OpenAlex ID for author
    yr              | INT       | year (from year of 1st publication - 2023)
    total_cites     | INT       | # total citations this author received across all their works in a given yr

Returns:
Table with percentile ranking of an author at a given age:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | OpenAlex ID for author
    concept_0       | STRING    | 1st level 0 concept most frequently applied to author's works
    age             | INT       | academic age of author, with age 0 being the year of their 1st publication
    per_rank        | FLOAT     | percentile rank of given author relative to others with the same concept, start yr, and age 
*/

-- calc author percentile rank of author for each year
WITH ranks AS (
  WITH start_yrs AS (
    -- get the 1st year of publication for every author
    SELECT author_id, MIN(yr) AS start_yr
    FROM `CITATIONS_TABLE` 
    GROUP BY author_id
  )
  SELECT cites.author_id, authors.concept_0, start_yrs.start_yr, (cites.yr - start_yrs.start_yr) AS age, cites.total_cites 
  FROM `CITATIONS_TABLE` AS cites, start_yrs, `AUTHORS_TABLE` AS authors
  WHERE (cites.author_id = start_yrs.author_id) AND (cites.author_id = authors.id) AND (start_yr >= 1665) AND (start_yr <= 2012)
  ORDER BY cites.author_id, yr
)
SELECT
author_id,
concept_0,
age,
PERCENT_RANK() OVER (PARTITION BY concept_0, start_yr, age ORDER BY total_cites ASC) AS per_rank    -- group by concept, start_yr, age; calc based on total_cites
FROM ranks
