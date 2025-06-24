// mvmeta eyeball script: have to check output (results/graphs) by eye
// IW 7/4/2022
* updated 24/6/2025

prog drop _all
pause on

// CHECK GRAPHS BY EYE
* check bubble
use $mvmetadir/scripts\MYCN.dta, clear
mvmeta y S, var(y4 y3 y2 y1) wscorr(.3) fixed bubble(var(y2 y4) missval(-2) name(b1,replace))
mvmeta y S, var(y1 y2 y3 y4) wscorr(.3) fixed bubble(var(y2 y4) missval(-2) name(b2,replace))
pause Check graphs b1 and b2 are identical
mvmeta y S, var(y4 y3 y2 y1) wscorr(.3) fixed bubble(var(y4 y2) missval(-2) name(b3,replace))
pause Check graph b3 is transpose of b1 & b2

mvmeta y S, var(y4 y3 y2 y1) wscorr(.3) fixed bubble(var(y4 y2) missval(-2) name(b4,replace) pct(40(5)50))
pause Check graph b4 is like b3 but with triple-ring instead of single-ring


// CHECK RESULTS BY EYE

* check PIs are unaffected by ordering
mvmeta y S, var(y4 y3 y2 y1) wscorr(.3) mm pi
mvmeta y S, var(y1 y2 y3 y4) wscorr(.3) mm pi
pause Check PIs are unaffected by ordering

* check that weights correctly handle different ways to express study identifiers
* Check 1: studies are 1-6 but 1 is omitted
use $mvmetadir/package/p53, clear
gen stchar="Study " + strofreal(study)
sencode stchar, gen(stnum)
replace study = 100+_n
l
foreach id in none study stchar stnum {
	if "`id'"=="none" local idopt
	else local idopt id(`id')
	dicmd mvmeta lnHR VlnHR in 2/6, wscorr(0.7) `idopt' wt longparm
	pause Check studies are 2-6 not 1-5
}
