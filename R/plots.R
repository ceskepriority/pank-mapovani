theme_studie <- function(gridlines = "x", multiplot = FALSE) {
  ptrr::theme_ptrr(gridlines = gridlines, family = "Nunito Sans",
                   multiplot = multiplot,
                   title_family = "Nunito Sans",
                   axis.text.x = element_text(colour = "black"),
                   legend.position = "top",
                   legend.key.width = unit(8, "pt"),
                   legend.margin = margin(c(0, 0, 0, 0), "pt"),
                   legend.box.margin = margin(c(0,0,-10,0), "pt"),
                   panel.spacing = unit(6, "pt"),
                   plot.margin = margin(c(6, 10, 6, 6), "pt"),
                   plot.background = element_rect(fill = "white", colour = NA),
                   legend.key.height = unit(12, "pt")
                   )
}

# table(invts$token %in% rslts$token)
# table(rslts$token %in% invts$token)
# table(token_email_key$email %in% dbau$Email)
#
# table(is.na(token_email_key$email))
#
#
#
# rslts_long |>
#   distinct(question)

plot_heatmap <- function(data, q_pattern, title = NULL, subtitle = NULL,
                         caption = NULL) {
  data |>
    filter(str_detect(question, q_pattern)) |>
    select(item, value) |>
    mutate(value = str_wrap(value, 35)) |>
    separate(item, into = c("x", "order"), sep = " ", remove = FALSE, convert = TRUE) |>
    drop_na(value) |>
    count(item, order, value, sort = T) |>
    mutate(value_wtd = n * (4 - order)) |>
    mutate(value = as.factor(value) |> fct_reorder(value_wtd, .fun = sum)) |>
    ggplot(aes(order, value, fill = n)) +
    geom_tile(colour = "white", size = 1) +
    geom_text(aes(label = n, colour = after_scale(coloratio::cr_choose_bw(fill))),
              family = "Nunito Sans") +
    scale_fill_viridis_c(option = "cividis", name = "počet", guide = "none") +
    scale_x_continuous(expand = ptrr::flush_axis, position = "top") +
    labs(title = title,
         subtitle = "1 = nejvyšší priorita.\nŘazeno podle počtu váženého prioritou",
         caption = caption,
         axis.text.x = element_text(face = "bold")) +
    theme_studie("none")
}

prep_plot_data <- function(data, q_pattern, scale_keys, key_wrap, item_wrap = 35) {
  dta <- data |>
    filter(str_detect(question, q_pattern), !item %in% c("Komentář")) |>
    select(item, value) |>
    drop_na(value) |>
    count(item, value) |>
    mutate(value = str_wrap(value, key_wrap), value = as.factor(value))

  if(!is.null(scale_keys)) {
    scale_keys <- str_wrap(scale_keys, key_wrap)
    dta <- dta |>
      mutate(value = fct_relevel(value, scale_keys) |> fct_rev())
  }
  dta <- dta |>
    mutate(item = str_wrap(item, item_wrap) |>
             as.factor() |> fct_reorder(as.numeric(value) * n, sum)) |>
    group_by(item) |>
    mutate(perc = n/sum(n, na.rm = TRUE)) |>
    group_by(item) |>
    arrange(desc(value)) |>
    mutate(perc_cum = cumsum(perc),
           label = if_else(perc > .05, round(perc * 100), NA_real_)) |>
    ungroup()

  dta
}

plot_stacked <- function(data, q_pattern,
                         scale_keys = c("Velmi často", "Často", "Občas", "Nikdy"),
                         scale_palette = "Blues",
                         key_wrap = 15,
                         item_wrap = 35,
                         title = NULL, subtitle = NULL,
                         caption = NULL) {


  dta <- prep_plot_data(data, q_pattern, scale_keys, key_wrap, item_wrap)

  plt <- ggplot(dta, aes(perc, item, fill = value)) +
    geom_col(position = "stack") +
    geom_text(aes(label = label, group = item, x = perc_cum,
                  colour = after_scale(coloratio::cr_choose_bw(fill))),
              nudge_x = -.015, hjust = 1, family = "Nunito Sans", size = 3) +
    theme_studie() +
    ptrr::scale_x_percent_cz(expand = ptrr::flush_axis) +
    labs(title = title, subtitle = subtitle, caption = caption)

  if(!is.null(scale_keys)) {
    scale_keys <- str_wrap(scale_keys, key_wrap)
    plt <- plt +
      scale_fill_brewer(name = NULL,
                        breaks = scale_keys, drop = FALSE,
                        palette = scale_palette,
                        guide = "legend")
  }
  plt
}

plot_bars <- function(data, q_pattern, percent = FALSE,
                      scale_keys = NULL,
                      scale_palette = "Blues",
                      key_wrap = 15,
                      title = NULL, subtitle = NULL,
                      caption = NULL) {

  dta <- prep_plot_data(data, q_pattern, scale_keys, key_wrap)

  plt <- ggplot(dta) +
    geom_col(aes(n, value), fill = "darkblue") +
    theme_studie() +
    scale_x_continuous(expand = ptrr::flush_axis) +
    labs(title = title, subtitle = subtitle, caption = caption)
  plt
}

plot_respondents <- function(dbau) {
  data <- dbau |>
    filter(pozvany) |>
    drop_na(Resort) |>
    mutate(Resort = if_else(str_detect(Resort, "^MF"), "MF", Resort)) |>
    count(Resort, vyplnil_dotaznik) |>
    mutate(Resort = as.factor(Resort) |> fct_reorder(n, sum)) |>
    group_by(Resort) |>
    arrange(desc(vyplnil_dotaznik)) |>
    mutate(x_cum = cumsum(n))

  ggplot(data, aes(n, Resort, fill = vyplnil_dotaznik)) +
    geom_col() +
    geom_text(aes(x = x_cum, label = round(n),
                  colour = after_scale(cr_choose_bw(fill))),
              family = "Nunito Sans", nudge_x = -0.25, hjust = 1) +
    theme_studie("x") +
    theme(legend.position = "top",
          plot.background = element_rect(fill = "white",
                                         colour = NA)) +
    scale_x_continuous(expand = ptrr::flush_axis) +
    scale_fill_manual(values = c("darkgrey", "darkblue"),
                      labels = c("Ne", "Ano"),
                      name = "Vyplnil/a dotazník") +
    guides(fill = guide_legend(reverse = T)) +
    labs(title = "Identifikované / oslovené útvary a návratnost odpovědí")
}

plot_staff_indiv <- function(rslts_staffnums_long) {
  ggplot(rslts_staffnums_long |>
           mutate(typ = as.factor(typ) |> fct_rev()),
         aes(token, pocet, fill = typ)) +
    geom_col() +
    scale_y_continuous(expand = flush_axis, n.breaks = 7) +
    theme_studie("y", multiplot = TRUE) +
    scale_fill_manual(values = c("darkblue", "darkgrey"),
                      breaks = c("analytici", "ostatní"),
                      labels = c("Analytická práce", "Jiné"),
                      name = "Pracovní náplň zaměstnance") +
    facet_wrap(~utvar) +
    theme(axis.text.x = element_blank()) +
    labs(title = "Počty zaměstnanců a analytiků v jednotlivých útvarech",
         subtitle = "Co sloupec, to útvar (název pro přehlednost nezobrazen)")
}

plot_staff_dotplot <- function(rslts_staffnums, odbor = TRUE) {

  utvar_typ <- ifelse(!odbor, "Oddělení", "Odbor")
  utvar_typ_pl <- ifelse(!odbor, "Oddělení", "Odbory")

  rslts_staffnums |>
    filter(oddeleni == !odbor) |>
    ggplot(aes(value)) +
    geom_dotplot(binwidth = 1, dotsize = .8, stackratio = .8) +
    facet_wrap(~question, nrow = 2,
               labeller = label_wrap_gen(80), scales = "fixed") +
    scale_y_continuous(labels = NULL, breaks = NULL,
                       expand = expansion(add = c(0, 2 ), mult = c(0, 0))) +
    theme_studie(multiplot = TRUE) +
    theme(axis.title.x = element_text()) +
    labs(title = str_glue("{utvar_typ_pl}: počty všech zaměstanců a analytiků"),
         x = "Počet úvazků",
         subtitle = str_glue("Co bod, to {tolower(utvar_typ)} | Analytici = vykonávají analytickou činnost"))
}

plot_staff_hist <- function(rslts_staffnums_long) {
  ggplot(rslts_staffnums_long, aes(podil)) +
    geom_histogram(bins = 8) +
    theme_studie("y", multiplot = TRUE) +
    theme(axis.title.x = element_text()) +
    facet_wrap(~utvar) +
    scale_x_percent_cz() +
    scale_y_number_cz() +
    labs(title = "Rozdělení útvarů podle podílu analytiků",
         x = "Podíl zaměstnanců útvaru, kteří vykonávají analytickou práci")
}


# qd_data <- rslts_long |>
#   filter(str_detect(question, "Jak často využívají analytici Vašeho útvaru následující zdroje dat")) |>
#   select(item, value) |>
#   drop_na(value) |>
#   count(item, value) |>
#   mutate(value = as.factor(value) |> fct_relevel("Nikdy", "Občas", "Často"),
#          item = str_wrap(item, 35) |>
#            as.factor() |> fct_reorder(as.numeric(value) * n, sum))
#
# ggplot(qd_data) +
#   geom_col(aes(n, item, fill = value), position = "fill") +
#   scale_fill_brewer(breaks = c("Velmi často", "Často", "Občas", "Nikdy"),
#                     name = NULL) +
#   ptrr::theme_ptrr("x", legend.position = "top", legend.key.width = unit(8, "pt"),
#                    legend.key.height = unit(12, "pt")) +
#   ptrr::scale_x_percent_cz() +
#   labs(title = "Frekvence využívání různých typů dat")

#
# rslts_long |>
#   filter(str_detect(question, "Na který z analytických nástrojů by se mělo")) |>
#   select(item, value) |>
#   mutate(value = str_wrap(value, 35)) |>
#   separate(item, into = c("x", "order"), sep = " ", remove = FALSE, convert = TRUE) |>
#   drop_na(value) |>
#   count(item, order, value, sort = T) |>
#   mutate(value_wtd = n * (4 - order)) |>
#   mutate(value = as.factor(value) |> fct_reorder(value_wtd, .fun = sum)) |>
#   ggplot(aes(order, value, fill = n)) +
#   geom_tile(colour = "white", size = 1) +
#   geom_text(aes(label = n, colour = after_scale(coloratio::cr_choose_bw(fill)))) +
#   scale_fill_viridis_c(option = "cividis", name = "počet") +
#   labs(title = "Prioritní vzdělávací potřeby: analytické nástroje",
#        subtitle = "1 = nejvyšší priorita.\nŘazeno podle počtu váženého prioritou") +
#   ptrr::theme_ptrr("none")

