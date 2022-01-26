

process_rslts <- function(rslts_raw, patch_rslts) {
  rslts <- rslts_raw |>
    filter(`Přístupový kód` != "b2Tc6S0KoU8StiB") |> # respondent s nesmyslnými odpověďmi
    rename(token = `Přístupový kód`) |>
    mutate(resort = na_if(resort, "DOPLNIT"),
           sekce = na_if(sekce, "DOPLNIT"),
           utvar = na_if(utvar, "DOPLNIT")) |>
    rows_update(patch_rslts) |>
    select(-Jméno, -Příjmení, -matches("email"))
}

process_invts <- function(invts_raw, patch_invts) {
  invts <- invts_raw |>
    bind_rows(patch_invts) |>
    mutate(email = tolower(email))

}

lengthen_rslts <- function(rslts) {
  rslts_long <- rslts |>
    select(-`Datum odeslání`, -`Celkový čas`, -`Poslední strana`) |>
    gather("key", "value",
           -c(`ID odpovědi`, token,
              pozice, pohlavi, resort, sekce, utvar)) |>
    rename(response_id = `ID odpovědi`) |>
    filter(!str_detect(key, "vyplňte prosím Váš email|až do konce")) |>
    separate(key, into = c("question", "item"), sep = " \\[", fill = "right") |>
    mutate(item = str_remove(item, "\\]"),
           question = str_replace_all(question, "\\{TOKEN:ATTRIBUTE_1\\}", "[vedoucí/ředitel]"))

}


process_dbau <- function(dbau_raw, invts, rslts) {

  token_email_key <- rslts |>
    select(token) |>
    left_join(invts |>
                select(token, email))
  dbau_raw |>
    mutate(vyplnil_dotaznik = Email %in% token_email_key$email,
           pozvany = Email %in% invts$email)

}

process_staffnums <- function(rslts_long) {
  stafnums <- rslts_long |>
    filter(str_detect(question, "[Kk]olik")) |>
    drop_na(value) |>
    mutate(value = as.numeric(value),
           oddeleni = str_detect(question, "oddělení"),
           question = str_remove(question, "\\(přepočteno na plné úvazky\\)"),
           q_short = if_else(str_detect(question, "analyt"),
                             "analytici",
                             "all"),
           utvar = if_else(oddeleni, "Oddělení", "Odbory"))
}

widen_staffnums <- function(rslts_staffnums) {
  rslts_staffnums |>
    mutate() |>
    select(token, oddeleni, q_short, value, utvar) |>
    spread(q_short, value) |>
    mutate(ostatní = all - analytici) |>
    select(token, oddeleni, analytici, ostatní, all, utvar) |>
    mutate(podil = analytici/(analytici + ostatní))
}

lengthen_staffnums <- function(rslts_staffnums_wide) {
  gather(rslts_staffnums_wide, "typ", "pocet", -token, -all, -oddeleni,
         -utvar, -podil) |>
    mutate(token = as.factor(token) |> fct_reorder(pocet, sum,.desc = TRUE))
}



