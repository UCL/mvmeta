/* 
Run all tests for mvmeta and mvmeta_make
This program takes care of finding the right folders and filing the results in testlogs
Note there are *also* tests requiring the tester's attention
IW 24/6/2025
*/


// USER-SPECIFIC SETTING
global mvmetadir c:\ian\git\mvmeta


// PRELIMINARIES
cd "$mvmetadir/scripts"
adopath ++ $mvmetadir/package
cap log close
set linesize 79
prog drop _all

prog def dicmd
noi di as input _newline(2) `"`0'"'
`0'
end


// TESTS REQUIRING TESTER'S ATTENTION
// do mvmeta_eyeball_script


// AUTOMATED TESTS
foreach script in mvmeta_bscov_tests mvmeta_cscript mvmeta_make_cscript mvmeta_make_cscript_more  {

	log using "$mvmetadir/testlogs/`script'.log", replace

	version 12
	if c(stata_version)>=13 cls
	prog drop _all
	set more off
	set trace off
	pause off // on to check output in detail, off for fast run through
	global F5 exit;

	// VERSION NUMBERS
	di "c(stata_version) = " c(stata_version)
	di "c(version) = " c(version)
	which mvmeta
	which mvmeta_make

	cap noi do `script'
	
	if _rc {
		di as error "mvmeta failed in `script'.do"
		exit _rc
	}
	else {
		di as result "mvmeta passed in `script'.do"
	}
	log close
	
}

. di as result _n "********************************************************" ///
         _n "*** MVMETA AND MVMETA_MAKE HAVE PASSED ALL THE TESTS ***" ///
         _n "********************************************************"