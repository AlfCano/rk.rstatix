local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.rstatix",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "Modern and robust statistical tests using the rstatix package. Includes Welch ANOVA, ANCOVA, and outlier diagnostics.",
      version = "0.0.1",
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://https://github.com/AlfCano/rk.rstatix",
      license = "GPL (>= 3)"
    )
  )

  # JS Helper to cleanly extract column names without $, [[, or quotes
  js_helpers <- "
    function extractColName(raw) {
        if (!raw) return '';
        var parts = raw.split(/[\\$\\[\\]]/).filter(Boolean);
        return parts[parts.length - 1].replace(/[\"']/g, '');
    }
    function getCol(id) {
        return extractColName(getValue(id));
    }
  "

  # =========================================================================================
  # COMPONENT 1: Robust ANOVA (Welch & Games-Howell)
  # Location: Analysis > Means
  # =========================================================================================
  h_welch <- list("analysis", "means")

  help_welch <- rk.rkh.doc(
      title = rk.rkh.title("Robust ANOVA (Welch & Games-Howell)"),
      summary = rk.rkh.summary("Computes a Welch one-way ANOVA (does not assume equal variances) and the Games-Howell post-hoc test using rstatix.")
  )

  w_vs <- rk.XML.varselector(id.name = "w_vs")
  w_df <- rk.XML.varslot("Data frame", source = "w_vs", classes = "data.frame", required = TRUE, id.name = "w_df")
  w_dv <- rk.XML.varslot("Dependent Variable (Numeric)", source = "w_vs", required = TRUE, id.name = "w_dv", classes = c("numeric", "integer"))
  w_between <- rk.XML.varslot("Grouping Variable (Factor)", source = "w_vs", required = TRUE, id.name = "w_between")

  # Auto-focus logic
  w_logic <- rk.XML.logic(rk.XML.connect(governor = w_df, get = "available", client = w_vs, set = "root"))

  w_effsize <- rk.XML.cbox("Calculate Effect Size (Eta Squared)", value = "TRUE", chk = TRUE, id.name = "w_effsize")
  w_gh <- rk.XML.cbox("Compute Games-Howell Post-hoc Test", value = "TRUE", chk = TRUE, id.name = "w_gh")
  w_save <- rk.XML.saveobj("Save post-hoc results as", initial = "welch_results", chk = FALSE, id.name = "w_save")

  w_dialog <- rk.XML.dialog(label = "Robust ANOVA (Welch & Games-Howell)", child = rk.XML.row(
      w_vs,
      rk.XML.col(
        rk.XML.frame(w_df, w_dv, w_between, label = "Data"),
        rk.XML.frame(w_effsize, w_gh, label = "Options"),
        w_save, rk.XML.stretch()
      )
  ))

  js_calc_welch <- paste0(js_helpers, "
    var df = getValue('w_df');
    var dv = getCol('w_dv');
    var between = getCol('w_between');
    var effsize = getValue('w_effsize') === 'TRUE';
    var gh = getValue('w_gh') === 'TRUE';

    echo('require(rstatix)\\nrequire(dplyr)\\n\\n');

    echo('# 1. Welch ANOVA\\n');
    echo('res_welch <- ' + df + ' %>% rstatix::welch_anova_test(' + dv + ' ~ ' + between + ')\\n');

    if (effsize) {
        echo('\\n# Effect Size (Eta Squared from standard ANOVA)\\n');
        echo('model_aov <- aov(' + dv + ' ~ ' + between + ', data = ' + df + ')\\n');
        echo('res_eff <- rstatix::eta_squared(model_aov)\\n');
    }

    if (gh) {
        echo('\\n# 2. Games-Howell Post-hoc Test\\n');
        echo('res_gh <- ' + df + ' %>% rstatix::games_howell_test(' + dv + ' ~ ' + between + ')\\n');
    }

    // NUEVO: Agrupar resultados en una lista si el usuario activó la casilla de guardar
    if (getValue('w_save.active')) {
        echo('\\n# Combine results into a list\\n');
        echo('welch_results <- list(welch_anova = res_welch)\\n');

        if (effsize) { echo('welch_results$effect_size <- res_eff\\n'); }
        if (gh) { echo('welch_results$games_howell <- res_gh\\n'); }
    }
  ")

  js_print_welch <- "
    if (!is_preview) {
        echo('rk.header(\"Robust ANOVA (Welch)\", level = 2)\\n');
        echo('rk.print(\"<b>Test:</b> Welch One-Way ANOVA (Unequal variances assumed)\")\\n');
        echo('rk.results(as.data.frame(res_welch))\\n');

        if (getValue('w_effsize') === 'TRUE') {
            echo('rk.header(\"Effect Size (Eta Squared)\", level = 3)\\n');
            echo('rk.results(as.data.frame(res_eff))\\n');
        }

        if (getValue('w_gh') === 'TRUE') {
            echo('rk.header(\"Games-Howell Post-hoc Test\", level = 3)\\n');
            echo('rk.results(as.data.frame(res_gh))\\n');
        }

        // El mensaje de guardado ahora avisa que es una lista
        if (getValue('w_save.active')) {
            echo('rk.print(paste0(\"<i>All generated results saved to workspace as a list: </i><code>\", \"' + getValue('w_save') + '\", \"</code>\"))\\n');
        }
    }
  "



  # =========================================================================================
  # COMPONENT 2: ANCOVA (Analysis of Covariance)
  # Location: Analysis > Psychology / Social Science > Frequentist
  # =========================================================================================
  h_psych <- list("analysis", "Psychology / Social Science", "Frequentist")

  help_ancova <- rk.rkh.doc(
      title = rk.rkh.title("ANCOVA (Analysis of Covariance)"),
      summary = rk.rkh.summary("Computes ANCOVA and estimated marginal means (EMMeans) adjusting for covariates using rstatix.")
  )

  a_vs <- rk.XML.varselector(id.name = "a_vs")
  a_df <- rk.XML.varslot("Data frame", source = "a_vs", classes = "data.frame", required = TRUE, id.name = "a_df")
  a_dv <- rk.XML.varslot("Dependent Variable (Numeric)", source = "a_vs", required = TRUE, id.name = "a_dv", classes = c("numeric", "integer"))
  a_between <- rk.XML.varslot("Grouping Variable (Factor)", source = "a_vs", required = TRUE, id.name = "a_between")
  a_covar <- rk.XML.varslot("Covariate(s) (Numeric)", source = "a_vs", multi = TRUE, required = TRUE, id.name = "a_covar", classes = c("numeric", "integer"))

  a_logic <- rk.XML.logic(rk.XML.connect(governor = a_df, get = "available", client = a_vs, set = "root"))

  a_emmeans <- rk.XML.cbox("Calculate Estimated Marginal Means (EMMeans)", value = "TRUE", chk = TRUE, id.name = "a_emmeans")
  a_emmeans_posthoc <- rk.XML.cbox("Perform pairwise comparisons for EMMeans (Bonferroni adjusted)", value = "TRUE", chk = TRUE, id.name = "a_emmeans_posthoc")

  a_save <- rk.XML.saveobj("Save all results as (List)", initial = "ancova_results", chk = FALSE, id.name = "a_save")

    a_dialog <- rk.XML.dialog(label = "ANCOVA", child = rk.XML.row(
      a_vs,
      rk.XML.col(
        rk.XML.frame(a_df, a_dv, a_between, a_covar, label = "Data Definition"),
        rk.XML.frame(a_emmeans, a_emmeans_posthoc, label = "Post-hoc & EMMeans"),
        a_save,
        rk.XML.stretch()
      )
  ))

  js_calc_ancova <- paste0(js_helpers, "
    var df = getValue('a_df');
    var dv = getCol('a_dv');
    var between = getCol('a_between');
    var emm = getValue('a_emmeans') === 'TRUE';
    var emm_ph = getValue('a_emmeans_posthoc') === 'TRUE';

    // Parse multiple covariates
    var covar_raw = getValue('a_covar').split('\\n').filter(Boolean);
    var covar = covar_raw.map(extractColName).join(' + ');

    echo('require(rstatix)\\nrequire(dplyr)\\n\\n');

    echo('# 1. ANCOVA\\n');
    echo('res_ancova <- ' + df + ' %>% rstatix::anova_test(' + dv + ' ~ ' + covar + ' + ' + between + ')\\n');

    if (emm) {
        echo('\\n# 2. Estimated Marginal Means\\n');
        var covar_vec = 'c(\"' + covar_raw.map(extractColName).join('\", \"') + '\")';
        echo('res_em <- ' + df + ' %>% rstatix::emmeans_test(' + dv + ' ~ ' + between + ', covariate = ' + covar_vec + ', p.adjust.method = \"bonferroni\")\\n');
        echo('res_em_table <- rstatix::get_emmeans(res_em)\\n');
    }

    // NUEVO: Agrupar resultados en una lista si se activa la casilla
    if (getValue('a_save.active')) {
        echo('\\n# Combine results into a list\\n');
        echo('ancova_results <- list(ancova = res_ancova)\\n');
        if (emm) {
            echo('ancova_results$emmeans <- res_em_table\\n');
            if (emm_ph) {
                echo('ancova_results$emmeans_pairwise <- res_em\\n');
            }
        }
    }
  ")

  js_print_ancova <- "
    if (!is_preview) {
        echo('rk.header(\"Analysis of Covariance (ANCOVA)\", level = 2)\\n');
        echo('rk.results(as.data.frame(res_ancova))\\n');

        if (getValue('a_emmeans') === 'TRUE') {
            echo('rk.header(\"Estimated Marginal Means (Adjusted for Covariates)\", level = 3)\\n');
            echo('rk.results(as.data.frame(res_em_table))\\n');

            if (getValue('a_emmeans_posthoc') === 'TRUE') {
                echo('rk.header(\"Pairwise Comparisons (Bonferroni)\", level = 4)\\n');
                echo('rk.results(as.data.frame(res_em))\\n');
            }
        }

        // NUEVO: Mensaje de confirmación de guardado
        if (getValue('a_save.active')) {
            echo('rk.print(paste0(\"<i>All generated results saved to workspace as a list: </i><code>\", \"' + getValue('a_save') + '\", \"</code>\"))\\n');
        }
    }
  "

  comp_ancova <- rk.plugin.component("ANCOVA (Analysis of Covariance)", xml = list(dialog = a_dialog, logic = a_logic), js = list(require = c("rstatix", "dplyr"), calculate = js_calc_ancova, printout = js_print_ancova), hierarchy = h_psych, rkh = list(help = help_ancova))


  # =========================================================================================
  # COMPONENT 3: Outlier Diagnostics
  # Location: Analysis > Psychology / Social Science > Frequentist
  # =========================================================================================
  help_outliers <- rk.rkh.doc(
      title = rk.rkh.title("Identify Outliers"),
      summary = rk.rkh.summary("Quickly filters and identifies univariate outliers (and extreme outliers) per group using rstatix.")
  )

  o_vs <- rk.XML.varselector(id.name = "o_vs")
  o_df <- rk.XML.varslot("Data frame", source = "o_vs", classes = "data.frame", required = TRUE, id.name = "o_df")
  o_var <- rk.XML.varslot("Target Variable (Numeric)", source = "o_vs", required = TRUE, id.name = "o_var", classes = c("numeric", "integer"))
  o_group <- rk.XML.varslot("Grouping Variable (Optional)", source = "o_vs", id.name = "o_group")

  o_logic <- rk.XML.logic(rk.XML.connect(governor = o_df, get = "available", client = o_vs, set = "root"))

  o_extreme <- rk.XML.cbox("Show ONLY Extreme Outliers (values beyond 3x IQR)", value = "TRUE", chk = FALSE, id.name = "o_extreme")

  o_dialog <- rk.XML.dialog(label = "Identify Outliers", child = rk.XML.row(
      o_vs,
      rk.XML.col(
        rk.XML.frame(o_df, o_var, o_group, label = "Data Definition"),
        rk.XML.frame(o_extreme, label = "Filtering"),
        rk.XML.stretch()
      )
  ))

  js_calc_outliers <- paste0(js_helpers, "
    var df = getValue('o_df');
    var vr = getCol('o_var');
    var grp = getCol('o_group');
    var extreme = getValue('o_extreme') === 'TRUE';

    echo('require(rstatix)\\nrequire(dplyr)\\n\\n');

    if (grp !== '') {
        echo('res_out <- ' + df + ' %>% dplyr::group_by(' + grp + ') %>% rstatix::identify_outliers(' + vr + ')\\n');
    } else {
        echo('res_out <- ' + df + ' %>% rstatix::identify_outliers(' + vr + ')\\n');
    }

    if (extreme) {
        echo('res_out <- res_out %>% dplyr::filter(is.extreme == TRUE)\\n');
    }
  ")

  js_print_outliers <- "
    if (!is_preview) {
        echo('rk.header(\"Outliers Diagnostics\", level = 2)\\n');
        var ext_str = getValue('o_extreme') === 'TRUE' ? 'EXTREME Outliers Only (3x IQR)' : 'All Outliers (1.5x IQR)';
        echo('rk.print(paste0(\"<b>Criterion: </b>\", \"' + ext_str + '\"))\\n');

        echo('if (nrow(res_out) > 0) {\\n');
        echo('  rk.results(as.data.frame(res_out))\\n');
        echo('} else {\\n');
        echo('  rk.print(\"<i>No outliers found in the dataset under the selected criteria.</i>\")\\n');
        echo('}\\n');
    }
  "

  comp_outliers <- rk.plugin.component("Identify Outliers", xml = list(dialog = o_dialog, logic = o_logic), js = list(require = c("rstatix", "dplyr"), calculate = js_calc_outliers, printout = js_print_outliers), hierarchy = h_psych, rkh = list(help = help_outliers))


  # =========================================================================================
  # BUILD SKELETON
  # =========================================================================================
  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    # 1. Welch es el plugin principal (se inyecta directo)
    xml = list(dialog = w_dialog, logic = w_logic),
    js = list(require = c("rstatix", "dplyr"), calculate = js_calc_welch, printout = js_print_welch),
    rkh = list(help = help_welch),
    # 2. ANCOVA y Outliers son los secundarios
    components = list(comp_ancova, comp_outliers),
    # 3. Definimos el mapa apuntando al menú principal de Welch
    pluginmap = list(
        name = "Robust ANOVA (Welch & Games-Howell)",
        hierarchy = h_welch
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin package 'rk.rstatix' generated successfully.\n")
})
