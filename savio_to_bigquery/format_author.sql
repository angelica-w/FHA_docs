/*
- Given a single table of authors where each row is a JSON object, extract the desired fields,
  convert the table into standard csv format, and add carnegie classification for authors’ affiliated institution
- Includes calculations for the top 3 level 0 concepts
- Last used on May 3, 2023 snapshot of OpenAlex, so includes more recently added fields (impact factor, h-index, i-10 index)

Parameters:
Unformatted authors table with single column of JSON object files:
    Column Name  | Data Type | Description
    -------------|-----------|------------------------
    author       | STRING    | author entity as JSON object

Table of Carnegie Classifications for US institutions in OpenAlex:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    affiliation_name    | STRING    | institution name
    institution_type    | STRING    | institution type matching with 90% fuzziness (0:teaching, 1:research)

Returns:
Formatted authors table:
    Column Name         | Data Type | Description
    --------------------|-----------|------------------------
    id                  | STRING    | Unique OpenAlex ID for author
    name                | STRING    | Name of author
    name_alternative    | STRING    | Other ways author's name has been displayed
    orcid               | STRING    | ORCID ID for author
    works_count         | INT       | # works author has created (according to OpenAlex)
    total_cite          | INT       | # works that cite a work this author created (according to OpenAlex)
    affiliation_name    | STRING    | Name of last known institution
    affiliation_id      | STRING    | OpenAlex ID for institution
    affiliation_ror     | STRING    | ROR ID for institution
    affiliation_country | STRING    | ISO 2-letter country code of institution
    affiliation_type    | STRING    | ROR "type" for institution
    works_api_url       | STRING    | URL for list of author's works
    impact_factor       | NUMERIC   | 2-yr mean citedness for author
    h_index             | NUMERIC   | h-index for author
    i_10_index          | NUMERIC   | i-10 index for author
    concept_0           | STRING    | 1st level 0 concept most frequently applied to author's works
    score_0             | NUMERIC   | strength of association between author and concept_0 (scale 0-100)
    concept_1           | STRING    | 2nd top level 0 concept most frequently applied to author's works
    score_1             | NUMERIC   | strength of association between author and concept_1 (scale 0-100)
    concept_2           | STRING    | 3rd top level 0 concept most frequently applied to author's works
    score_2             | NUMERIC   | strength of association between author and concept_2 (scale 0-100)
    institution_type    | STRING    | Carnegie Classification for institution
*/

SELECT 
  data0.id,
  name,
  name_alternative,
  orcid,
  works_count,
  total_cite,
  data0.affiliation_name,
  affiliation_id,
  affiliation_ror,
  affiliation_country,
  affiliation_type,
  works_api_url,
  impact_factor,
  h_index,
  i_10_index,
  concept_0,
  score_0,
  concept_1,
  score_1,
  concept_2,
  score_2,
  data2.institution_type
FROM(
  -- extract desired author fields
  SELECT
    json_extract_scalar(author, '$.id') AS id,
    json_extract_scalar(author, '$.display_name') AS name,
    json_extract_scalar(author, '$.display_name_alternatives') AS name_alternative,
    json_extract_scalar(author, '$.ids.orcid') AS orcid,
    CAST(json_extract_scalar(author, '$.works_count') AS INT) AS works_count,
    CAST(json_extract_scalar(author, '$.cited_by_count') AS INT) as total_cite,
    json_extract_scalar(author, '$.last_known_institution.display_name') AS affiliation_name,
    json_extract_scalar(author, '$.last_known_institution.id') AS affiliation_id,
    json_extract_scalar(author, '$.last_known_institution.ror') AS affiliation_ror,
    json_extract_scalar(author, '$.last_known_institution.country_code') AS affiliation_country,
    json_extract_scalar(author, '$.last_known_institution.type') AS affiliation_type,
    json_extract_scalar(author, '$.works_api_url') AS works_api_url,
    CAST(json_extract_scalar(author, '$.summary_stats.2yr_mean_citedness') AS DECIMAL) AS impact_factor,
    CAST(json_extract_scalar(author, '$.summary_stats.h_index') AS DECIMAL) AS h_index,
    CAST(json_extract_scalar(author, '$.summary_stats.i10_index') AS DECIMAL) AS i_10_index,
  FROM `UNFORMATTED_AUTHORS_TABLE`
) AS data0
LEFT OUTER JOIN(
    -- get top 3 level 0 concepts
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
                        json_extract_scalar(author, '$.id') as id,
                        json_extract_scalar(c, '$.display_name') as c_name,
                        CAST(json_extract_scalar(c, '$.level') as INT) as c_level,
                        CAST(json_extract_scalar(c, '$.score') as DECIMAL) as c_score,

                    FROM `UNFORMATTED_AUTHORS_TABLE` as file
                    left join unnest(json_extract_array(author, '$.x_concepts')) as c
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
)AS data1
ON data0.id = data1.id
-- get carnegie classification for author's institution
LEFT OUTER JOIN `CARNEGIE_CLASSIFICATION_TABLE` as data2
ON data0.affiliation_name = data2.affiliation_name
LIMIT 1000