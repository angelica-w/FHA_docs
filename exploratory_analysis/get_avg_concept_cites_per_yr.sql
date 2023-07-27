/*
Given a table of cites per work per year, 
create a table with the average number of citations works in a given concept receive for each year

Parameters:
Works' Citations table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | OpenAlex ID for work
    concept         | STRING    | top level 0 concept assigned to work
    pub_yr          | INT       | yr this work was published
    total_cites     | INT       | # of citations this work received since publication
    age             | INT       | age of work since publication, with age 0 being the year it was published
    num_cites       | INT       | # of citations this work received in the given yr

Returns:
Table with the average # citations works in a given concept receive for each yr:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    concept         | STRING    | level 0 concept
    yr              | INT       | year
    avg_cites       | FLOAT     | average # citations works of the given concept received that given yr
*/

WITH yrs AS (
  SELECT id, concept, (pub_yr + age) AS yr, num_cites
  FROM `WORKS_CITATIONS_TABLE` 
)
SELECT concept, yr, AVG(num_cites) AS avg_cites
FROM yrs
GROUP BY concept, yr
ORDER BY concept, yr