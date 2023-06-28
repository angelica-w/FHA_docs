/*
Given a table of authors, group by concepts to create a table of the # authors within each concept

Parameters:
Authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for author
    concept_0           | STRING    | 1st level 0 concept most frequently applied to author's works
    etc.

Returns:
Table with the # authors in each concept:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    concept         | STRING    | level 0 concept
    num_authors     | INT       | # authors in given concept
*/

SELECT concept_0, COUNT(id) AS num_authors
FROM `AUTHORS_TABLE`
GROUP BY concept_0
ORDER BY concept_0