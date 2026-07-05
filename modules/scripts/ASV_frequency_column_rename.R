library(readr)
library(dplyr)

table <- read_tsv("exported-table/feature-table.tsv", skip=1)
metadata <- read_tsv("sample-metadata.tsv")

id_map <- setNames(metadata$description, metadata$`sample-id`)  # swap column name as needed
colnames(table)[-1] <- id_map[colnames(table)[-1]]  # -1 keeps the ASV ID column untouched

write_tsv(table, "feature-table-renamed.tsv")
