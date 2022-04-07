/*
MAIN TEST SCRIPT FOR MVMETA
07apr2022 avoid mreldif(b,e(b)) & change version to allow Stata v12; include runhelpfile.ado
01mar2022 added check of MVMETA_obserror
08feb2022 added checks of warning() 
20jan2022 noposdef dropped from estimateoptstog
	because noposdef now suppresses fe, so disables randfix and testsigma
21dec2021 added check that help file examples run
15nov2021 added test of new bscov(exch); constraints; taulog option
11nov2021 added test of penalty() option
14oct2021 added test of new pi; pbest always with seed; MYCN data
8apr2021 added log in testlogs folder
v3.0.1 11may2015: new syntax for wt(), bubble()
v2.13:
	package and scripts in separate directories
	scripts directory includes all data files
v2.12 4-5mar2015: 
	  drop borrow 
	  include wt()
v2.5.4: more pbest options 
v2.4: details is no longer an option
      most checks include missing outcome
      added commonparm
v2.3: added pbest(,predict) and bscov(corr P)
v2.1: added testsigma borrow qscalar randfix(y*)
v1.9: options renamed
v1.7: changed showchol to showall

Note that cscript sets linesize to 79
*/

local mvmetadir c:\ado\ian\mvmeta\
cd "`mvmetadir'scripts"
adopath ++ `mvmetadir'package
cap log close
set linesize 79
log using "`mvmetadir'testlogs\mvmeta_cscript.log", replace

version 12
if c(version)>=13 cls
cscript mvmeta
prog drop _all
set more off
set trace off
pause off // on to check output in detail, off for fast run through
global F5 exit;

prog def dicmd
* works for version (6?) 7 or 8
noi di as input _newline(2) `"`0'"'
`0'
end

which mvmeta

use telomerase2, clear
gen id=_n
gen one=1
gen study10 = id==10
gen studychar = "Study "+string(study)
encode studychar, gen(studynum)
label def study10 0 "Studies 1-9" 1 "Study 10"
label val study10 study10
mat P2=(1,0.5\0.5,1)

// CHECK HANDLING OF MISSING COVARIATE
mvmeta y S study in 2/l
pause
local ll = e(ll)
gen study2 = study in 2/l
mvmeta y S study2
pause 
assert abs(e(ll)-`ll')<1E-12
mvmeta y S, eq(y1:study2, y2:study2)
pause 
assert abs(e(ll)-`ll')<1E-12

// and missing outcome
gen z1=y1 in 2/l
gen z2=y2 in 2/l
mvmeta z S study
pause 
assert abs(e(ll)-`ll')<1E-12
replace z2=y2

// OPTIONS
local pbestopt pbest(min in 2/5, all gen(rank) zero predict saving(z) replace mcse id(study) seed(641))
local wtsd wt(sd details format(%5.3f) keepmat(SD) unscaled wide)
local wtrv wt(rv details format(%5.3f) keepmat(RV))
local wtdpc wt(dpc details format(%5.3f) keepmat(DPC))
local bubble bubble(name(bubble,replace) yline(0) xline(0) ///
	col(blue green black =) lwidth(.2 = = .6) lpatt(solid = dash solid))
local forest forest(title(Forest plot) name(forest,replace) ///
	xli(0) subtitle(,size(large)) ///
	xlab(,labsize(large)) ylab(,labsize(large)) ///
	xrescale uv(line predict) mv(line predict) weights(align(c)) ytick(none))
local pi pi(format(%9.5f) level(80))

local replayoptssep /// replay options to be run separately
	showall "`forest'" eform eform(EFORM) nouncertainv print(bscov) ///
    print(bscorr) level(90) dof(n-2) i2 "pbest(min, seed(641))" "`pbestopt'" ///
	nowt "`wtsd'" "`wtrv'" "`wtdpc'" testsigma qscalar randfix randfix(z*) ///
	"`bubble'" pi "`pi'"

local replayoptstog /// replay options to be run together
	showall eform(EFORM) nouncertainv print(bscov) level(90) ///
    dof(n-2) i2 `pbestopt' `wtsd' testsigma qscalar randfix(z*) `bubble' `forest' 

local estimateoptssep /// estimate options to be run separately
	fixed mm mm1 mm2 reml ml vars(z2) start(I(2)) showstart ///
    longparm wscorr(0) wscorr(riley) ///
    "mm notrunc" missest(1) missvar(1E5) maxse(3) noconstant psdcrit(1E-3) noposdef ///
    "bscov(uns)" "bscov(prop I(2))" "bscov(equal I(2))" "bscov(corr P2)" ///
	"bscov(exch 0.5)" "bscov(exch)" ///
	quick commonparm id(study) id(studychar) id(studynum)

local estimateoptstog /// estimate options to be run together
	showstart longparm ///
    missest(1) missvar(1E5) maxse(3) noconstant psdcrit(1E-3) id(studychar)

// CHECK REPLAY OPTIONS ONE BY ONE
foreach replayopt in `replayoptssep' {
    dicmd mvmeta z S study, `replayopt'
pause 
	cap drop rank*
}

// and ID options
dicmd mvmeta z S study, `wtsd' id(studychar) pbest(min, seed(641))
pause 

// AND ALL TOGETHER
dicmd mvmeta z S study, `replayoptstog' pi
pause 
drop rank* 

// CHECK ESTIMATE OPTIONS ONE BY ONE
foreach estimateopt in `estimateoptssep' {
    dicmd mvmeta z S study, `estimateopt'
pause 
}

// CHECK ALL OPTIONS TOGETHER FOR BSCOV(UNS) WSCORR(0)
dicmd mvmeta z S study one, bscov(uns) wscorr(0) ///
	`estimateoptstog' `replayoptstog' pi(xvar(one))
pause 
drop rank*

// ... AND REPLAY
dicmd mvmeta, `replayoptstog' pi(xvar(one))
pause 
drop rank* 

// CHECK ALL OPTIONS TOGETHER FOR BSCOV(EXCH) CORR(RILEY)
dicmd mvmeta z S study one, bscov(exch 0.5) wscorr(riley) ///
	`estimateoptstog' `replayoptstog' pi(xvar(one))
pause 
drop rank* 

// ... AND REPLAY
dicmd mvmeta, `replayoptstog' pi(xvar(one))
pause 
drop rank* 

// CHECK ALL OPTIONS TOGETHER FOR BSCOV(CORR) 
dicmd mvmeta z S study one, bscov(corr I(2)) ///
	`estimateoptstog' `replayoptstog' pi(xvar(one))
pause 
drop rank* 
	
// ... AND REPLAY
dicmd mvmeta, `replayoptstog' pi(xvar(one))
pause 
drop rank* 

// CHECK ALL OPTIONS TOGETHER FOR BSCOV(EXCH) 
dicmd mvmeta z S study one, bscov(exch) ///
	`estimateoptstog' `replayoptstog' pi(xvar(one))
pause 
drop rank* 
	
// ... AND REPLAY
dicmd mvmeta, `replayoptstog' pi(xvar(one))
pause 
drop rank* 

// CHECK BUBBLE AND FOREST WITH SUMMARIES
dicmd mvmeta y S, `bubble'
pause 
dicmd mvmeta y S, `forest'
pause 

// CHECK NUMERICAL RESULTS FOR corr(riley)
drop S12
dicmd mvmeta y S, wscorr(riley)
pause 
assert abs(_b[y1] - 1.155125567887) < 1E-6

// SPARSE DATA 
use MYCN, clear
drop y4
drop if !mi(y2) & !mi(y3)
gen S12=0.5*sqrt(S11*S22)
gen S13=0.5*sqrt(S11*S33)
mvmeta y S, var(y?) bscov(exch 0.5)
mvmeta y S, var(y?) bscov(exch 0.5) warn(text)
mvmeta y S, var(y?) bscov(exch 0.5) warn(off)

// CHECK PENALTY OPTION REDUCES BS CORRELATION
drop S12 S13
forvalues i=0/2 {
	if `i'==0 local penalty
	if `i'==1 local penalty penalty(0)
	if `i'==2 local penalty penalty(0.1)
	dicmd mvmeta y S, var(y1 y2) wscorr(riley) `penalty'
	mat Sigma = e(Sigma)
	local rho`i' = Sigma[1,2]/sqrt(Sigma[1,1]*Sigma[2,2])
}
assert reldif(`rho0', `rho1') < 1E-6
assert abs(`rho2') < abs(`rho1')

* also check that penalty ensures convergence
use MYCN, clear
drop year

mvmeta y S, wscorr(riley) iter(30)
assert e(converged) == 0
mvmeta y S, wscorr(riley) iter(30) penalty(1)
assert e(converged) == 1

// TEST NEW BSCOV(EXCH)
mvmeta y S, wscorr(riley) iter(30) bscov(exch)
local rhoest = [rho]_b[_cons]
mat best6 = e(b)
mat best5 = best6[1,1..5]
local se1 = _se[y1]

* compare with bscov(exch #) for the estimated #
mvmeta y S, wscorr(riley) iter(30) bscov(exch `rhoest')
mat eb = e(b)
assert mreldif(best5,eb) < 1E-7 // point estimates should be the same
assert _se[y1] < `se1' // SEs should be smaller

* invariance to starting values
mvmeta y S, wscorr(riley) iter(30) bscov(exch) start(2 0)
mat eb = e(b)
assert mreldif(best6,eb) < 2E-7 // point estimates should be the same
di reldif(_se[y1], `se1') 
assert reldif(_se[y1], `se1') < 1E-7 // SEs should be the same

// TEST TAULOG
foreach bscov in "bscov(prop I(4))" "bscov(exch)" {
	foreach taulog in notaulog taulog {
		dicmd mvmeta y S, wscorr(0.3) `bscov' `taulog'
		mat Sigma`taulog' = e(Sigma)	
	}
	assert mreldif(Sigmanotaulog, Sigmataulog) < 1E-6
		// Sigmas should be the same: relaxed after Ella got 3E-6
}

// TEST CONSTRAINTS
use telomerase2, clear
for var y2 S12 S22: replace X=. in 1

* 1. Standard analysis
mvmeta y S, bscov(uns) taulog nounc 
* store useful results
mat Sigma=e(Sigma)
foreach n in 11 12 22 {
	local c`n'=[chol`n']_cons
	constraint `n' [chol`n']_cons = `c`n''
}
* store nounc SEs (not stored automatically because nounc is a Replay option)
* code from Replay
tempname V V2 
mat `V' = e(V)
mat `V2' = invsym(`V')
mat `V2' = `V2'[1..`e(nparms_mean)',1..`e(nparms_mean)']
mat `V2' = invsym(`V2')
local se1 =  sqrt(`V2'[1,1])

* 2. Fix Sigma by bscov(eq)
mvmeta y S, bscov(eq Sigma) nounc 
di reldif(_se[y1],`se1') 
assert reldif(_se[y1],`se1') < 1E-7

* 3. Fix Sigma by constraints
mvmeta y S, bscov(uns) taulog constraint(11 12 22) nounc 
di reldif(_se[y1],`se1') 
assert reldif(_se[y1],`se1') < 1E-7


// CHECK THE STATA HELP FILES
* runhelpfile is in scripts
cap runhelpfile // just to load it
cd "`mvmetadir'package"
runhelpfile using mvmeta.sthlp, skip(net)
runhelpfile using mvmetademo_run.sthlp, skip(net)
cd "`mvmetadir'scripts"


// CHECK WARNING OPTIONS WORK
* generating warnings from
*   -showchol-, an old option which triggers a warning
*   a superfluous y variable
*   superfluous wscorrforce and notrunc options
use telomerase2, clear
gen y=1
foreach warning in error text off {
	dicmd mvmeta y S, showchol warning(`warning') wscorrforce notrunc
}

* using a data set with non-positive-definite S's 
use fracpoly_results, clear
* commands that fail: check the output
foreach warning in error text off {
	dicmd cap noi mvmeta b V, warning(`warning') 
	di as input "Error code was " _rc _n
}
* commands that succeed using noposdef 
foreach warning in error text off {
	dicmd mvmeta b V, noposdef warning(`warning')
}

// CHECK OBSERROR
use telomerase2, clear
replace S11=. in 3
cap mvmeta y S
assert _rc==459
assert $MVMETA_obserror==3

// TIDY UP
clear
erase "`mvmetadir'scripts/z.dta

di as result _n "****************************************" ///
	_n "*** MVMETA HAS PASSED ALL ITS TESTS ***" ///
	_n "****************************************"

log close
