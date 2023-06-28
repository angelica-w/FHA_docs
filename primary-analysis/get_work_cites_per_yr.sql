/*
Given a table of works and a table of works' citations, 
create a longform table where each row is a work, year, and how many times that work was cited that year

Parameters:
Works table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    concept_0           | STRING    | top level 0 concept assigned to work

Works' citations table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    cited_works_id      | STRING    | OpenAlex ID of work that this work cites (this work ⇒ cited_work)

Returns:
Table with how many times a given work was cited in a given year:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | OpenAlex ID for work
    concept         | STRING    | top level 0 concept assigned to work
    pub_yr          | INT       | yr this work was published
    total_cites     | INT       | # of citations this work received since publication
    age             | INT       | age of work since publication, with age 0 being the year it was published
    num_cites       | INT       | # of citations this work received in the given yr
*/


WITH 
  cites_per_yr AS (
    -- count # citations a given work receives per year
    WITH cites_per_work AS (
      -- get works in all_works table that cite the given works in cited table
      SELECT cited.id AS cited_id, cited.publication_year AS cited_pub_yr, cited.concept_0 AS cited_concept, all_works.id AS work_id, all_works.publication_year AS work_pub_yr
      FROM `WORKS_TABLE` AS cited
      LEFT JOIN `WORKS_CITATIONS_TABLE` AS all_works 
      ON cited.id = SUBSTR(all_works.cited_works_id, 2, LENGTH(all_works.cited_works_id) - 2)
      WHERE (all_works.cited_works_id IS NOT NULL)
    )
    SELECT cited_id, cited_pub_yr, cited_concept, work_pub_yr, COUNT(work_id) AS num_cites
    FROM cites_per_work
    GROUP BY cited_id, cited_pub_yr, cited_concept, work_pub_yr
  ),
  total_cites AS (
    -- count # citations a given work has received in total
    WITH cites_per_work AS(
      SELECT works.id AS cited_id, works.publication_year AS cited_pub_yr, all_works.id AS work_id, all_works.publication_year AS work_pub_yr
      FROM `WORKS_TABLE` as works
      LEFT JOIN `WORKS_CITATIONS_TABLE` as all_works
      ON works.id = SUBSTR(all_works.cited_works_id, 2, LENGTH(all_works.cited_works_id) - 2)
      WHERE (all_works.cited_works_id IS NOT NULL)
      GROUP BY works.id, works.publication_year, all_works.id, all_works.publication_year
      ORDER BY works.id, all_works.publication_year
    )
    SELECT cited_id, cited_pub_yr, COUNT(cited_id) AS total_cites
    FROM cites_per_work
    GROUP BY cited_id, cited_pub_yr
    ORDER BY cited_id
  ),
  yrs AS (
    -- generate rows for every year from publication year to 2023
    SELECT id, concept_0 AS concept, publication_year AS start_yr, yr
    FROM `WORKS_TABLE`
    CROSS JOIN UNNEST(GENERATE_ARRAY(publication_year, 2023)) AS yr
    ORDER BY id, yr
  )
SELECT yrs.id, yrs.concept, yrs.start_yr AS pub_yr, totals.total_cites AS total_cites, (yrs.yr - yrs.start_yr) AS age, COALESCE(cites.num_cites, 0) AS num_cites
FROM yrs
LEFT JOIN cites_per_yr AS cites
ON yrs.id = cites.cited_id AND yrs.yr = cites.work_pub_yr
LEFT JOIN total_cites AS totals
ON (yrs.id = totals.cited_id)
ORDER BY id, yr
