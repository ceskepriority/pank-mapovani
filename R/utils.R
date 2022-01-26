likert_agree <- c("Rozhodně souhlasím", "Spíše souhlasím",
                  "Ani souhlasím, ani nesouhlasím",
                  "Spíše nesouhlasím", "Rozhodně nesouhlasím")

scales_freq <- c("Velmi často", "Často", "Občas", "Nikdy",
                 "Nevím, nedokážu posoudit")


save_plot <- function(plot, format = "png", dir = "charts-output",
                      width_cm = 16.5, height_cm = width_cm * 2/3) {
  plot_stem <- deparse(substitute(plot))
  plot_file <- file.path(dir, paste0(plot_stem, ".", format))

  ggsave(filename = plot_file, plot = plot,
         dpi = 300, width = width_cm, height = height_cm, units = "cm")
}
