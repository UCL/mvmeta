/*
Check that weights correctly handle different ways to express study identifiers
Need to check the output visually
Written <2018, updated 1mar2022
Was called anothercheck[2], now called checkstudyids.do
*/

pda
pause on
set more on

// Check 1: studies are 1-6 but 1 is omitted
use ../package/p53, clear
gen stchar="Study " + strofreal(study)
sencode stchar, gen(stnum)
replace study = 100+_n
l
foreach id in none study stchar stnum {
	if "`id'"=="none" local idopt
	else local idopt id(`id')
	dicmd mvmeta lnHR VlnHR in 2/6, wscorr(0.7) `idopt' wt longparm
	pause
}



// Check 2: studies are 1-10 but 1,2 are omitted
use ../scripts/telomerase2, clear
gen stchar="Study " + strofreal(study)
sencode stchar, gen(stnum)
replace study = 100+_n
foreach id in none study stchar stnum {
	if "`id'"=="none" local idopt
	else local idopt id(`id')
	dicmd mvmeta y S in 3/10, `idopt' wt longparm
	pause
}

