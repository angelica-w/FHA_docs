/*
Given a table of authors, a table of work's authors, and a table of citations per year for each work,
create a longform table where each row is a author, year, and the # of citations each author received that year

Parameters:
Authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for author
    etc.

Work's Authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    author_id           | STRING    | OpenAlex ID for author of work
    etc.

Citations table:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    id              | STRING    | OpenAlex ID for work
    pub_yr          | INT       | yr this work was published
    age             | INT       | age of work since publication, with age 0 being the year it was published
    num_cites       | INT       | # of citations this work received in the given yr
    etc.

Returns:
Table with how many times a given author was cited in a given year:
    Column Name     | Data Type | Description
    ----------------|-----------|------------------------
    author_id       | STRING    | OpenAlex ID for author
    yr              | INT       | year (from year of 1st publication - 2023)
    total_cites     | INT       | # total citations this author received across all their works in a given yr
*/

-- get # citations an author received for a given year across all their works
WITH author_works_cites AS (
  -- get # citations an author's works received for every year
  WITH author_works AS (
    -- select all authors who have works in the works able
    SELECT authors.id AS author_id, works.id AS work_id
    FROM `WORKS_TABLE` AS works, `AUTHORS_TABLE` AS authors 
    WHERE works.author_id = authors.id
    ORDER BY author_id
  )
  SELECT author_id, work_id, (pub_yr + age) AS yr, num_cites
  FROM author_works
  LEFT JOIN `CITATIONS_TABLE` AS cites
  ON author_works.work_id = cites.id
  ORDER BY author_id
)
SELECT author_id, yr, SUM(num_cites) AS total_cites
FROM author_works_cites 
GROUP BY author_id, yr
ORDER BY author_id, yr
