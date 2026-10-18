// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(rstatix)\n");	echo("require(dplyr)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function extractColName(raw) {
        if (!raw) return '';
        var parts = raw.split(/[\$\[\]]/).filter(Boolean);
        return parts[parts.length - 1].replace(/["']/g, '');
    }
    function getCol(id) {
        return extractColName(getValue(id));
    }
  
    var df = getValue('a_df');
    var dv = getCol('a_dv');
    var between = getCol('a_between');
    var emm = getValue('a_emmeans') === 'TRUE';
    var emm_ph = getValue('a_emmeans_posthoc') === 'TRUE';

    // Parse multiple covariates
    var covar_raw = getValue('a_covar').split('\n').filter(Boolean);
    var covar = covar_raw.map(extractColName).join(' + ');

    echo('require(rstatix)\nrequire(dplyr)\n\n');

    echo('# 1. ANCOVA\n');
    echo('res_ancova <- ' + df + ' %>% rstatix::anova_test(' + dv + ' ~ ' + covar + ' + ' + between + ')\n');

    if (emm) {
        echo('\n# 2. Estimated Marginal Means\n');
        var covar_vec = 'c("' + covar_raw.map(extractColName).join('", "') + '")';
        echo('res_em <- ' + df + ' %>% rstatix::emmeans_test(' + dv + ' ~ ' + between + ', covariate = ' + covar_vec + ', p.adjust.method = "bonferroni")\n');
        echo('res_em_table <- rstatix::get_emmeans(res_em)\n');
    }

    // NUEVO: Agrupar resultados en una lista si se activa la casilla
    if (getValue('a_save.active')) {
        echo('\n# Combine results into a list\n');
        echo('ancova_results <- list(ancova = res_ancova)\n');
        if (emm) {
            echo('ancova_results$emmeans <- res_em_table\n');
            if (emm_ph) {
                echo('ancova_results$emmeans_pairwise <- res_em\n');
            }
        }
    }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("ANCOVA (Analysis of Covariance) results")).print();

    if (!is_preview) {
        echo('rk.header("Analysis of Covariance (ANCOVA)", level = 2)\n');
        echo('rk.results(as.data.frame(res_ancova))\n');

        if (getValue('a_emmeans') === 'TRUE') {
            echo('rk.header("Estimated Marginal Means (Adjusted for Covariates)", level = 3)\n');
            echo('rk.results(as.data.frame(res_em_table))\n');

            if (getValue('a_emmeans_posthoc') === 'TRUE') {
                echo('rk.header("Pairwise Comparisons (Bonferroni)", level = 4)\n');
                echo('rk.results(as.data.frame(res_em))\n');
            }
        }

        // NUEVO: Mensaje de confirmación de guardado
        if (getValue('a_save.active')) {
            echo('rk.print(paste0("<i>All generated results saved to workspace as a list: </i><code>", "' + getValue('a_save') + '", "</code>"))\n');
        }
    }
  
	//// save result object
	// read in saveobject variables
	var aSave = getValue("a_save");
	var aSaveActive = getValue("a_save.active");
	var aSaveParent = getValue("a_save.parent");
	// assign object to chosen environment
	if(aSaveActive) {
		echo(".GlobalEnv$" + aSave + " <- ancova_results\n");
	}

}

