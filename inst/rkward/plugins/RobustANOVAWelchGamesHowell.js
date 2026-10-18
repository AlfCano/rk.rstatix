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
  
    var df = getValue('w_df');
    var dv = getCol('w_dv');
    var between = getCol('w_between');
    var effsize = getValue('w_effsize') === 'TRUE';
    var gh = getValue('w_gh') === 'TRUE';

    echo('require(rstatix)\nrequire(dplyr)\n\n');

    echo('# 1. Welch ANOVA\n');
    echo('res_welch <- ' + df + ' %>% rstatix::welch_anova_test(' + dv + ' ~ ' + between + ')\n');

    if (effsize) {
        echo('\n# Effect Size (Eta Squared from standard ANOVA)\n');
        echo('model_aov <- aov(' + dv + ' ~ ' + between + ', data = ' + df + ')\n');
        echo('res_eff <- rstatix::eta_squared(model_aov)\n');
    }

    if (gh) {
        echo('\n# 2. Games-Howell Post-hoc Test\n');
        echo('res_gh <- ' + df + ' %>% rstatix::games_howell_test(' + dv + ' ~ ' + between + ')\n');
    }

    // NUEVO: Agrupar resultados en una lista si el usuario activó la casilla de guardar
    if (getValue('w_save.active')) {
        echo('\n# Combine results into a list\n');
        echo('welch_results <- list(welch_anova = res_welch)\n');

        if (effsize) { echo('welch_results$effect_size <- res_eff\n'); }
        if (gh) { echo('welch_results$games_howell <- res_gh\n'); }
    }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Robust ANOVA (Welch & Games-Howell) results")).print();

    if (!is_preview) {
        echo('rk.header("Robust ANOVA (Welch)", level = 2)\n');
        echo('rk.print("<b>Test:</b> Welch One-Way ANOVA (Unequal variances assumed)")\n');
        echo('rk.results(as.data.frame(res_welch))\n');

        if (getValue('w_effsize') === 'TRUE') {
            echo('rk.header("Effect Size (Eta Squared)", level = 3)\n');
            echo('rk.results(as.data.frame(res_eff))\n');
        }

        if (getValue('w_gh') === 'TRUE') {
            echo('rk.header("Games-Howell Post-hoc Test", level = 3)\n');
            echo('rk.results(as.data.frame(res_gh))\n');
        }

        // El mensaje de guardado ahora avisa que es una lista
        if (getValue('w_save.active')) {
            echo('rk.print(paste0("<i>All generated results saved to workspace as a list: </i><code>", "' + getValue('w_save') + '", "</code>"))\n');
        }
    }
  
	//// save result object
	// read in saveobject variables
	var wSave = getValue("w_save");
	var wSaveActive = getValue("w_save.active");
	var wSaveParent = getValue("w_save.parent");
	// assign object to chosen environment
	if(wSaveActive) {
		echo(".GlobalEnv$" + wSave + " <- welch_results\n");
	}

}

