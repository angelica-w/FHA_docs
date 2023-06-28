/*
Given a table of authors and a table of works' authors, 
create a table of the number of authors in each concept who started publishing in a given year

Parameters:
Authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for author
    concept_0           | STRING    | 1st level 0 concept most frequently applied to author's works
    etc.

Works' Authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    author_id           | STRING    | OpenAlex ID for author of work
    etc.

Returns:
Table with the # authors in each concept who started publishing in a given yr:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    start_yr        | INT       | year
    concept_0       | STRING    | level 0 concept
    num_authors     | INT       | # authors in given concept who started in given yr
*/

WITH start_yrs AS (
  -- get first year of publication for each author
    SELECT works.author_id AS author_id, authors.concept_0, CAST(MIN(works.publication_year) AS INT) AS start_yr
    FROM `WORKS_AUTHORS_TABLE` AS works, `AUTHORS_TABLE` AS authors
    WHERE works.author_id = authors.id
    GROUP BY works.author_id, authors.concept_0
)
SELECT start_yr, concept_0, COUNT(*) AS num_authors
FROM start_yrs
GROUP BY start_yr, concept_0
ORDER BY start_yr