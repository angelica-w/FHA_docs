/*
- Given a single table of works where each row is a JSON object, 
  extract the work the given work cites and convert the table into csv format
- Each work may span multiple rows, where each row is a distinct work and referenced work (work that this work cites)
- Last used on May 3, 2023 snapshot


Parameters:
Unformatted works table with single column of JSON object files:
    Column Name  | Data Type | Description
    -------------|-----------|------------------------
    work         | STRING    | work entity as JSON object

Returns:
Formatted works table with each work's citation:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | OpenAlex ID for work
    title               | STRING    | title of this work
    publication_year    | INT       | yr this work was published
    type                | STRING    | Crossref's "type" of work
    cited_by_count      | INT       | # of citations to this work (other works ⇒ this work) (according to OpenAlex)
    cited_url           | STRING    | URL for list of works that cites this work
    cited_works_id      | STRING    | OpenAlex ID of work that this work cites (this work ⇒ cited_work)
*/

SELECT
    json_extract_scalar(work, '$.id') as id,
    json_extract_scalar(work, '$.title') as title,
    CAST(json_extract_scalar(work, '$.publication_year') AS INT) as publication_year,
    json_extract_scalar(work, '$.type') as type,
    CAST(json_extract_scalar(work, '$.cited_by_count') AS INT) as cited_by_count,
    json_extract_scalar(work, '$.cited_by_api_url') as cited_url,
    r as cited_works_id
FROM `UNFORMATTED_WORKS_TABLE`
left join unnest(json_extract_array(work, '$.referenced_works')) as r