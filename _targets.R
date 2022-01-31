library(targets)
library(tarchetypes)

options(conflicts.policy = list(warn = FALSE))
options(clustermq.scheduler = "LOCAL")
options(crayon.enabled = TRUE,
        scipen = 100,
        yaml.eval.expr = TRUE)

source("R/utils.R")
source("R/data.R")
source("R/plots.R")

# Set target-specific options such as packages.
tar_option_set(packages = c("dplyr", "tidyr", "readr", "readxl", "writexl",
                            "forcats", "stringr", "here", "ggplot2", "ptrr",
                            "coloratio", "ragg"))

list(
  tar_file(dbau_file,        here::here("data-input", "PANK - Databáze analytických útvarů ve VS.xlsx")),
  tar_file(invts_file,       here::here("data-input", "pank_dotaznik_stav_211122.xlsx")),
  tar_file(rslts_file,       here::here("data-input", "mapovani_vysledky_211203_1100.xlsx")),
  tar_file(patch_invts_file, here::here("data-input", "patch_invites.csv")),
  tar_file(patch_rslts_file, here::here("data-input", "patch_results.csv")),

  tar_target(dbau_raw,
             read_excel(dbau_file, sheet = "Contact Tracking") |>
               mutate(Email = tolower(Email))),
  tar_target(rslts_raw,   read_excel(rslts_file)),
  tar_target(invts_raw,   read_excel(invts_file)),
  tar_target(patch_invts, read_csv(patch_invts_file)),
  tar_target(patch_rslts, read_csv(patch_rslts_file)),

  tar_target(rslts, process_rslts(rslts_raw, patch_rslts)),
  tar_target(invts, process_invts(invts_raw, patch_invts)),
  tar_target(rslts_long, lengthen_rslts(rslts)),
  tar_target(dbau, process_dbau(dbau_raw, invts, rslts)),

  tar_target(rslts_staffnums, process_staffnums(rslts_long)),
  tar_target(rslts_staffnums_wide, widen_staffnums(rslts_staffnums)),
  tar_target(rslts_staffnums_long, lengthen_staffnums(rslts_staffnums_wide)),

  tar_target(pl_data,
             plot_stacked(rslts_long, "využívají analytici Vašeho útvaru následující zdroje dat",
                          title = "Zdroje dat",
                          scale_keys = scales_freq,
                          scale_palette = "Blues",
                          subtitle = "Jak často využívají analytici Vašeho útvaru následující zdroje dat?")),
  tar_target(pl_nastroje_uceni,
             plot_heatmap(rslts_long, "Na který z analytických nástrojů by se mělo",
                          "Vzdělávací priority: analytické nástroje",
                          subtitle = "1 = nejvyšší priorita")),
  tar_target(pl_nastroje_vyuziti, plot_stacked(rslts_long,
                                   "Jak často jsou ve Vašem útvaru využívány následující analytické nástroje?",
                                   title = "Využití analytických nástrojů")),
  tar_target(pl_uceni, plot_heatmap(rslts_long,
                                    "prioritní vzdělávací potřeby analytiků útvaru",
                                    "Vzdělávací priority: celkově")),

  tar_target(pl_cinnost, plot_stacked(rslts_long, "Jaké typy analytických činností vykonávají",
               scale_keys = scales_freq,
               scale_palette = "Blues",
               title = "Činnosti analytických útvarů")),
  tar_target(pl_org, plot_bars(rslts_long, "organizováni zaměstnanci, kteří vykonávají analytické činnosti?",
                               scale_keys = c("Celý odbor je zaměřený na analytickou činnost.",
                                              "V jednotlivých odděleních pracují analytici spolu s jinak zaměřenými zaměstnanci.",
                                              "V odboru je více analytických oddělení.",
                                              "V odboru je oddělení zaměřené na analytickou činnost.",
                                              "Jiné (vypište prosím v komentáři):"),
                               title = "Organizace analytiků v odboru",
                               key_wrap = 42)),
  tar_target(pl_resp, plot_respondents(dbau)),
  tar_target(pl_staff_dotplot_odd, plot_staff_dotplot(rslts_staffnums, odbor = FALSE)),
  tar_target(pl_staff_dotplot_odb, plot_staff_dotplot(rslts_staffnums, odbor = TRUE)),
  tar_target(pl_staff_indiv, plot_staff_indiv(rslts_staffnums_long)),
  tar_target(pl_staff_hist, plot_staff_hist(rslts_staffnums_long)),
  tar_target(pl_pocet_hodn, plot_stacked(rslts_long, "Odpovídá tento počet",
                                         title = "Odpovídá počet zaměstnanců potřebám?")),
  tar_target(pl_pocet_hodn_bars, plot_bars(rslts_long, "Odpovídá tento počet", scale_keys = NULL,
                                           title = "Odpovídá počet zaměstnanců potřebám?")),
  tar_target(pl_hodn, plot_stacked(rslts_long |>
                                     mutate(item = str_replace(item, "oddělení|odboru",
                                                               "[oddělení/odboru]")),
                                   "Do jaké míry souhlasíte s následujícími výroky?",
                                   scale_palette = "BrBG",
                                   scale_keys = likert_agree,
                                   key_wrap = 14,
                                   title = "Do jaké míry souhlasíte s následujícími výroky?") +
               theme(legend.justification = c(1, 1))),
  tar_target(pl_vystupy, plot_stacked(rslts_long, "Jaká část vašich analytických výstupů je zveřejněna",
               scale_keys = rev(c("Žádné", "Pouze malá část", "Přibližně polovina",
                                  "Většina", "Všechny")), scale_palette = "RdYlGn") +
               theme(axis.text.y = element_blank())),
  tar_target(pl_vyuziti, plot_stacked(rslts_long, "využívány ve Vaší organizaci",
                                      scale_keys = c(scales_freq[1:4], "Nevím"),
                                      title = "Využití výstupů útvaru",
                                      subtitle = "Do jaké míry jsou analýzy Vašeho útvaru využívány ve Vaší organizaci, popř. mimo ni?")),
  tar_target(pl_vystupy_bars, plot_bars(rslts_long, "Jaká část vašich analytických výstupů je zveřejněna",
                                        scale_keys = rev(c("Žádné", "Pouze malá část", "Přibližně polovina",
                                                           "Většina", "Všechny")),
                                        title = "Jaká část výstupů Vašeho útvaru je zveřejněna?",
                                        scale_palette = "RdYlGn", key_wrap = 100)),
  tar_target(pl_expertiza,
             plot_stacked(rslts_long |>
                            mutate(item = str_replace(item, "příspěvkové organizace", "přísp. org.") |>
                                     str_replace("výzkumné instituce", " výzk. inst.") |>
                                     str_remove("apod\\.")),
                          "Využívá Váš útvar následující způsoby k získávání expertíz",
                          title = "Způsoby získávání expertíz, analýz a poradenství",
                          subtitle = "řazeno podle frekvence využití",
                          item_wrap = 45)),

  tar_file(ex_pocet_hodn_bars, save_plot(pl_pocet_hodn_bars, height_cm = 6)),
  tar_file(ex_pocet_hodn, save_plot(pl_pocet_hodn, height_cm = 3)),
  tar_file(ex_hodn, save_plot(pl_hodn, height_cm = 6)),
  tar_file(ex_cinnost, save_plot(pl_cinnost, height_cm = 9.5)),
  tar_file(ex_expertiza, save_plot(pl_expertiza, height_cm = 7)),
  tar_file(ex_vyuziti, save_plot(pl_vyuziti, height_cm = 6)),
  tar_file(ex_vystupy_bars, save_plot(pl_vystupy_bars, height_cm = 6)),
  tar_file(ex_uceni, save_plot(pl_uceni, height_cm = 10)),
  tar_file(ex_staff_dotplot_odd, save_plot(pl_staff_dotplot_odd, height_cm = 12)),
  tar_file(ex_staff_dotplot_odb, save_plot(pl_staff_dotplot_odb, height_cm = 10)),
  tar_file(ex_staff_indiv, save_plot(pl_staff_indiv, height_cm = 7)),
  tar_file(ex_staff_hist, save_plot(pl_staff_hist, height_cm = 7)),
  tar_file(ex_org, save_plot(pl_org, height_cm = 6)),
  tar_file(ex_data, save_plot(pl_data, height_cm = 9.5)),
  tar_file(ex_nastroje_vyuziti, save_plot(pl_nastroje_vyuziti, height_cm = 11)),
  tar_file(ex_nastroje_uceni, save_plot(pl_nastroje_uceni, height_cm = 11)),
  tar_file(ex_resp, save_plot(pl_resp, height_cm = 9)),

  tar_file(rslts_export, {write_xlsx(list(data = rslts, data_long = rslts_long),
                                     here::here("data-export", "results.xlsx"))
    here::here("data-export", "results.xlsx")
    }),
  tar_file(db_export, {write_xlsx(list(data = dbau),
                                     here::here("data-export", "databaze.xlsx"))
    here::here("data-export", "databaze.xlsx")
    })
)
