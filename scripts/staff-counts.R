source("_targets_packages.R")
source("R/plots.R")

targets::tar_load(rslts_staffnums)
targets::tar_load(rslts_staffnums_long)
targets::tar_load(rslts_staffnums_wide)

rslts_staffnums |>
  count(question, pozice)

rslts_staffnums |>
  count(value)

rslts_staffnums |>
  distinct(token)

rslts_staffnums_long |>
  filter(oddeleni) |>
  count(token, wt = pocet) |>
  filter(n > 4, n < 11)

27/39

# přes dvě třetiny je mezi 5 a 10

rslts_staffnums_long |> count(wt = pocet)

count(rslts_staffnums_long |> filter(oddeleni),
      typ, wt = pocet)

count(rslts_staffnums_long,
      typ, wt = pocet)

count(rslts_staffnums_long |> filter(!oddeleni),
      typ, wt = pocet)

mean(dt_podil$podil)
median(dt_podil$podil)

sum(rslts_staffnums_wide$analytici)/sum(rslts_staffnums_wide$all)
min(rslts_staffnums_wide$podil[rslts_staffnums_wide$podil > 0])

count(rslts_staffnums_long, typ, wt = pocet)
count(rslts_staffnums_long, wt = pocet)

count(rslts_staffnums_long, utvar, typ, wt = pocet) |>
  group_by(utvar) |>
  mutate(podil = n/sum(n))






























