/*
Given a table of # citations a given work receives each yr,
create a table of the # total citations works of each concept receive

Parameters:
Citations table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | OpenAlex ID for work
    concept         | STRING    | top level 0 concept assigned to work
    pub_yr          | INT       | yr this work was published
    total_cites     | INT       | # of citations this work received since publication
    age             | INT       | age of work since publication, with age 0 being the year it was published
    num_cites       | INT       | # of citations this work received in the given yr

Returns:
Table with the # works in each concept published in a given yr:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    concept_0       | STRING    | level 0 concept
    total_cites     | INT       | # citations works in given concept received in given yr
*/

SELECT concept, SUM(num_cites) AS total_cites
FROM `CITATIONS_TABLE` 
GROUP BY concept
ORDER BY total_cites