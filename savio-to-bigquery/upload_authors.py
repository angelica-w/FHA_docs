'''
Load OpenAlex Author files from own machine (in this case Savio) to BigQuery

OpenAlex stores files JSON Lines format
⇒ parse each file depending on newlines and tabs
⇒ loaded to BigQuery as CSV table with single "author" column, where each cell has the JSON object of each author

Need:
- BigQuery account and project
- file path to the BigQuery service account key JSON file
- directory where OpenAlex files are stored
'''

from google.cloud import bigquery
from google.oauth2 import service_account
from google.cloud.exceptions import NotFound
import os
import gzip
import json
import fnmatch
from io import BytesIO

# replace with path to your service account key JSON file
credentials = service_account.Credentials.from_service_account_file("PATH_TO_SERVICE_ACCOUNT_KEY")
client = bigquery.Client(credentials = credentials, project = "openalex-bigquery")      # Construct BigQuery client object

project_id = "openalex-bigquery"        # change to BigQuery project name
dataset_id = "2023_05_03_snapshot"      # change name depending on snapshot being uploaded
table_id = "authors"        # change name depending on type of files being loaded

parent_directory = "PATH_TO_DIRECTORY_OF_AUTHOR_FILES"       # path to parent directory with files

schema = [
    bigquery.SchemaField("author", "STRING"),       # change schema name depending on type of files being loaded
]

# create table if bigquery table if doesn't exist
table_ref = bigquery.TableReference.from_string(f'{project_id}.{dataset_id}.{table_id}')
table = bigquery.Table(table_ref, schema=schema)
table = client.create_table(table, exists_ok=True)

existing_table = client.get_table(table_ref)
schema_fields = existing_table.schema

# specify job to read each file as a CSV with tab deliminator and append all files to a single "authors" BigQuery table
job_config = bigquery.LoadJobConfig()
job_config.write_disposition = bigquery.WriteDisposition.WRITE_APPEND
job_config.source_format = bigquery.SourceFormat.CSV
job_config.field_delimiter = '\t'
job_config.schema = schema_fields

table = client.get_table(table_ref)

# travels through each gzipped file in the directory and load to BigQuery table
for root, dirs, files in os.walk(parent_directory):
    for file in files:
        if file.endswith('.gz'):
            gz_path = os.path.join(root, file)

            # unzip file
            with gzip.open(gz_path, 'rb') as gzip_file:
                file_content = gzip_file.read().decode('utf-8')
            lines = file_content.strip().split('\n')        # each JSON object is separated by newline
            file_obj = BytesIO()
            
            # read each JSON object as separate row in file_obj
            for line in lines:
                json_object = json.loads(line)
                row = '\t'.join([json.dumps(json_object)])      # fields of JSON object are separated by tab
                file_obj.write(row.encode('utf-8'))
                file_obj.write(b'\n')

            # pass in file_obj to load data to BigQuery    
            file_obj.seek(0)
            load_job = client.load_table_from_file(file_obj, table, job_config=job_config)
            load_job.result()
            print(f'{gz_path} loaded to bigquery')
     