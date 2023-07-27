/*
- Given a table of works, create a table with an era column, categorizing each work into 1 of 4 eras based on publication year
  - Before 1815 ⇒ era 1
  - 1816-1918 ⇒ era 2
  - 1919-1945 ⇒ era 3
  - 1946-present ⇒ era 4

Parameters:
Works table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    concept_0           | STRING    | top level 0 concept assigned to work

Returns:
Table with a categorical era variable depending on when a given work was published:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    concept_0           | STRING    | top level 0 concept assigned to work
    era                 | INT       | the era a work falls under (1, 2, 3, 4)
*/

SELECT id, publication_year, concept_0,
  CASE
    WHEN (publication_year <= 1815) THEN 1
    WHEN (publication_year >= 1816) AND (publication_year <= 1918) THEN 2
    WHEN (publication_year >= 1919) AND (publication_year <= 1945) THEN 3
    WHEN (publication_year >= 1946) THEN 4 
    ELSE NULL 
  END AS era
FROM `WORKS_TABLE` 
