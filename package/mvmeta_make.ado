/********************************************************************* 
*! version 4.1 # Ian White # 27jul2023
	mvmeta_make now posts doubles. 
		This makes it possible to reduce augwt() without introducing error. 
		Different methods for estimating subgroup-specific treatment effects 
		now agree very well for augwt<=0.001, which they didn't before.
		Default reduced from augwt(0.01) to augwt(0.0001).
	augmentation now allowed with regress
	bugs fixed:
		error when saving() includes a filepath (used bind option on gettoken)
		model-omitted coefficients were retained in b but dropped from V (matdropo rewritten)
	output improved
		some missing output corrected
		suppress unwanted output with labelled by() var
version 4.0.3 # Ian White # 12jul2022
	multiple commas warning only printed for classic syntax
version 4.0.2 # Ian White # 21apr2022
	last regression doesn't contaminate ereturn-ed values
version 4.0 # Ian White # 07apr2022
	version number changed to match mvmeta
	new release to UCL, github and SSC
version 0.23.1  Ian White   7apr2022
	reordered options to match help file
version 0.23  Ian White   5apr2022
	add option countby: 
		written by S Kaptoge (Apr2009, Aug2016) to allow extraction of
		study-specific counts of events, participants, 	and person-time of follow up 
		by a variable specified in added option countby(varname)
version 0.22.2  Ian White   5apr2022
	extended usecoefs to work without eqname (also corrected help)
version 0.22.1  Ian White   4apr2022
	added dicmd subroutine
version 0.22  Ian White   28mar2022
	major edit to enable prefix syntax
	small changes to output 
	debug option enhanced
20jan2022: added but commented out possible change to pos def checking
version 0.21.1  Ian White   2nov2021
	quietly suppresses all output
version 0.21  Ian White   22jun2015
    by(varname) changed to by(varlist) 
    multiple equations rewritten
        bug fix - some covariances were omitted
        new parsing from e(b)
        new useeqs() 
		mlogit no longer requires baseoutcome()
	new clear option
	updated to v11 (makes -mixed- work better)
	NB to set up post file I have chosen the expensive option of fitting 
		the full model in the whole data set:
	- using covariates because
		(a) stcox returns no e(b) without covariates
		(b) mixed needs to be correctly parsed
	- using full data set because covariates might have pp in 1st study
		but user can specify a subset using learnif() 
	improved augmentation - uses all outcome levels in all subsets (not in the specific subset)
	new options: infix, longnames
version 0.20     30may2014
    esave(junk) returns missing _e_junk instead of failing (Phil Perry's request from 2011)
    preserve before augment to avoid changing data set if crash while augmented
    robust and cluster(varname) now disable augmentation
        - I tried changing iweight to pweight, but it gives bad (non-large) variances
    multiple-equation commands supported
        - command is run without covariates in first study before loop 
            in order to identify equation names and set up post file
        - mlogit requires baseoutcome()  
        - warning: I've found an example where mlogit does strange things after augmentation
version 0.19     20apr2011 - Stephen Kaptoge's edits to esave()
version 0.18     18mar2011  ON WEBSITE
    removes unwanted output with hard option
version 0.17     22dec2009 - new counts() option
version 0.16     22dec2009
    corrected bug that gave wrong _e_N_sub
version 0.15     21dec2009
    corrected bug that caused augmentation to fail for clogit when matched sets weren't numbered 1, 2, 3, ...
version 0.14      5oct2009
    fixed bug causing crash with too many stratifying levels
    augmentation for clogit puts augmented values into new groups - this works
version 0.13     25sep2009
    augmentation for clogit is stratified by group variable - but still fails
    fixed bugs stopping filenames with spaces
    fixed bug in _augment that caused "Obs. nos. out of range" error with very long variable list
    now an eclass command returning e(sample) from each separate command
version 0.12     3feb2009
    Augmentation respects a weight that has been stset
    Option saving(filename, replace) now works (previously gave obscure "invalid `clear'" error
    -stset- features are preserved even if the stcox model crashes
version 0.11    26sep2008
    changes from Stephen K: made eclass and enabled esave(N_sub N_fail) with logistic regressions
version 0.10    22aug2008    AS PUBLISHED IN SJ 9(1):40-56
    varcheck rewritten to cope with Stephen K's very strange example in Stata 9
    coef, or, nohr identified as separate options to be included in replay for hard
    new pause option
    decided not to capture augmented analysis as I've never had problems
version 0.9     8aug2008
    gives error when usevars() contains variables not in xvarlist
    bug fixed when usevars() is just one variable (PP was missed)
    new esave - adds selected e() to dataset
    (similarly undocumented rsave, for Stephen K)
    nodetails also suppresses augmentation details
    noauglist suppresses listing of augmenting observations 
    ppcmd allows alternative command (e.g. plogit) as alternative to augmentation
    ppfix(all) uses augmentation/ppcmd unconditionally
    hard captures results of first model fit & augments if error
    works with blogit (but augmentation doesn't)
    remove eqnames for any command, not just clogit
    augment() renamed augwt()
    nocons included as explicit option thus getting #parms right in _augment and disabling useconstant
    new output variables _ppfixed and _ppremains 
version 0.8    17mar2008
    _getcovcorr replaced with varcheck (_getcovcorr's check option isn't in Stata 9)
version 0.7.1  18dec2007   
    much improved augmentation 
        checks for missing variables and zero variances
        early event for any st command
    zerovar, missvar dropped and replaced with error and missing value
version 0.7  11dec2007   
    bugs fixed: single covariate -> perfect prediction always detected
                uselist default wrong
    much improved augmentation 
        checks for missing variables and zero variances
        early event for any st command
    zerovar, missvar dropped and replaced with error and missing value
version 0.6  19oct2007   
    uses augmented procedure (option augment() instead of hessadd())
version 0.5  18oct2007   
    attempts to detect when Stata has used a generalised inverse for V: 
        if detected, it augments the Hessian by `hessadd'*var(X) before inverting (version 10 only)
    missing beta's are replaced by zero with variance `zerovar', covariance 0
    NOTE: OK if there are no events in any category*study,
        but fails if there are no individuals in the reference category 
        (because a new reference category is chosen)
version 0.4  24sep2007   
    enable weights
version 0.3   5jul2007   
    rename use, cons as usevars, useconstant; 
    rename outputs as bvar1, Vvar1var2 etc. not b1, V11 etc.; 
    rename singular option as zerovar and improve warning message
version 0.2  28jun2007   
    handle clogit row/colnames: e(b), e(V) labelled y:x1, y:x2 etc. instead of x1, x2 etc.;
    append option; 
    if/in bug removed
*********************************************************************/

prog def mvmeta_make, eclass
version 11
ereturn hidden local mvmeta_make_version 4.1
local mvoptions ///
	SAVing(string) replace append clear /// save-file options
	USEVars(varlist) USEConstant USEEqs(string) LEARNif(string) /// what results are stored
	USECOEfs(string) esave(string) counts(string) COLLapse(string) /// what results are stored
    NAMEs(namelist min=2 max=2) infix(string) LONGnames keepmat /// how results are stored
    noDETails pause /// output 
    PPFix(string) AUGwt(real 0.0001) noAUGList PPCmd(string) /// perfect prediction behaviour 
    hard /// estimation
    debug dryrun rsave(string) countby(varname) // undocumented options

local cmdoptions STrata(passthru) noCONstant coef or nohr  /// command options requiring special treatment
	robust cluster(passthru) BAseoutcome(passthru) /// command options requiring special treatment
    * // other command options

* WHICH SYNTAX?
* if first character after mvmeta_make is "," then we have prefix syntax, otherwise we have classic syntax
if substr("`0'",1,1)=="," {
	local syntype prefix
}
else if substr("`0'",1,1)==" " {
	di as text "Program error"
	exit 498
}
else {
	local syntype classic
}

* PARSE CLASSIC (NON-PREFIX) SYNTAX
if "`syntype'"=="classic" {
	* detect multiple commas
	gettoken left right : 0, parse(",") bind
	local right: subinstr local right "," "" 
	gettoken left right : right, parse(",") bind
	if !mi("`right'") di as error "Probable syntax error: multiple commas found"

	syntax anything(equalok) [if] [in] [fweight aweight pweight iweight], ///
		by(varlist) [`mvoptions' `cmdoptions']
}

* PARSE PREFIX SYNTAX
else {
	gettoken prefixpart anything : 0, parse(":") bind
	local anything = trim(subinstr("`anything'",":","",1))
	
	* parse the mvmeta_make options
	local 0 `prefixpart'
	syntax, by(varlist) [`mvoptions']

	* parse the regcmd: might be prefix (main command after colon) or mixed (main command before ||)
	local prefixcmds bootstrap jackknife permute "mi estimate" 
	while inlist(word("`anything'",1), "bootstrap", "jackknife", "permute", "mi") { 
		// while a prefix command is detected
		gettoken one anything : anything, parse(":") bind
		local prefix `prefix' `one':
		local anything: subinstr local anything ":" ""
	}
	if word("`anything'",1) == "mixed" { 
		local strpos = strpos("`anything'","||")
		local postfix = substr("`anything'",`strpos',.)
		local anything = substr("`anything'",1,`strpos'-1)
	}
	
	local 0 `anything'
	syntax anything(equalok) [if] [in] [fweight aweight pweight iweight], ///
		[`cmdoptions']
}

* if postfix doesn't contain a comma, append one
_parse comma lhs rhs : postfix
if mi("`rhs'") local postfix `postfix',

if !mi("`debug'") {
	di as input "Initial results of parsing in `syntype' syntax:"
	foreach thing in prefix anything by if in weight postfix options {
		di as text _col(5) "`thing'" as result _col(16) "``thing''"
	}	
}

local options `options' `robust' `cluster' `baseoutcome'

*********************** PARSING ***********************

* Find yvar and xvarlist
gettoken regcmd regbody : anything, parse(" ")
unabcmd `regcmd'
local regcmd = r(cmd)
local anything `prefix' `anything'
if substr("`regcmd'",1,2)=="st" local xvarlist `regbody'
else if "`regcmd'"=="mvreg" {
	gettoken yvar xvarlist : regbody, parse("=")
	local xvarlist : subinstr local xvarlist "=" ""
}
else gettoken yvar xvarlist : regbody
if "`regcmd'"=="blogit" {
    gettoken nvar xvarlist : xvarlist
}
if "`regcmd'"=="mlogit" & mi("`baseoutcome'") {
    di as error `"mvmeta_make mlogit: baseoutcome() required"'
    exit 198 // otherwise -mlogit- might choose different baseoutcome in different studies
}
if inlist("`regcmd'","mixed","xtmixed") {
    gettoken xvarlist junk : xvarlist, parse("|")
*    local regbody `yvar' `xvarlist'
}
if inlist("`regcmd'","mlogit","mvreg") & !mi("`useeqs'") {
	di "useeqs() ignored"
	local useeqs
}	

if !mi("`yvar'") unab yvar : `yvar'
unab xvarlist : `xvarlist' // gives error message if factor variables used
if "`debug'"=="debug" {
	di as text "y variables: " _col(21) as result "`yvar'"
	di as text "x variables: " _col(21) as result "`xvarlist'"
}
if "`weight'"!="" local wtexp [`weight'`exp']

if "`names'"!="" {
   tokenize "`names'"
   local y `1'
   local S `2'
}
else {
   local y y
   local S S
}

if "`keepmat'"=="keepmat" {
   local ymat `y'
   local Smat `S'
}
else {
   tempname ymat Smat
}

if "`details'"=="nodetails" local qui qui
if !mi("`debug'") local noidicmd dicmd
tempname onevalue post

if "`hard'"=="hard" local hardcap capture

* augmentation options
if !mi("`robust'`cluster'") | "`weight'"=="pweight" { // Robust SE
    if "`ppfix'"=="" {
        local ppfix none
        di as error `"Robust standard error requested - ppfix set to none"'
    }
    else if inlist("`ppfix'", "check", "all") {
        di as error `"Robust standard error requested - ppfix(`ppfix') not allowed"'
        exit 198
    }
}
if inlist("`regcmd'","regress","mvreg","mixed","xtmixed") {
	local ycts ycts // augment y as continuous variable
}
if inlist("`regcmd'","mvreg","mixed","xtmixed") {
	if !inlist("`ppfix'","","none") di as error "ppfix(`ppfix') changed to ppfix(none): augmentation does not work with `regcmd'"
	* this is because these commands don't allow iweights
	local ppfix none
}
if "`ppfix'"=="" local ppfix check
if !inlist("`ppfix'","none","check","all") {
    di as error `"Please specify ppfix(none|check|all)"'
    exit 198
}
if "`ppcmd'"!="" {
    gettoken ppcmd1 ppcmd2 : ppcmd, parse(",")
    local ppcmd2=substr("`ppcmd2'",2,.)
}
if "`ppcmd'"=="" & `augwt'<=0 {
    local ppfix none
}


if "`append'"=="append" & "`replace'"=="replace" {
    di as error `"Can't have append and replace"'
    exit 198
}

local eformopts `coef' `or' `hr'

* check if user has saving(file, replace)
tokenize `"`saving'"', parse(",")
if "`3'"=="replace" {
    local replace replace
    local saving `1'
}    
* sort out clear
local savingorig `saving'
if mi("`saving'") {
	if mi("`clear'") {
		di as error "Please specify saving() or clear"
		exit 198
	}
	if !mi("`append'") {
		di as error "append ignored without saving()"
		local append
	}
	if !mi("`replace'") {
		di as error "replace ignored without saving()"
		local replace 
	}
	if !mi("`clear'") {
		tempfile saving
	}
}

if "`useconstant'" == "useconstant" & "`constant'"=="noconstant" {
	di as error "Can't have both useconstant and noconstant options"
	exit 198
}
if "`useconstant'" == "useconstant" & "`regcmd'"=="stcox" {
	di as error "useconstant option not allowed - stcox doens't have a constant"
	exit 198
}
if !mi("`usecoefs'") {
	if !mi("`usevars'") di as error "usecoefs() specified: usevars() ignored"
	if !mi("`useconstant'") di as error "usecoefs() specified: useconstant ignored"
	if !mi("`useeqs'") di as error "usecoefs() specified: useeqs() ignored"
	if !mi("`learnif'") di as error "usecoefs() specified: learnif() ignored"
}
else if mi("`learnif'") local learnif 1 // by default, use all data to learn coefficients

*********************** END OF PARSING ***********************

if !mi("`debug'") {
	di as input "Final results of parsing:"
	foreach thing in anything if in wtexp postfix strata constant eformopts options {
		di as text _col(5) "`thing' " as result _col(16) "``thing''"
	}
}

*********************** START ANALYSIS: IF/IN AND BYVARS ***********************

marksample touse, novarlist
markout `touse' `yvar' `xvarlist'

* Make summary by-variable
local byvarlist `by'
if wordcount("`by'")>1 {
	tempvar byvarname
	qui egen `byvarname' = group(`byvarlist') if `touse', label
}
else local byvarname `by'
qui levelsof `byvarname' if `touse', local(byvarnamelevels)
local nby : word count `bylevels'
cap confirm numeric var `byvarname'
local ischarbyvarname = _rc>0

* Create postfile expression for by-variables
foreach byvar of local byvarlist { 
    cap confirm string var `byvar'
    if _rc==0 { // string variables: find length
        tempvar length
        gen int `length'=length(`byvar')
        summ `length', meanonly
        local bypost `bypost' str`=r(max)'
    }
    else { // numeric variables: any label?
        local label`byvar' : value label `byvar'
        local labels2save `labels2save' `label`byvar''
    }
    local bypost `bypost' `byvar'
}
if !mi("`labels2save'") {
    tempfile labelsfile
    qui label save `labels2save' using `labelsfile'
}

*********************** SORT OUT USEVARS ***********************

if "`usevars'"=="" {
   local usevars `xvarlist'
}
local usevars : list uniq usevars
local p : word count `usevars'

* check `usevars' are within `xvarlist'
local errorvars : list usevars - xvarlist
if !mi("`errorvars'") {
	di as error `"`errorvars' found in usevars() but not in xvarlist"'
    exit 498
}

* assign `var`i'' locals
forvalues r=1/`p' {
   local var`p' : word `r' of `usevars'
}

if "`useconstant'" == "useconstant" {
    local ++p
    local var`p' _cons
    local usevars `usevars' _cons
}

*** SORT OUT COUNTS ***
foreach name in records subjects failures {
    foreach count in `counts' {
        if "`count'"==substr("`name'",1,length("`count'")) local counts2 `counts2' `name'
    }
}
local counts `counts2'
local counts2

*********************** IDENTIFY COEFFICIENTS ***********************


if !mi("`usecoefs'") {
	di as text "Using coefficients: " _c
	local ncoefs 0
	foreach usecoef of local usecoefs {
		local ++ncoefs
		local pos = strpos("`usecoef'","]")
		if `pos' local eq = substr("`usecoef'",2,`pos'-2)
		local colon = cond(`pos',":","")
		local var = substr("`usecoef'",`pos'+1,.)
		local coef`ncoefs' `eq'`colon'`var'
		local coefname`ncoefs' `infix'`eq'`infix'`var'
		if `pos' di as result "[`eq']`var' " _c
		else di as result "`var' " _c
	}
}

else {
	* initial run to identify equations without pp problems
	* stcox and mixed are problems
	* by default this fits FULL command to ALL data - learnif() simplifies
	di as text "Learning equation names..."
	if "`regcmd'"=="stcox" local estimate estimate
	`noidicmd' qui `anything' if `touse' & `learnif' `wtexp' `postfix' ///
		`strata' `constant' `eformopts' `options' `estimate'
	tempname b
	mat `b' = e(b)
	local beqs : coleq `b'
	local beqsuniq : list uniq beqs
	local bnames : colname `b'
	local beq1 : word 1 of `beqs'
	local ncoefs 0
	di as text "Using coefficients: " _c

	* special commands
	if inlist("`regcmd'","mlogit","mvreg") {
		local useeqs1 `beqsuniq'
		if inlist("`regcmd'","mlogit") { // drop equation for base outcome
			local dropeq : label (`yvar') `e(baseout)'
			local useeqs1 : list useeqs1 - dropeq
		}
		local useeqs2
	}
	else { 
		local useeqs1 `beq1'
		if "`useeqs'"=="*" local useeqs2 : list beqsuniq - beq1
		else local useeqs2 `useeqs'
	}
	local neqs : word count `useeqs1' `useeqs2'

	* coefficients in first type of equation (use all x's)
	foreach useeq of local useeqs1 {
		foreach usevar of local usevars {
			local ++ncoefs
			local coef`ncoefs' `useeq':`usevar' // for matrix subscripting
			if `neqs'==1 & mi("`longnames'") { // short name when possible
					local coefname`ncoefs' `infix'`usevar' // variable name in postfile
					di as result "`usevar' " _c
			}
			else {
					local coefname`ncoefs' `infix'`useeq'`infix'`usevar' // variable name in postfile
					di as result "[`useeq']`usevar' " _c
			}
		}
	}

	* coefficients in second type of equation (use everything in last fit)
	foreach useeq of local useeqs2 {
		forvalues j=1/`=colsof(`b')' {
			local thiseq : word `j' of `beqs'
			if "`useeq'" == "`thiseq'" { // jth parm is from equation `useeq'
				local thisname : word `j' of `bnames'
				if substr("`thisname'",1,2)=="o." continue
				local ++ncoefs
				local coef`ncoefs' `thiseq':`thisname'
				local coefname`ncoefs' `infix'`thiseq'`infix'`thisname'
				di as result "[`thiseq']`thisname' " _c
			}
		}
	}
}

di
if !mi("`dryrun'") {
	di as text "Dryrun requested - no analysis done"
	exit
}

*********************** SET UP POSTFILE ***********************

if "`debug'"=="debug" di as input "Setting up postfile..."
* identify coefficients and variances for post file
forvalues i = 1 / `ncoefs' {
    local bvars `bvars' `y'`coefname`i''
	local bpostvars `bpostvars' (`coef`i'')
    forvalues j = `i' / `ncoefs' {
        local Svars `Svars' `S'`coefname`i''`coefname`j''
    }
}

* ereturned and returned quantities
foreach e in `esave' {
    local evars `evars' _e_`e'
}
foreach r in `rsave' {
    local rvars `rvars' _r_`r'
}
if "`countby'"~="" { // SK code
    capture confirm string variable `countby'
    local strcount = _rc==0
    qui levelsof `countby', local(countbylevls)
    foreach levl in `countbylevls' {
      local addcount ns_`countby'_`levl' nf_`countby'_`levl' pt_`countby'_`levl'
      local countsby `countsby' `addcount'
    }
	 capture confirm variable _rec _nrec, exact
	 local uniquecond = cond(_rc == 0, "& _rec == _nrec", "")		/* distinct observations in case-cohort data declared by stsetcco */
}
/* SK generate time variable for computing person-time below, taking account of delayed entry */
tempvar timevar
qui gen double `timevar' = .
qui if "`:char _dta[_dta]'" == "st" {
	replace `timevar' = _t - _t0
	local idvar: char _dta[st_id]
}

if "`append'"=="append" {
    cap confirm file "`saving'"
    if _rc confirm file "`saving'.dta"
    tempfile postfile
}
else local postfile `saving'
postfile `post' `bypost' double(`bvars' `Svars') `evars' `rvars' `counts' `countsby' ///
	byte(_ppfixed _ppremains) using "`postfile'", `replace'

if !mi("`debug'") {
    foreach thing in bvars Svars evars rvars counts {
        di as text "`thing':" as result _col(21) "``thing''" 
    }
}

*********************** MAIN ANALYSIS ***********************

if !mi("`debug'") di as input `"Basic command is: `anything' `if' `in' `wtexp' `postfix' `strata' `constant' `eformopts' `options'"'

tempvar esample individual
gen byte `esample' = 0
gen int `individual' = _n
foreach level of local byvarnamelevels {
    `qui' di _newline
    if !mi("`debug'") di as input `"level `level'"'
    * identify this level
    if `ischarbyvarname' local levelvalue `""`level'""'
    else local levelvalue `level'

    summ `individual' if `byvarname' == `levelvalue', meanonly
    local first = r(min) // an obs in this by-group
	if mi("`first'") {
		di as error "Program error in mvmeta_make has led to wrongly seeking `byvarname'==`levelvalue'"
		exit 498
	}
    local bylevels
    local bydesc
    foreach byvar of local byvarlist {
        local bylevel = `byvar'[`first']
        cap confirm string variable `byvar'
        if !_rc { // string
            local bylevel `"`"`bylevel'"'"'
            local bylevel2 `bylevel'
        }
        else { // numeric
            local bylevel2 : label (`byvar') `bylevel'
        }
        local bylevels `bylevels' (`bylevel')
        local bydesc `bydesc' `byvar'==`bylevel2'
    }
    * di as input `"-> `bydesc'"' // not silenced by quietly
    di `"{input}-> `bydesc'"' // silenced by quietly
    
    local pptofix 0
    local fix fix
    forvalues pass=0/1 {
        local ppfound 0
        if "`ppfix'"=="all" {
            * always adjust for perfect prediction: bypass initial model fit
            local fix avoid
            local pptofix 1
        }
        *  DO THE MAIN REGRESSION
        local regrc 0
        if `pptofix'==0 {                 // WITHOUT FIXING PP
            `noidicmd' `hardcap' `qui' `anything' if `byvarname'==`levelvalue' & `touse' `wtexp' `postfix' `strata' `constant' `eformopts' `options'
            if "`hard'"=="hard" {
                local regrc = _rc
                if `regrc' {
                    di as error `"`bydesc': `regcmd' has returned error code `regrc': this may indicate perfect prediction"'
                    local ppfound 1
                }
                else if "`details'"!="nodetails" {
                    cap `regcmd', `eformopts' `options'
                    if !_rc `regcmd', `eformopts' `options'
                    else {
                        cap `regcmd', `eformopts'
                        if !_rc `regcmd', `eformopts'
                        else {
                            cap `regcmd'
                            if !_rc `regcmd'
                            else di "Can't redisplay `regcmd' results"
                        }
                    }
                }
            }
			if "`regcmd'"=="regress" local df_r_orig = e(df_r)
        }
        else if `pptofix'==1 {            // WITH FIXING PP
			if "`ppcmd'"!="" {
                di as error `"`bydesc': attempting to `fix' perfect prediction by using `ppcmd'"'
               `qui' `ppcmd1' `regbody' if `byvarname'==`levelvalue' & `touse' `wtexp', `strata' `constant' `eformopts' `options' `ppcmd2'
            }
            else {
                if "`regcmd'"=="cox" | substr("`regcmd'",1,2)=="st" local st st
                di as error `"`bydesc': attempting to `fix' perfect prediction by augmenting with `augwt' observations per parameter"'
                if "`st'"=="st" di as error `"   (counting baseline hazard as 1 parameter)"'
                preserve
				tempvar wtvar augvar
                local list = cond("`auglist'"!="noauglist", "list", "")
                if "`regcmd'"=="clogit" local groupvar groupvar(`e(group)')
                `qui' _augment if `touse' `wtexp', `list' `st' xvarlist(`xvarlist') ///
					yvar(`yvar') subgroup(`byvarname'==`levelvalue') timesweight(`augwt') ///
					wtvar(`wtvar') augvar(`augvar') `strata' `groupvar' `constant' `ycts'
				local wtexp2 [iweight=`wtvar']
                if "`st'"=="st" {
                    qui stset _t _d if _st `wtexp2', time0(_t0)
                    local wtexp2
                }
                `qui' di as text _newline "Analysis after augmentation:"
                `noidicmd' `qui' `anything' if (`byvarname'==`levelvalue' & `touse')|`augvar' `wtexp2' `postfix' `strata' `constant' `eformopts' `options'
                restore
            }
        }
        if `regrc'==0 {
            mat `ymat'`level'=e(b)
			if "`regcmd'"=="regress" & !mi("`df_r_orig'") {
				local varscale = e(df_r) / `df_r_orig'
				// regression variance is best calculated as RSS/RDF where RDF is from *unaugmented* regression
			}
			else local varscale 1
			if `varscale'!=1 & !mi("`debug'") di as text "Scaling variance by ratio of residual df: " as result "`e(df_r)' / `df_r_orig'"
            mat `Smat'`level'=`varscale'*e(V)

            if !mi("`debug'") {
               mat l `ymat'`level', title(e(b) for study `level')
               mat l `Smat'`level', title(e(V) for study `level')
            }
            *  CHECK FOR PERFECT PREDICTION:
/*
			*** change 20jan2022: reduce to the required matrix before checking for PP
			* fails with logit - need to add the equation names to `row', `col'
			* MISGUIDED since failure to estimate one coefficient casts otehrs in doubt
			tempname SS
			mat `SS'=J(`p',`p',.)
			forvalues r=1/`p' {
				local row : word `r' of `usevars'
				forvalues c=1/`p' {
					local col: word `c' of `usevars'
					mat `SS'[`r',`c'] = `Smat'`level'["`row'", "`col'"]
				}
			}
			if !mi("`debug'") mat l `SS', title("Variance matrix being checked")
            cap varcheck `SS', check(pd)
*/
            matdropo `ymat'`level' `ymat'`level'
			cap varcheck `Smat'`level', check(pd)
            if _rc {
                `qui' di 
                di as error `"`bydesc': perfect prediction or inestimable parameter"' 
                di as error `"   (V matrix is not positive definite)"'
                `qui' mat l `Smat'`level', title(V)
                local ppfound 1
            }
            else {
               local missing 
               forvalues j = 1 / `ncoefs' { 
				  cap mat `onevalue' = `ymat'`level'[1,"`coef`j''"]
				  if _rc local missing `missing' `y'`coefname`j''
               }
               if !mi(`"`missing'"') {
                   `qui' di 
                   di as error `"`bydesc': perfect prediction or inestimable parameter"' 
                   di as error `"   (parameters `missing' have been dropped)"' 
                   local ppfound 1
               }
            }
        }
        
        * OPTIONALLY PREPARE FOR 2ND PASS
        if "`regcmd'"=="blogit" & `ppfound' & "`ppcmd'"=="" {
            di as error `"Sorry, augmentation is not available with blogit as it doesn't allow weights"'
            continue, break
        }
        if "`ppfix'"=="all" | `pass'==1 {
            if `ppfound' di as error `"`bydesc': perfect prediction has not been `fix'ed"'
            else di as text `"`bydesc': perfect prediction has been `fix'ed"'
        }
        if "`ppfix'"=="none" & `ppfound'==1 di as error `"`bydesc': perfect prediction fixing disabled"'
        if "`ppfix'"=="all" | "`ppfix'"=="none" | `ppfound'==0 continue, break
        if `pass'==0 local pptofix `ppfound'
    }
    if !mi("`debug'") di as input `"Estimation completed for study `levelvalue'"'

if !mi("`debug'") {
   mat l `ymat'`level', title(Ready to post: e(b) for study `level')
   mat l `Smat'`level', title(Ready to post: e(V) for study `level')
}

    * POST THE RESULTS 
    local blist
    local Slist
	forvalues i = 1 / `ncoefs' {
		cap mat `onevalue' = `ymat'`level'[1,"`coef`i''"]
		if _rc {
			di as error `"`bydesc': missing `coefname`i''"'
			local bvalue .
		}
		else {
			local bvalue = `onevalue'[1,1]
		}
		local blist `blist' (`bvalue')
		forvalues j = `i' / `ncoefs' {
			cap mat `onevalue' = `Smat'`level'["`coef`i''", "`coef`j''"]
			if !_rc {
			   local Svalue = `onevalue'[1,1]
			}
			else {
			   di as error `"`bydesc': missing `S'`coefname`i''`coefname`j''"'
			   local Svalue .
			}
			if `i'==`j' & `Svalue' == 0 {
			   di as error `"`bydesc': missing `S'`coefname`i''`coefname`j''"'
			   local Svalue .
			}
			local Slist `Slist' (`Svalue')
        }
    }

    local rlist
    foreach r in `rsave' {
        local rlist `rlist' (r(`r'))
    }
    local elist
    foreach e in `esave' {
        if inlist("`e(cmd)'", "logistic", "logit", "clogit") & "`e'"=="N_sub" {
            qui count if e(sample)          /*21dec09*/
            local elist `elist' (`=r(N)')    /*21dec09*/
        }
        else if inlist("`e(cmd)'", "logistic", "logit", "clogit") & "`e'"=="N_fail" {
            qui count if `e(depvar)'==1 & e(sample)
            local elist `elist' (`=r(N)')
        }
        else local elist `elist' (`=e(`e')') 
        /* 30may2014: unavailable `e' evaluates as . not empty, hence doesn't crash */
    }
    local clist
    foreach count in `counts' {
        if "`count'"==substr("records",1,length("`count'")) {
            qui count if e(sample)         
            local clist `clist' (`=r(N)')    
        }
        else if "`count'"==substr("subjects",1,length("`count'")) {
            tempvar isin 
            gen byte `isin' = e(sample)
            if "`regcmd'"=="stcox" { // identify unique obs per id
                local id : char _dta[st_id]
                if "`id'"!="" {
                    local sort : sortedby
                    sort `id' `isin'
                    qui by `id': replace `isin'=0 if _n<_N
                    if "`sortedby'"!="" sort `sortedby'
                }
            }
            qui count if `isin'       
            local clist `clist' (`=r(N)')    
        }
        else if "`count'"==substr("failures",1,length("`count'")) {
            if "`regcmd'"=="stcox" local event _d
            else local event `e(depvar)'
            qui count if e(sample) & `event'
            local clist `clist' (`=r(N)')    
        }
        else {
            di as error `"counts(`count') not allowed"'
            exit 198
        }
    }
    if "`countby'"~="" {
    	 local countsby
    	 local depvar = cond("`e(cmd)'"=="cox", "_d", "`e(depvar)'")
		 if !missing("`idvar'") {
			tempvar idsubgroup
			egen `idsubgroup' = tag(`idvar' `countby') if e(sample) `uniquecond'
			local idsubgcond = "& `idsubgroup' == 1"
       }
		 qui foreach levl in `countbylevls' {
			  local subgroup = cond(`strcount'==1, `"`countby'=="`levl'""', `"`countby'==`levl'"')
			  count if e(sample) & `subgroup' `uniquecond' `idsubgcond'
			  local ns = r(N)
			  count if e(sample) & `depvar'==1 & `subgroup' `uniquecond'
			  local nf = r(N)
			  local pt = .
			  if !missing("`timevar'") {
					summ `timevar' if e(sample) & `subgroup'
					local pt = r(sum)
			  }
			  local addcount (`ns') (`nf') (`pt')
			  local countsby `countsby' `addcount'
		 }
		 capture drop `idsubgroup'
    }
    qui replace `esample' = e(sample) if `byvarname'==`levelvalue' & `touse'
    local postcommand post `post' `bylevels' `blist' `Slist' `elist' `rlist' `clist' `countsby' (`pptofix') (`ppfound') 
    if "`debug'"=="debug" di as input `"Post command: `postcommand'"'
	`postcommand'
	`pause'
}
postclose `post'

preserve
if !mi("`collapse'") { // combine postfile with summary results
	cap collapse `collapse' if `touse', by(`byvarlist')
	if _rc {
		di as error "mvmeta_make: collapse option failed"
	}
	else {
		tempfile collapsedata
		sort `byvarlist'
		qui save `collapsedata'
		use `postfile', clear
		sort `byvarlist'
		qui merge 1:1 `byvarlist' using `collapsedata'
		cap assert _merge==3
		if _rc di as error "Warning: merge was imperfect"
		drop _merge
		qui save `postfile', replace
	}
}

// Tidy up saved results (and append to existing results if requested)
use "`saving'", clear
if "`append'"=="append" append using `postfile'
label var _ppfixed "Perfect prediction fixed?"
label var _ppremains "Perfect prediction remains in this result?"
if !mi("`labelsfile'") qui do `labelsfile'
foreach byvar of local byvarlist {
    if !mi("`label`byvar''") label val `byvar' `label`byvar''
}
`qui' di
if !mi("`savingorig'") save "`saving'", replace
if !mi("`clear'") {
	if !mi("`savingorig'") di as text "mvmeta_make results are also loaded into memory"
	else di as text "mvmeta_make results are now loaded into memory"
	restore, not
	ereturn post // removes ereturned results from last regression
}
else {
	restore
	ereturn post, esample(`esample')
}

// e-class 
ereturn local cmdline mvmeta_make `0'
ereturn local cmd mvmeta_make

end

******************************************************************************************

program define _augment
* varlist changed to new options 22jun2015: xvarlist, yvar, subgroup
version 11
syntax [if] [in] [fweight aweight pweight iweight], ///
	xvarlist(varlist) subgroup(string) ///
	[yvar(varlist) TOTALweight(real 0) TIMESweight(real 0) noPREServe list ///
	wtvar(string) augvar(string) noequal st ycts strata(varlist) ///
	noconstant groupvar(string)]

if mi("`yvar'`st'") {
	di as error "mvmeta_make: _augment call must have yvar() or st option"
	exit 498
}
if "`wtvar'"=="" local wtvar _weight
if "`augvar'"=="" local augvar _augment
confirm new var `wtvar' `augvar'

tempvar augment wt
if "`weight'"!="" gen float `wt' `exp'
else gen float `wt' = 1

marksample touseall
tempvar touse
gen byte `touse' = `touseall' & (`subgroup')

// Sort out some locals
if "`ycts'"=="ycts" {
	qui summ `yvar'
	if r(sd)<=0 {
		di as error "Error in _augment: `yvar' does not vary"
		exit 498
	}
	local ylow = r(mean)-r(sd)
	local yupp = r(mean)+r(sd)
	local nylevels 2
	local ylevels `ylow' `yupp'	
}
else if "`st'"=="" {
    qui levelsof `yvar' if `touseall', local(ylevels) // NB and not if `subgroup'
    qui tab `yvar' if `touseall' [iw=`wt']
    local nylevels = r(r)
    local totw = r(N)
}
else {
    st_is 2 analysis
    qui replace `touse'=0 if _st==0
    local yvar _t
    local nylevels 2
	local st_wv : char _dta[st_wv]
	if "`st_wv'"!="" replace `wt'=`wt'*`st_wv'
    summ `wt' if _st & `touse', meanonly
    local totw = r(sum)
    local stvars _t _d
    summ _t if _st & `touse', meanonly
    local tmin = r(min)/2
    local tmax = r(max)+r(min)/2
    local ylevels `tmin' `tmax'
}
local Nold = _N

// Count x's
local nx : word count `xvarlist'

// Set total weight of added observations
if `totalweight'>0 & `timesweight'>0 {
    di as error `"_augment: Can't specify totalweight() and timesweight()"'
    exit 498
}
if `totalweight' == 0 local totalweight = `nx' + ("`constant'"!="noconstant")
if `timesweight'>0 local totalweight = `totalweight' * `timesweight'

// Number of added observations
local Nadd = `nx'*2*`nylevels'
local Nnew = `Nold'+`Nadd'
di as text "Adding " as result `Nadd' as text " pseudo-observations "_c
if "`strata'"!="" di as text "per stratum " _c
di as text "with total weight " as result `totalweight'

qui {
    set obs `Nnew'
    gen byte `augment' = _n>`Nold'
    local thisobs `Nold'
    // Handle groupvar - intended for clogit
    if "`groupvar'"!="" {
        qui summ `groupvar' if `touse'
        local augxnum = r(max)        // Counts x-groups
    }
    else local augxnum 0
    foreach x of var `xvarlist' {
       local augxnum=`augxnum'+2
       sum `x' [iw=`wt'] if `touse' & !`augment'
       if r(sd)==0 {
          * No variation in this cohort: use SD across all cohorts
          sum `x' [iw=`wt'] if !`augment'
       }
       if r(sd)==0 {
          di as error "_augment: no variation in `x' found, even across all cohorts"
       }
       local mean = r(mean)
       local sd = r(sd)*sqrt((r(sum_w)-1)/r(sum_w))
       replace `x' = `mean' if `augment'
       local auginum 0               // Counts obs within x-groups
       foreach yval in `ylevels' {
          if "`equal'"=="noequal" {
             summ `wt' if `yvar'==`yval' & `touse' & !`augment', meanonly
             local py = r(sum)/`totw'
          }
          else local py = 1/`nylevels'
          foreach xnewstd in -1 1 {
             local ++thisobs
             local ++auginum
             replace `x' = `mean'+(`xnewstd')*`sd' in `thisobs'
             replace `yvar' = `yval' in `thisobs'
             replace `wt'= `totalweight' * `py' / (2*`nx') in `thisobs'
             if "`groupvar'"!="" replace `groupvar' = `augxnum' + (`auginum'==2|`auginum'==3) in `thisobs'
          }
       }
    }
    if "`st'"=="st" {
       replace _d=1 if `yvar'==`tmin' & `augment'
       replace _d=0 if `yvar'==`tmax' & `augment'
       replace _t0=0 if `augment'
       replace _st=1 if `augment'
    }
}

// Handle strata
if "`strata'"!="" {
    qui {
       foreach stratvar of varlist `strata' {
           cap confirm string variable `stratvar' 
           local isstring = _rc==0
           levelsof `stratvar' if `touse' & !`augment', local(stratlevels)
           local nlevels : word count `stratlevels'
           forvalues i=2/`nlevels' {
               local Noldplus1=_N+1
               expand 2 if `augment' & missing(`stratvar')
               local thislevel : word `i' of `stratlevels'
               if `isstring' replace `stratvar'="`thislevel'" in `Noldplus1'/l
               else replace `stratvar'=`thislevel' in `Noldplus1'/l
           }
           local thislevel : word 1 of `stratlevels'
           if `isstring' replace `stratvar'="`thislevel'" if `augment' & missing(`stratvar')
           else replace `stratvar'=`thislevel' if `augment' & missing(`stratvar')
           replace `wt'=`wt'/`nlevels' if `augment' 
       }
    }
}

rename `wt' `wtvar'
rename `augment' `augvar'

if "`list'"=="list" {
    di as txt _newline "Listing of added records:"
    char `wtvar'[varname] weight
    label var `wtvar' "Weight"
    char `augvar'[varname] augment
    label var `augvar' "Augmented?"
    list `stvars' `strata' `groupvar' `xvarlist' `yvar' `wtvar' if `augvar', sep(4) subvarname
}

end


prog def varcheck
syntax anything, [check(string)]
if colsof(`anything') != rowsof(`anything') {
    di as error `"varcheck: `anything' is not a square matrix"'
    exit 498
}
* Remove any coeffs whose name starts "o."
matdropo `anything' `anything'
local dim = rowsof(`anything')
* Check for missing values, adapted to cope with the following special case
* In Stata 9, I have come across a matrix M of values 1.#QNAN that returns matmissing(M)=0 but matmissing(M+M)=1
tempname anything1
mat `anything1'=`anything'+`anything'
if matmissing(`anything1') {
    di as error `"varcheck: `anything' has missing values"'
    exit 498
}
if `dim' == 1 {
    * 1x1 matrix
    local mineigen = `anything'[1,1]
}
else {
    * larger matrix
    forvalues r=1/`dim' {
        if `anything'[`r',`r']<=0 {
			di as error `"varcheck: `anything' has variance<=0"'
			exit 498 
		}
        forvalues s=1/`dim' {
            if (`anything'[`r',`s'])^2>`anything'[`r',`r']*`anything'[`s',`s'] {
				di as error `"varcheck: `anything' has correlation outside [-1,1]"'
				exit 498 
			}
        }
    }
    if "`check'"!="" {
       tempname evecs evals
       mat symeigen `evecs' `evals' = `anything'
       local mineigen = `evals'[1,`dim']
    }
}
if "`check'"=="psd" {
    if `mineigen'<0 {
        di as error `"varcheck: `anything' is not positive semi-definite"'
		mat l `evals'
        exit 506
    }
}
else if "`check'"=="pd" {
    if `mineigen'<=0 {
        di as error `"varcheck: `anything' is not positive definite"'
		mat l `evals'
        exit 506
    }
}
end


prog def matdropo
args matin matout 
* selects submatrix of matin whose rownames don't start "o." and stores it in matout
foreach rowcol in row col {
	local `rowcol'fullnames : `rowcol'fullnames `matin'
	tempname `rowcol'select
	foreach `rowcol'fullname of local `rowcol'fullnames {
		if strpos("``rowcol'fullname'",":") {
			gettoken `rowcol'eq `rowcol'name : `rowcol'fullname, parse(":")
			local `rowcol'name : subinstr local `rowcol'name ":" ""
		}
		else local `rowcol'name ``rowcol'fullname'
		local ok = strpos("``rowcol'name'","o.")!=1
		mat ``rowcol'select' = nullmat(``rowcol'select'),(`ok')
		if `ok' local new`rowcol'fullnames `new`rowcol'fullnames' ``rowcol'fullname'
	}
}
mata {
	rowselect=st_matrix("`rowselect'")
	colselect=st_matrix("`colselect'")
	matin=st_matrix("`matin'")
	matout=select(matin,rowselect')
	matout=select(matout,colselect)
	st_matrix("`matout'",matout)
}
mat rownames `matout' = `newrowfullnames'
mat colnames `matout' = `newcolfullnames'
end


prog def dicmd
noi di as input `"`0'"'
`0'
end
