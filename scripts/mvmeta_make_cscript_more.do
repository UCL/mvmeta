/*
mvmeta_make_cscript_more.do
IW 27jul2023
*/

foreach model in "logit hisbpl" "regress sbpl" {
	* load data
	use "N:\Home\meta\Interactions\deft_subgps\metadeft\problem jul 23\David hypothetical data (2)", clear
	keep if inlist(trial,"ANBP","COOP")
	rename treat trt
	egen agegp = cut(age), at(30 45 70 100)
	tabstat age, by(agegp) s(n min max)
	tab trial agegp
	gen hisbpl = sbpl>160 if !mi(sbpl)
	xi i.trt*i.agegp, noomit

	* run 3 mvmeta_make commands that should give the same results
	di as input _n(5) "`model': 1. parameterised as subgroup-specific treatment effect, ppfix not needed"
	mvmeta_make, by(trial) saving(z1,replace) usevars(_ItrtXage_1*) ppfix(none): `model' _Iagegp* _ItrtXage_1* sbpi

	di as input _n(5) "`model': 2. parameterised as subgroup-specific treatment effect, with ppfix anyway"
	mvmeta_make, by(trial) saving(z2,replace) usevars(_ItrtXage_1*) ppfix(check): `model' _Iagegp* _ItrtXage_1* sbpi

	di as input _n(5) "`model': 3. parameterised as main treatment effect and 2 interactions"
	mvmeta_make, by(trial) saving(z3,replace) usevars(_Itrt_1 _ItrtXage_1_45 _ItrtXage_1_70) ppfix(check): `model' _Itrt_1 _Iagegp_45 _Iagegp_70 _ItrtXage_1_45 _ItrtXage_1_70 sbpi

	* test results for (i) unexpected missing values and (ii) discrepant results
	use z1, clear // reference
	* no augmentation - missing values are genuine
	mvmeta y S, fixed
	mat V1=e(V)

	use z2, clear
	egen nmiss = rowmiss(y* S*)
	assert nmiss==0
	mvmeta y S, fixed
	di as text _n "Relative error is " as result mreldif(V1,e(V))
	assert mreldif(V1,e(V))<1E-5

	use z3, clear
	egen nmiss = rowmiss(y* S*)
	assert nmiss==0
	mvmeta y S, fixed
	nlcom (_ItrtXage_1_30: _b[y_Itrt_1]) (_ItrtXage_1_45: _b[y_Itrt_1] + _b[y_ItrtXage_1_45]) ///
		(_ItrtXage_1_70: _b[y_Itrt_1] + _b[y_ItrtXage_1_70]), post
	di as text _n "Relative error is " as result mreldif(V1,e(V))
	assert mreldif(V1,e(V))<1E-5
}

forvalues i=1/3 {
	erase z`i'.dta
}
