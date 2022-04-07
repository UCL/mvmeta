/*
mvmeta_make_data.do
Create test datasets
IW 28/3/2022
*/

* SIMPLE DATA
set seed 5718576
clear
set obs 3
gen study = _n
expand 100
sort study
by study: gen id = _n
gen x = rnormal()
gen y = study+x+5*rnormal()
gen yg = (y>0) + (y>4)
save mvmeta_make_testdata_reg, replace

* LONGITUDINAL DATA
use mvmeta_make_testdata_reg, clear
rename y y1
gen y2 = study+x+5*rnormal()
reshape long y, i(study id) j(time)
save mvmeta_make_testdata_mixed, replace

* MULTIPLY IMPUTED DATA
* DIFFERENT OBS BY STUDY
* NB GET DISASTER IF M ALSO VARIES
* NEED TO USE MI APPEND NOT APPEND
forvalues study=1/3 {
	local nobs = 50*`study'
	clear
	set obs `nobs'
	gen study = `study'
	gen id = _n
	gen x = rnormal()
	gen y = study+x+5*rnormal()
	replace x = . if id<=10
	mi set flong
	mi register imputed x
	mi impute reg x y, add(3)
	mi estimate, post: reg y x
	est store study`study'
	if study>1 mi append using mvmeta_make_testdata_mi
	save mvmeta_make_testdata_mi, replace
}

* 	SURVIVAL DATA AND NON-STANDARD STUDY NUMBERING
use mvmeta_make_testdata_reg, clear
replace study=study+2
drop y yg
gen z = runiform()<.5
gen t = -log(runiform())/exp(-3+0.1*study+x-0.1*z)
drop if study==3 & id>90
gen d = t<5
replace t = min(t,5)
tab study d
stset t, failure(d)
save mvmeta_make_testdata_surv, replace


// Create test data for package

use mvmeta_make_testdata_mixed, clear
drop yg
rename x z
label data "Simulated data to illustrate mvmeta_make with mixed"
save ../package/testdata_mixed, replace

use mvmeta_make_testdata_mi, clear
label data "Simulated data to illustrate mvmeta_make with mi estimate"
save ../package/testdata_mi, replace
