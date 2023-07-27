/*
mvmeta_make_cscript.do: MAIN TEST SCRIPT FOR MVMETA_MAKE
27jul2023: added test of filepath in saving()
21apr2022: added checks of ereturned results
7apr2022: renamed mvmeta_make_cscript and automated log
5apr2022: add tests of usevars, usecoefs, esave
	add test with survival data, including counts() and Stephen K's countby()
	standardise line length
28mar2022: major update to test prefix syntax
IW 2nov2021
Still to do: test perfect prediction
*/

// PRELIMINARIES
local mvmetadir c:\ian\git\mvmeta\
cd "`mvmetadir'scripts"
adopath ++ `mvmetadir'package
cap log close
log using "`mvmetadir'testlogs\mvmeta_make_cscript.log", replace

version 12
if c(stata_version)>=13 cls
cscript adofile mvmeta_make
prog drop _all
set more off
set trace off


// VIEW VERSION NUMBERS
di c(stata_version)
which mvmeta_make
which mvmeta


// SIMPLE DATA: COMPARE CLASSIC AND PREFIX SYNTAXES
use mvmeta_make_testdata_reg, clear

mvmeta_make reg y x if id>2 [aw=x^2], by(study) saving(z1) replace mse1 

mvmeta_make, by(study) saving(z2) replace: reg y x if id>2 [aw=x^2], mse1
* check ereturned results without clear
assert e(sample) == id>2
assert mi(e(N))
assert e(cmd)=="mvmeta_make"

mvmeta_make reg y x if id>2 [aw=x^2], by(study) clear mse1 nodetails
* check ereturned results with clear
assert e(sample) == 0
assert mi(e(N))
assert e(cmd)=="mvmeta_make"

cf _all using z1
cf _all using z2
mvmeta y S


// TEST USEVARS ETC
use mvmeta_make_testdata_reg, clear
mvmeta_make reg y x if id>2 [aw=x^2], by(study) clear replace mse1 usevars(x)
cf _all using z1

use mvmeta_make_testdata_reg, clear
mvmeta_make reg y x if id>2 [aw=x^2], by(study) clear replace mse1 usecoefs(x)
cf _all using z1

use mvmeta_make_testdata_reg, clear
mvmeta_make reg y x if id>2 [aw=x^2], by(study) clear replace mse1 usecons
drop y_cons Sx_cons S_cons
cf _all using z1

use mvmeta_make_testdata_reg, clear
count if id>2
local N = r(N)
mvmeta_make reg y x if id>2 [aw=x^2], by(study) clear replace mse1 esave(N ll)
sum _e_N, meanonly
assert r(sum)==`N'
drop _e_N _e_ll
cf _all using z1


// TEST WITH MULTIPLE EQUATIONS
use mvmeta_make_testdata_reg, clear
mvmeta_make mlogit yg x if id>2, by(study) saving(z3) replace baseoutcome(0)
mvmeta_make mlogit yg x if id>2, by(study) saving(z4) replace baseoutcome(0) usecoefs([1]x [2]x)
mvmeta_make mlogit yg x if id>2, by(study) saving(z5) replace baseoutcome(0) usecoefs([1]x [2]x [2]_cons)

use z4, clear
cf _all using z3

use z5, clear
drop y2_cons S1x2_cons S2x2_cons S2_cons2_cons
cf _all using z3


// MI DATA: CHECK COMPLEX PREFIX SYNTAX & AGREEMENT WITH SIMPLE ANALYSIS

use mvmeta_make_testdata_mi, clear

mi estimate, post: reg y x if id>2 & study==1, robust coefl
local varx=_se[x]^2

cap noi mvmeta_make, by(study) clear cons: mi estimate, post: reg y x, robust coefl
* error: option cons not allowed

mvmeta_make, by(study) clear usecons details: mi estimate, post: reg y x if id>2, robust coefl
assert reldif(Sxx[1],`varx') < 1E-7


// MIXED MODEL: CHECK COMPLEX PREFIX SYNTAX
* mixed was new in Stata 13
if c(stata_version)>=13 {
	use mvmeta_make_testdata_mixed, clear
	gen x1=x*(time==1)
	gen x2=x*(time==2)
	mixed y time x1 x2 if id>2 & study==1 || id:, reml
	local varx1=_se[x1]^2
	mvmeta_make, by(study) clear: mixed y time x1 x2 if id>2 || id:, reml
	assert reldif(Sx1x1[1],`varx1') < 1E-7
}


// TWO BYVARS
use mvmeta_make_testdata_mixed, clear
reg y x if id>2 & study==1 & time==1, mse1
local varx=_se[x]^2
mvmeta_make, by(study time) clear saving(c:\temp\z) replace: reg y x if id>2, mse1
assert reldif(Sxx[1],`varx') < 1E-7


// SURVIVAL DATA
use mvmeta_make_testdata_surv, clear
stcox z x if id>2 & study==3
local se1 = _se[x]
count if id>2 & study==3
local n = r(N)
count if id>2 & study==3 & _d
local d = r(N)
count if id>2 & z==0 & study==3
local n0 = r(N)
count if id>2 & z==0 & study==3 & _d
local d0 = r(N)
sum _t if id>2 & z==0 & study==3, meanonly
local py0 = r(sum)
mvmeta_make stcox z x if id>2, by(study) saving(z1) replace 
mvmeta_make, by(study) saving(z2) replace : stcox z x if id>2
mvmeta_make, by(study) saving(z3) replace countby(z): stcox z x if id>2
mvmeta_make, by(study) saving(z4) replace counts(r s f): stcox z x if id>2

use z3, clear
* compare with direct calculations
assert ns_z_0==`n0' if study==3
assert nf_z_0==`d0' if study==3
assert reldif(pt_z_0,`py0')<1E-7 if study==3
assert reldif(Sxx, `se1'^2)<1E-7 if study==3
* compare with other mvmeta_make commands
drop ns_z_0 nf_z_0 pt_z_0 ns_z_1 nf_z_1 pt_z_1
cf _all using z1
cf _all using z2

use z4, clear
* compare with direct calculations
assert records==`n' if study==3
assert subjects==`n' if study==3
assert failures==`d' if study==3
* compare with other mvmeta_make commands
drop records subjects failures
cf _all using z1


// WEB DATA REGARDING GENDER AS A STUDY: TEST STUDY NUMERIC/LABELLED/STRING
webuse mheart1s20, clear
* get truth
mi estimate, post: logit attack smokes age if female==1
local bage = _b[age]
* study as numeric
mvmeta_make, by(female) saving(z1) replace: mi estimate, post: logit attack smokes age
* study as labelled numeric
label def female 0 "M" 1 "F"
label val female female
mvmeta_make, by(female) saving(z2) replace: mi estimate, post: logit attack smokes age
* study as string
decode female, gen(femalechar)
drop female
mvmeta_make, by(female) saving(z3) replace: mi estimate, post: logit attack smokes age
* check results
use z1, clear
assert reldif(yage,`bage')<1E-7 if female==1
cf _all using z2

use z2, clear
assert reldif(yage,`bage')<1E-7 if female==1

use z3, clear
assert reldif(yage,`bage')<1E-7 if female=="F"


// TIDY UP
forvalues i=1/5 {
	erase z`i'.dta
}
erase c:\temp\z.dta


// REPORT SUCCESS
di as result _n "********************************************" ///
	_n "*** MVMETA_MAKE HAS PASSED ALL ITS TESTS ***" ///
	_n "********************************************"


log close
