/*
Given a table of works, create a table of the number of works in each concept published in a given year

Parameters:
Works table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | Unique OpenAlex ID for work
    concept_0       | STRING    | 1st level 0 concept assigned to work
    etc.

Returns:
Table with the # works in each concept published in a given yr:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    publication_year    | INT       | year
    concept_0           | STRING    | level 0 concept
    num_works           | INT       | # works in given concept published in given yr
*/

SELECT publication_year, concept_0, COUNT(id) AS num_works
FROM `WORKS_TABLE` 
GROUP BY publication_year, concept_0
ORDER BY publication_year