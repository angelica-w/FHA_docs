# Exploratory Tests

## Replication of Tian & Ipeirotis (2021)

---

We created a correlation matrix using the rank percentile indicator developed by Tian & Ipeirotis (2021). To construct this indicator, we first calculated the percentile rank of each of an author's works 5 years after publication ([get_percent_rank.sql]). Given these values, an author's percentile rank is the sum of their works' percentile ranks. We decided to compare authors' percentile ranks across 5-year intervals, so we summed the works' percentile ranks within each relevant time frame (e.g., years 1-5, 6-10, etc.).

Using this table, we created correlation matrices that parallel the ones created by Tian and Ipeirotis. These can be found in the figures folder. One figure is of a single correlation matrix across all concepts, and one is of multiple correlation matrices, grouped by concept. The code for the correlation matrices is in the [tian_ipeirotis] Jupyter Notebook.

## Impact of Eras

---

We were also interested in whether early and late career performance varies as a function of era. We decided to focus on 4 different turning points: End of Waterloo (1815), End of WWI (1918), End of WWII (1945), and the Fall of the Berlin War (1989). Works were categorized as falling within 1 of 5 eras defined by these turning points ([get_work_eras.sql]).

## Continuous Measure of Concept

---

We currently determine an author's concept by selecting the top level 0 concept that OpenAlex has identified. This method isn't perfect because each author could have multiple top level 0 concepts. Because of this, we created another concept variable that is a continuous measure of the average number of citations each field receives ([get_avg_concept_cites_per_yr.sql]).

[get_percent_rank.sql]: ../exploratory_analysis/get_percent_rank.sql
[tian_ipeirotis]: ../exploratory_analysis/tian_ipeirotis.ipynb
[get_work_eras.sql]: ../exploratory_analysis/get_work_eras.sql
[get_avg_concept_cites_per_yr.sql]: ../exploratory_analysis/get_avg_concept_cites_per_yr.sql
