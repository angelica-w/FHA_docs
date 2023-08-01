# Accessing Data from OpenAlex

## Downloading from AWS S3 to Own Machine

---

OpenAlex hosts their data in their own [bucket on S3], so we need to first download it. According to OpenAlex, the gzip-compressed snapshot is 330 GB while the decompressed snapshot is 1.6 TB, so we decided to download the snapshot to the scratch folder in Savio.

1. ssh to data transfer node on Savio (dtn.brc.berkeley.edu)
2. Install aws cli package  
   `pip install --user awscli`
3. Load python and set path to package  
   `module load python`  
   `export PATH=~/.local/bin:PATH`
4. Start loading data to Savio (**make sure to set destination to scratch folder**)  
   `aws s3 sync "s3://openalex" "PATH_TO_SCRATCH" --no-sign-request`

This finished downloading the May 3, 2023 snapshot of OpenAlex in a couple hours.

## Uploading from Machine to BigQuery

---

We decided to use [BigQuery] to work with the data because it's specifically designed to interact with large datasets efficiently.

We were only interested in the authors and works data, so there are only Python scripts for uploading the authors and works data to BigQuery ([upload_authors.py], [upload_works.py]). However, they can be easily modified to be used to upload any other data provided by OpenAlex. For the most part, these scripts follow the logic in Openalex's [documentation], executing any of the shell commands with Python instead.

For the May 3, 2023 snapshot of OpenAlex:

- authors data has ~34 million rows; ~1.5 hrs to upload
- works data has ~240 million rows; 26 hrs to upload

**NOTE:** data files are in JSON Lines format, where each row is one object

- when uploading, needed to make the data fit in CSV format, where each table has 1 column and each row is a JSON object

## Formatting Data on BigQuery

---

We then unnest and reformatted the uploaded tables so that they were multi-column tables, whhere each column is a field (id, name, etc.).

### Authors Data

- [format_author.sql]: formats tables and adds carnegie classification based on authors' affiliated institution

### Works Data

BigQuery has a 6 hr limit for queries, and trying to format the entire works table at once exceeds this. This is probably because we're joining the authors and referenced works lists of each work, expanding the ~230 million row works table to ~8 billion rows. So rather than formatting the entire works table at once, we split the works table into 3 separate tables with information about a work's authors, cited works, and concept.

- [format_work_author.sql]: formats table of works with their authors
  - every work may appear on multiple rows, once for each author
- [format_work_cited.sql]: formats table of works with the works it cites (this work => other works)
  - every work may appear on multiple rows, once for each work it cites
- [format_work_concept.sql]: formats table of works and their top concept
  - every work only appears once, and only their top level 0 concept is listed

[bucket on S3]: https://openalex.s3.amazonaws.com/browse.html
[BigQuery]: https://cloud.google.com/bigquery
[documentation]: https://docs.openalex.org/download-all-data/upload-to-your-database/load-to-a-data-warehouse
[upload_authors.py]: ../FHA_docs/savio_to_bigquery/upload_authors.py
[upload_works.py]: ../FHA_docs/savio_to_bigquery/upload_works.py
[format_author.sql]: ../FHA_docs/savio_to_bigquery/format_author.sql
[format_work_author.sql]: ../FHA_docs/savio_to_bigquery/format_work_author.sql
[format_work_cited.sql]: ../FHA_docs/savio_to_bigquery/format_work_cited.sql
[format_work_concept.sql]: ../FHA_docs/savio_to_bigquery/format_work_concept.sql
