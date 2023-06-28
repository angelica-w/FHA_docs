/*
- Given a table of authors, a table of work's authors, and a table of work's citations,
  create a longform table where each row is an author, academic age, # works published at that age, total # of lifetime citations works published that yr received
  - only includes lifetime cites of works published before 2013 (otherwise there wouldn't be 10 yrs of citation counts)
  - lifetime citations only includes citations received up to 10 yrs after a paper's publication

Parameters:
Authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for author
    etc.

Works' Authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    author_id           | STRING    | OpenAlex ID for author of work
    etc.

Works' Citations table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    cited_works_id      | STRING    | OpenAlex ID of work that this work cites (this work ⇒ cited_work)
    etc.

Returns:
Table with how many times a given author was cited in a given year:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | Unique OpenAlex ID for author
    yr              | INT       | year (from year of 1st publication - 2023)
    total_cites     | INT       | # total citations this author received across all their works in a given yr
*/

WITH
  cites_per_yr AS (
    -- count how many times each work was cited in lifetime (10 yrs)
    WITH cites_per_work AS (
      -- get works that cited those works published by selected authors within 10 years of publication
      WITH cited AS (
        -- get works published by authors in authors table (authors who started publishing before 2013)
        WITH works AS (
          SELECT works.id AS work_id, CAST(works.publication_year AS INT) AS pub_yr, works.author_id AS author_id, 
          FROM `WORKS_AUTHORS_TABLE` AS works, `AUTHORS_TABLE` AS authors
          WHERE works.author_id = authors.id 
          ORDER BY authors.id 
        )
        SELECT works.author_id AS cited_author_id, works.work_id AS cited_work_id, works.pub_yr AS cited_pub_yr, all_works.id AS work_id, all_works.publication_year AS work_pub_yr
        FROM works
        LEFT JOIN `WORKS_CITATIONS_TABLE` AS all_works
        ON works.work_id = SUBSTR(all_works.cited_works_id, 2, LENGTH(all_works.cited_works_id) - 2)
        WHERE (all_works.cited_works_id IS NOT NULL) AND (all_works.publication_year < works.pub_yr + 11)
        GROUP BY all_works.id, cited_work_id, cited_author_id, cited_pub_yr, all_works.publication_year
        ORDER BY cited_author_id, cited_pub_yr
      )
      SELECT cited_author_id, cited_work_id, cited_pub_yr, COUNT(work_id) AS lifetime_cites
      FROM cited
      GROUP BY cited_author_id, cited_work_id, cited_pub_yr
      ORDER BY cited_author_id, cited_pub_yr
    )
    -- count lifetime cites per year for each author, across all works published that year
    SELECT cited_author_id, cited_pub_yr, SUM(lifetime_cites) AS total_lifetime_cites
    FROM cites_per_work
    GROUP BY cited_author_id, cited_pub_yr
    ORDER BY cited_author_id, cited_pub_yr
  ),
  yrs AS (
    -- get first and last years of publication for each author
    WITH bounds AS (
      SELECT works.author_id AS author_id, CAST(MIN(works.publication_year) AS INT) AS start_yr, CAST(MAX(works.publication_year) AS INT) AS end_yr
      FROM `WORKS_AUTHORS_TABLE` AS works, `AUTHORS_TABLE` AS authors
      WHERE works.author_id = authors.id
      GROUP BY works.author_id
    )
    -- generate multiple rows for each author, where each row is a year between their first and last years of publication
    SELECT author_id, start_yr, yr
    FROM bounds
    CROSS JOIN UNNEST(GENERATE_ARRAY(start_yr, end_yr)) AS yr
    ORDER BY author_id, yr
  ),
  num_works AS (
    -- get all works published by authors in authors table
    WITH works AS (
      SELECT works.author_id, works.id, works.publication_year AS pub_yr
      FROM `WORKS_AUTHORS_TABLE` AS works, `AUTHORS_TABLE` AS authors
      WHERE works.author_id = authors.id
      GROUP BY works.id, author_id, pub_yr
      ORDER BY author_id, pub_yr
    )
    -- count the number of works published per year for each author
    SELECT author_id, CAST(pub_yr AS INT) AS pub_yr, COUNT(id) AS num_works
    FROM works
    GROUP BY author_id, pub_yr 
    ORDER BY author_id, pub_yr
  )
SELECT yrs.author_id AS author_id, start_yr, (yr - start_yr) AS academic_age, COALESCE(num_works, 0) AS num_works, COALESCE(total_lifetime_cites, 0) AS total_lifetime_cites
FROM yrs
LEFT JOIN num_works AS counts
ON (yrs.author_id = counts.author_id) AND (yrs.yr = counts.pub_yr)
LEFT JOIN cites_per_yr AS cites
ON (yrs.author_id = cites.cited_author_id) AND (yrs.yr = cites.cited_pub_yr)
ORDER BY yrs.author_id, academic_age
