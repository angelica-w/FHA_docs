# FHA Documentation

This page includes the code used to access and format the data from [OpenAlex] for analysis.

OpenAlex is an open scholarly database that includes information about scholars and their works. Our analyses were conducted on the May 3, 2023 snapshot of the data, which contains 34,725,938 scholars and 239,690,211 works. More descriptives about the data were generated as well ([descriptives])

The dataset was collected and used by:

1. Downloading the most recent database snapshot (May 3, 2023) of OpenAlex available at the time, uploading it to Google's BigQuery, and formatting the necessary tables ([savio_to_bigquery])
2. Creating tables for our primary analyses ([primary_analysis])
3. Creating additional tables for exploratory analysis ([exploratory_analysis])

This research used the [Savio computational cluster resource] provided by the Berkeley Research Computing program at the University of California, Berkeley (supported by the UC Berkeley Chancellor, Vice Chancellor for Research, and Chief Information Officer).

[OpenAlex]: https://openalex.org/
[savio_to_bigquery]: ../main/savio_to_bigquery
[primary_analysis]: ../primary_analysis
[exploratory_analysis]: ../exploratory_analysis
[descriptives]: ../descriptives
[Savio computational cluster resource]: https://docs-research-it.berkeley.edu/services/high-performance-computing/overview/
