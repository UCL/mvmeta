/*
graph for end of tutorial 18jul2021
minor updates 13oct2021
*/
use fscstage1, clear
mvmeta b V
gen group=.
gen b=.
gen se=.
forvalues i=1/5 {
	replace group=`i' in `i'
	if `i'==1 {
		replace b=0 in `i'
		replace se=0 in `i'
	}
	else {
		replace b=_b[ b_Ifg_`i'] in `i'
		replace se=_se[ b_Ifg_`i'] in `i'
	}
}
l group b se in 1/5
label var group "Fifth of fibrinogen"
cigraph8 b se group, ytitle(Hazard ratio for CHD (95% CI)) ///
	title("Fibrinogen Studies Collaboration:" "Pooled shape of fibrinogen-CHD association") ///
	eform s(S) saving(../package/fsc2cigraph.gph, replace) yscale(log)
