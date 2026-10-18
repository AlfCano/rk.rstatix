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
  
    var df = getValue('o_df');
    var vr = getCol('o_var');
    var grp = getCol('o_group');
    var extreme = getValue('o_extreme') === 'TRUE';

    echo('require(rstatix)\nrequire(dplyr)\n\n');

    if (grp !== '') {
        echo('res_out <- ' + df + ' %>% dplyr::group_by(' + grp + ') %>% rstatix::identify_outliers(' + vr + ')\n');
    } else {
        echo('res_out <- ' + df + ' %>% rstatix::identify_outliers(' + vr + ')\n');
    }

    if (extreme) {
        echo('res_out <- res_out %>% dplyr::filter(is.extreme == TRUE)\n');
    }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Identify Outliers results")).print();

    if (!is_preview) {
        echo('rk.header("Outliers Diagnostics", level = 2)\n');
        var ext_str = getValue('o_extreme') === 'TRUE' ? 'EXTREME Outliers Only (3x IQR)' : 'All Outliers (1.5x IQR)';
        echo('rk.print(paste0("<b>Criterion: </b>", "' + ext_str + '"))\n');

        echo('if (nrow(res_out) > 0) {\n');
        echo('  rk.results(as.data.frame(res_out))\n');
        echo('} else {\n');
        echo('  rk.print("<i>No outliers found in the dataset under the selected criteria.</i>")\n');
        echo('}\n');
    }
  

}

