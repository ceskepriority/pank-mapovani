
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pank-mapovani

<!-- badges: start -->
<!-- badges: end -->

Tento repozitář obsahuje kód na zpracování a vizualizaci dat z
dotazníkového šetření mapování analytických kapacit ve státní správě -
výstup projektu PANK (Podpora analytických kapacit ve veřejné správě).

Kód vyžaduje neveřejná individuální data z šetření. Názvy potřebných
souborů jsou zaznamenány v `_targets.R` a podle nich je lze dohledat na
Google Drive.

Kód je organizován jako reprodukovatelná `{targets}` pipeline s
verzovanými záznamy použitých balíků, takže celý proces se po vložení
vstupních souborů dá spustit následně:

``` r
renv::restore()
targets::tar_make()
```

Hlavním výstupem jsou grafy v adresáři `charts-output`, použité v
dokumentu shrnujícím hlavní poznatky ze šetření.

Realizováno díky projektu PANK: Podpora analytických kapacit ve veřejné
správě, [podpořeno TAČR v programu
Éta](https://starfos.tacr.cz/cs/project/TL05000330).

Více k projektu na [pank.cz](https://pank.cz)

<details>
<summary>
Session info
</summary>

``` r
sessionInfo()
#> R version 4.1.2 (2021-11-01)
#> Platform: x86_64-apple-darwin17.0 (64-bit)
#> Running under: macOS Big Sur 10.16
#> 
#> Matrix products: default
#> BLAS:   /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRblas.0.dylib
#> LAPACK: /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRlapack.dylib
#> 
#> locale:
#> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices datasets  utils     methods   base     
#> 
#> loaded via a namespace (and not attached):
#>  [1] compiler_4.1.2  magrittr_2.0.1  fastmap_1.1.0   htmltools_0.5.2
#>  [5] tools_4.1.2     yaml_2.2.1      stringi_1.7.6   rmarkdown_2.11 
#>  [9] knitr_1.37      stringr_1.4.0   xfun_0.29       digest_0.6.29  
#> [13] rlang_0.4.12    renv_0.14.0     evaluate_0.14
```

</details>

Generováno 2022-01-26 22:42:44
