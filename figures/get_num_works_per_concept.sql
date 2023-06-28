/*
Given a table of works, group by concepts to create a table of the # works within each concept

Parameters:
Works table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | Unique OpenAlex ID for work
    concept_0       | STRING    | 1st level 0 concept assigned to work
    etc.

Returns:
Table with the # authors in each concept:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    concept         | STRING    | level 0 concept
    num_works       | INT       | # works in given concept
*/

SELECT concept_0, COUNT(id) AS num_works
FROM `WORKS_TABLE` 
GROUP BY concept_0
ORDER BY concept_0