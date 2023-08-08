# Creating Tables for Primary Analysis

Our analyses (lagged regressions) will focus on 3 main DVs:

1. Number of citations per year, at the level of the author
2. Number of lifetime citations per year, at the level of the author
3. Percentile Ranking per year, at the level of the author

A helpful table for creating the tables needed for the 3 DVs is a table of the number of citations per year, at the level of the work:

- [get_work_cites_per_yr.sql]:
  - for every work, gets the number of citations it received every year since publication
  - uses the works_cited table and a works table that's grouped on id, such that every work only appears once
    - for a given work, finds all the works that cites it
      🠊 groups by work id and year, counting the number of rows

The following code was used to create tables for the analyses of each of the 3 DVs:

- [get_author_cites_per_yr.sql]:
  - for every author, gets the number of citations they received every year across all their works since the year of their 1st publication
  - uses the works_authors table, authors table, and the previous work_cites_per_yr table
    - for every author, finds their works and how many times those works were cited each year 🠊 groups on author id and year, summing the citations per year
- [get_lifetime_cites.sql]:

  - for every author, gets the total number of lifetime citations works published in a given year received
  - a work's lifetime citation was limited to the total number of citations it received within 10 years since publication
    - 10 years was chosen as the cutoff because looking at the distritubtion of citations over time, it seemed like works receive a good portion of their total citations within 10 years of publication
  - uses the works_authors table, authors table, and works_cited table
    - for every author, finds their works and how many times those works were cited within 10 years of publication 🠊 groups on author id and year, summing lifetime citations

- [get_author_rank.sql]:
  - for every author, get their percentile rank every year relative to other authors with the same concept, 1st publication year, and academic age
    - percentile rank calculated based on the total number of citations an author received for a given year
  - uses authors table and the previous author_cites_per_yr table
    - groups on concept, start year, and academic age, calculating percentile rank by citation counts

Correlation matrices for each of the 3 DVs can be found in the [figures folder]. There are 2 figures for each DV: one of a single correlation matrix across all concepts and one of multiple correlation matrices, grouped by concept. The code for the correlation matrices is in the [correlation_matrices] Jupyter Notebook.

## Note: Dataset Filtering

We are only including the complete citation histories of all works published between 1665 and 2013, as well as the authors who published these works.

- 1665 as minimum cutoff because that was the seminal year of the 1st academic journal, Journal des Sçavans
- 2013 as maximum cutoff due to concerns of right-censoring (10-yr horizon for lifetime citations means 2013 is the maximum)

[get_work_cites_per_yr.sql]: ../primary_analysis/get_work_cites_per_yr.sql
[get_author_cites_per_yr.sql]: ../primary_analysis/get_author_cites_per_yr.sql
[get_author_rank.sql]: ../primary_analysis/get_author_rank.sql
[get_lifetime_cites.sql]: ../primary_analysis/get_lifetime_cites.sql
[get_work_cites_per_yr.sql]: ../primary_analysis/get_work_cites_per_yr.sql
[figures folder]: ../primary_analysis/figures
[correlation_matrices]: ../primary_analysis/correlation_matrices.ipynb
