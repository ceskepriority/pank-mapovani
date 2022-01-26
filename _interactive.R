source("_targets_packages.R")
source("R/R.R")

library(targets)
library(tarchetypes)
library(usethis)

options(scipen = 9)

ts <- as.list(targets::tar_manifest(fields = name)[["name"]])
names(ts) <- ts
