/*
- Given a single table of works where each row is a JSON object, 
  extract the top level 0 concepts of each work and convert the table into csv format
- Each work only appears in 1 row
- Last used on May 3, 2023 snapshot

Parameters:
Unformatted works table with single column of JSON object files:
    Column Name  | Data Type | Description
    -------------|-----------|------------------------
    work         | STRING    | work entity as JSON object

Returns:
Formatted works table with each work's top 3 level 0 concepts:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for work
    publication_year    | INT       | yr this work was published
    concept_0           | STRING    | 1st level 0 concept assigned to work
*/

SELECT 
    data_0.id,
    data_0.publication_year,
    data_1.concept_0,
FROM (
    SELECT
    json_extract_scalar(work, '$.id') as id,
    json_extract_scalar(work, '$.title') as title,
    CAST(json_extract_scalar(work, '$.publication_year') AS INT) as publication_year,
    json_extract_scalar(work, '$.type') as type,
    CAST(json_extract_scalar(work, '$.cited_by_count') AS INT) as cited_by_count,
    json_extract_scalar(work, '$.cited_by_api_url') as cited_url,
    FROM `UNFORMATTED_WORKS_TABLE` AS small
) AS data_0
LEFT OUTER JOIN(
    WITH concept_data as(
        SELECT 
            id,
            ARRAY_AGG(c_name IGNORE NULLS) as concepts,
            ARRAY_AGG(c_score IGNORE NULLS) as scores
        FROM(
            SELECT * EXCEPT(arr) 
            FROM(
                SELECT
                    id,
                    ARRAY_AGG(STRUCT(c_name, c_score) ORDER BY c_score DESC LIMIT 3) arr
                FROM(
                    SELECT 
                        json_extract_scalar(work, '$.id') as id,
                        json_extract_scalar(c, '$.display_name') as c_name,
                        CAST(json_extract_scalar(c, '$.level') as INT) as c_level,
                        CAST(json_extract_scalar(c, '$.score') as DECIMAL) as c_score,

                    FROM `UNFORMATTED_WORKS_TABLE` AS small
                    LEFT JOIN UNNEST(json_extract_array(work, '$.concepts')) as c
                    WHERE CAST(json_extract_scalar(c, '$.level') as INT) = 0 
                ) c0
                GROUP BY id
            ), UNNEST(arr)
        )
        GROUP BY id
    )
    SELECT * 
    FROM (
        SELECT id, a, b, offset
        from concept_data, 
        unnest(concepts) a with offset
        join unnest(scores) b with offset
        using (offset)
    )
    pivot (min(a) as concept, min(b) as score for offset in (0, 1, 2))
) AS data_1
ON data_0.id = data_1.id

