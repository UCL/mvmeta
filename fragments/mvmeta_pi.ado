/*
*! v0.2 IW 14oct2021
	now works also with long parameterisation
	NEED warning after metaregression
v0.1 IW 8apr2020

Form prediction intervals after mvmeta
Assumes df = total sample size minus 2: this matches univariate advice
*/

prog def mvmeta_pi
syntax [, format(string) level(cilevel)]

if mi("`format'") local format %9.0g

if e(cmd)!="mvmeta" {
	di as error "mvmeta was not the last command run"
	exit 301
}

* detect meta-regression
local metareg 0
forvalues i=1/`e(dims)' {
	if !mi(e(xvars_`i')) local metareg 1
}

local plevel = (100+`level')/200

local col1 _col(1)
forvalues i=2/6 {
    local pos = 1+12*(`i'-1)
    local col`i' `format' _col(`pos')
}
if `metareg' local metaregnote for the meta-regression intercepts
di as txt _n "Table of prediction intervals `metaregnote'" _n "{hline 70}" 
di `col1' as txt "Outcome" `col2' "Estimate" `col3' "`level'% Confidence Int." `col5' "`level'% Prediction Int."

tempname Sigma
mat `Sigma'=e(Sigma)
local df = e(N)-2
foreach yvar in `e(yvars)' {
	if e(parmtype)=="short" { 
		local est = _b[`yvar']
		local se  = _se[`yvar']
	}
	else {
		local est = [`yvar']_b[_cons]
		local se  = [`yvar']_se[_cons]
	}
	local pme = invnorm(`plevel') * `se'
	local pmp = invt(`df',`plevel') * sqrt(`se'^2 + `Sigma'["`yvar'","`yvar'"])
	di `col1' as txt "`yvar'" `col2' as res `format' `est' `col3' `format' `est'-`pme' `col4' `format' `est'+`pme' `col5' `format' `est'-`pmp' `col6' `format' `est'+`pmp'
}
di as txt "{hline 70}"
di as txt "Note: using N-2=" as res `df' as txt " degrees of freedom"

end
