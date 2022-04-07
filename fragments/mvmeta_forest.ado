*=========================== START OF MVMETA_FOREST PROGRAM ===========================
/*
version 1.0.1  25apr2015 Ian White & Ben Jann
This file (mvmeta_forest.ado) is directly called by mvmeta.ado. 
It does not use the current data at all; instead it uses e()
- to create a data set containing estimates, std errors and variables to tabulate for each study
- to provide uv and mv summaries
Problems: the coefplot call in this program removes e() results - how?

version 1.0.0  13feb2015  Ian White & Ben Jann
TO DO 27mar2015: if e(sample) is not set, could it still work? would be nice for mvmeta y S, forest noest to work? else give 
better error message.
Changed (bj 13feb2015):
- user can now specify custom byopts()
- removed -mcol(gray) ciopts(lcol(black))- as defaults for studies and added mcol(*.6)
- now -mv(label() line() predict() subopts)- instead of mvlabel() mvline() predict() mvopts()
- now -uv(label() line() predict() subopts)- instead of uvlabel() uvline() predict() uvopts()
- predict options other than df() and levels() are automatically wrapped into ciopts()
- new -weight(xpos() format() title() tskip() alignment() subopts)-; -nowt- discarded
- tabulate() is now -tabulate(varlist, xpos() nolabel tskip() alignment() subopts)

Changes (bj 12feb2015):
- addplot() started with "||" if only uv was included; I fixed this (it's just 
  a matter of clean style, it doesn't affect the resulting plot)
- truncated CIs now use pcarrow; ll()/ul() replaced by range(ll ul, subopts)
    o can use "." for +/- infty, e.g. range(. 2), range(-2 .)
    o subopts are as in -help twoway pcarrow-
- pstyles 2 and 3 are now used for the diamonds and for mv/uv lines; mv/uv lines are dashed
- changed order of the code for mvline and uvline back because mv comes first in the graph
  (or do you want that flipped? i.e. uv directly after the studies and the mv below that?)
- option "nowt" was called as "`nowt'" instead as "`wt'"; fixed this
- tabulated numbers were not vertically centerd at the tick if column title
  had multiple lines; this is fixed
- tablated numbers had leading spaces; this is fixed (numbers are now always
  left alligned; ylabel() does not offer any possibility to change the 
  alignment)
- tabulate(, novarlabel) is now tabulate(, nolabel); moreover, nolabel no longer 
  affects the weight variables
- tabulate(, yvalue()) is now tabulate(, tpos()) (Title POSition)

Changes (bj 30jan2015):
 - version statement added
 - now picks up the estimation sample
 - now picks up study values/value labels from id()
 - options mvline()/uvline() add lines at mv/uv estimates 
   (had to make sure that this also works properly if name() is specified; 
   graph is displayed at the end after adding the lines)
 - adjusted coefplot command for situations in which there is only one subgraph
 - added options mvlabel() and uvlabel() to specify labels for mv and uv
 - added options mvopts() and uvopts() to specify options for mv and uv
 - added options ll() and ul() to chop off the study confidence intervals 
   (maximum chopping cannot go past the point estimate); syntax is:
        ll/ul(# [, label() size() angle() textstyle() style()])
 - removed option -run- (didn't do anything, did it?)
 - added option predict() to specify options for the prediction interval
 - added quietly to coefplot

notes
    prediction interval uses normal distribution, not t(k-2) as does metan
        ==> use predict(df(#))
    doesn't assume parmtype=short - pooled results just take the first p coeffs, having checked there are no covariates
        ?commonparm might be a problem?
any tabulate variables will first have to be created!
*/

program define mvmeta_forest, /*sortpreserve*/
    version 9
    syntax, [ ///
        /*id(varname)*/ COEFLabels(str asis) range(str) ///
        DIAmondheight(real 0.2) noMv Mv2(str) noUv Uv2(str) ///
        Weights Weights2(str) /*TABulate(str)*/ /// 
        TItle(passthru) XRescale BYOPts(str) ///
        eform NODRAW name(str) debug * ]
    if !mi("`debug'") di as input "mvmeta_forest `0'"        
    if /*mi("`id'") &*/ !mi(e(id)) local id = e(id)
    if "`e(bsest)'"=="" { // no estimates -> no summaries
        local uv nouv
        local uv2
        local mv nomv
        local mv2
    }
    if `"`range'"'!="" {
        parse_range `range' // returns ll, ul, ropts
    }
    local coefplot_options `eform' `options'
    if "`mv'"=="" {
        parse_mvuvopts mv, `mv2' // returns mvlabel mvline mvline2 mvpredict mvpredict2 mvopts
    }
    if "`uv'"=="" {
        parse_mvuvopts uv, `uv2' // returns uvlabel uvline uvline2 uvpredict uvpredict2 uvopts
    }
    if `"`weights'`weights2'"'!="" {
        local weights weights
        parse_weights, `weights2' // returns w_xpos, w_title, w_tskip, w_align, w_format, w_opts
    }
    if `"`tabulate'"'!="" {
        parse_tabulate `tabulate' // returns t_vars, t_xpos, t_label, t_tskip, t_align, t_opts
    }
    if !mi("`debug'") local dicmd dicmd
    
    * get the weights - CODE NEEDS ADAPTING TO TAKE WEIGHTS FROM MATRIX wt
*    if "`e(parmtype)'"!="common" & "`estimates'"!="noestimates" {
    if !mi("`weights'") {
        cap mvmeta_wt, mat(wt)
        if _rc di as error "mvmeta_forest: weights could not be computed (error " _rc ")"
        else di "mvmeta_forest: weights have been computed"
    }

    // mark sample and place selected obs first (to make collecting labels easier)
*    qui count if e(sample)
*    local N = r(N)
*    tempvar outofsample
*    qui gen byte `outofsample' = 1 - e(sample)
*    sort `outofsample' `_sortindex'
*    local touse "in 1/`N'" 
    local N = e(N)
    local touse // remove all instances of `touse' later 

    // get data
    tempname ydata Sdata
    mat `ydata' = e(ydata) // etc.
    mat `Sdata' = e(Sdata) // etc.

    // collect labels
    tempvar idvar
    qui gen `idvar' = _n `touse' // I'm not sure this is used
    local lbls
    tempname ystudy // new
*    if `"`id'"'!="" {
*        local idvallab: val lab `id'
        forv i = 1/`N' {
*            local lbl: di `id'[`i']
*            if `"`idvallab'"'!="" {
*                local lbl: label `idvallab' `lbl'
*            }
*            local lbls `"`lbls' `i' = `"`lbl'"'"'
            mat `ystudy' = `ydata'[`i',1...]
            local lbl : rownames `ystudy'
            local lbls `"`lbls' `i' = `"`lbl'"'"'
            local studyname`i' `"`lbl'"'
        }
*    }
    foreach est in mv uv {
        if `"``est''"'=="" {
            if `"``est'label'"'!="" local lbls `"`lbls' `est' = `"``est'label'"'"'
            else                    local lbls `"`lbls' `est' = "Pooled `est'""'
        }
    }
    if `"`lbls'"'!="" {
        if `"`coeflabels'"'!="" {
            _parse comma lhs rhs : coeflabels
            local coeflabels `"`lhs'`lbls'`rhs'"'
        }
        else {
            local coeflabels `"`lbls'"'
        }
    }
    if `"`coeflabels'"'!="" {
        local coeflabels coeflabels(`coeflabels')
    }
    
    // collect some settings
    local p = e(dims)
*    local ystub = e(ystub)
*    local Sstub = e(Sstub)
    tempname ystub Sstub

    // check if there are covariates
    local hasx 0
    forvalues r = 1/`p' {
        if !mi("`e(xvars_`r')'") local hasx 1
    }
    if `hasx' | e(parmtype)=="common" {
        if ("`uv'"!="nouv" | "`mv'"!="nomv" | "`uvline'"!="" | "`mvline'"!="") {
            di as error "Sorry, forest plot can't show summaries - last mvmeta run " _c
            if `hasx' di "had covariates"
            else if e(parmtype)=="common" di "used commonparm option"
            local mv nomv
            local uv nouv
            local uvline
            local mvline
        }
    }
    else if "`weights'"!="" { // weights are wanted
    // weights are now held in e(wt) ...
*        tempname weight
*        qui mvmeta_bos, gen(`weight')
*        forvalues r=1/`p' {
*            local weightlist `weightlist' `weight'`r' 
*        }
    }
    
    // collect point estimates and standard errors of studies (some code brought up from later)
*    forvalues i=1/`p' {
*        local yvar = word(e(yvars),`i')
*        local yend = subinstr("`yvar'",e(ystub),"",1)
*        qui gen `sestub'`i' = sqrt(`e(Sstub)'`yend'`yend') `touse'
*        local sevars `sevars' `sestub'`i'
*    }
    mat `ystub' = e(ydata)
    tempname S
    forvalues i=1/`N' {
        mat `S'=`Sdata'[(`i'-1)*`p'+1..`i'*`p',1...]
        mat `S' = vecdiag(cholesky(diag(vecdiag(`S')))) /* FAILS IF MISSING VALUES */
        mat rownames `S' = `"`studyname`i''"'
        if `i'==1 mat `Sstub' = `S'
        else mat `Sstub' = `Sstub' \ `S'
    }
*    mkmat `e(yvars)'   `touse', mat(`ystub') rownames(`idvar') // study estimates
*    mkmat `sevars'     `touse', mat(`Sstub') rownames(`idvar') // standard errors of study estimates
*    drop `sevars'
    // weights and tabulate
    // I've changed weightlist to weights here & later
    if "`weights'`t_vars'"!="" & ("`w_xpos'"=="" | "`t_xpos'"=="") {
*        tempvar citmp
        tempname minmat maxmat
        mata: st_matrix("`minmat'",colmin(st_matrix("`ystub'")-1.96*st_matrix("`Sstub'")))
        mata: st_matrix("`maxmat'",colmax(st_matrix("`ystub'")+1.96*st_matrix("`Sstub'")))
        forv r = 1/`p' {
*            local yvar  : word `r' of `e(yvars)'
*            local sevar : word `r' of `sevars'
            if "`ll'"!="" local min `ll'
            else {
*                qui gen `citmp' = `yvar' - 2 * `sevar' `touse'
*                su `citmp', meanonly
*                local min = r(min)
*                drop `citmp'
                local min = `minmat'[1,`r']
            }
            if "`ul'"!="" local max `ul'
            else {
*                qui gen `citmp' = `yvar' + 2 * `sevar' `touse'
*                su `citmp', meanonly
*                local max = r(max)
*                drop `citmp'
                local max = `maxmat'[1,`r']
            }
            local tab_xstep_`r' = (`max' - `min')/3
            local tab_x0_`r'    = max(`max',0) + `tab_xstep_`r''
        }
    }
    local j 0
    if "`weights'"!="" {
        tempname wtmat // new
        mat `wtmat' = e(wt) // new
        if `w_tskip'>0 {
            local max = `N' + ("`mv'"!="nomv") + ("`uv'"!="nomv") + 0.5
            local min = 1 - `w_tskip' - 0.5
            local yrange yscale(range(`min' `max'))
        }
        if      `"`w_align'"'=="left"   local pos 3
        else if `"`w_align'"'=="center" local pos 0
        else                            local pos 9
        local ++j
        local tab_opts_`j'  `w_opts'
        local tab_tskip_`j' `w_tskip'
*        local k 0
*        foreach var of local weightlist { 
        forvalues k=1/`p' { // change k to r
*            local ++k
            if "`tab_x0_`k''"!="" {
                local tab_x_`j'_`k' `tab_x0_`k''
                local tab_x0_`k' = `tab_x0_`k'' + `tab_xstep_`k''
            }
            if `"`w_xpos'"'!="" {
                gettoken tab_x_`j'_`k' w_xpos : w_xpos
                local tab_x_last `tab_x_`j'_`k''
            }
            else if "`tab_x_last'"!="" {
                local tab_x_`j'_`k' `tab_x_last'
            }
            local tab_ti_`j'_`k' `"1 = `pos' `"`w_title'"'"'
            forv i = 1/`N' {
                local lbl: di `w_format' /*`var'[`i']*/ `wtmat'[`i',`k']
                local lbl `lbl'
                local tab_`j'_`k' `"`tab_`j'_`k'' `i' = `pos' `"`lbl'"'"'
            }
        }
        local tab_x_last
    }
    if "`t_vars'"!="" {
        if `t_tskip'>0 {
            if "`yrange'"=="" {
                local max = `N' + ("`mv'"!="nomv") + ("`uv'"!="nomv") + 0.5
                local min = 1 - `t_tskip' - 0.5
                local yrange yscale(range(`min' `max'))
            }
            else {
                if `t_tskip'>`w_tskip' {
                    local max = `N' + ("`mv'"!="nomv") + ("`uv'"!="nomv") + 0.5
                    local min = 1 - `t_tskip' - 0.5
                    local yrange yscale(range(`min' `max'))
                }
            }
        }
        if      `"`t_align'"'=="left"   local pos 3
        else if `"`t_align'"'=="center" local pos 0
        else                            local pos 9
        local k 0
        foreach var of local t_vars {
            if `++k'>`p' local k 1
            if `k'==1 {
                local ++j
                local tab_tskip_`j' `t_tskip'
                local tab_opts_`j'  `t_opts'
            }
            if "`tab_x0_`k''"!="" {
                local tab_x_`j'_`k' `tab_x0_`k''
                local tab_x0_`k' = `tab_x0_`k'' + `tab_xstep_`k''
            }
            if `"`t_xpos'"'!="" {
                gettoken tab_x_`j'_`k' t_xpos : t_xpos
                local tab_x_last `tab_x_`j'_`k''
            }
            else if "`tab_x_last'"!="" {
                local tab_x_`j'_`k' `tab_x_last'
            }
            local varlab : var label `var'
            if `"`varlab'"'=="" | "`t_label'"!="" local varlab `var'
            local tab_ti_`j'_`k' `"1 = `pos' `"`varlab'"'"'
            forv i = 1/`N' {
                if !missing(`var'[`i']) {
                    local lbl: di `:format `var'' `var'[`i']
                    local lbl `lbl'
                    local tab_`j'_`k' `"`tab_`j'_`k'' `i' = `pos' `"`lbl'"'"'
                }
            }
        }
    }
    local tab_j `j'

    // mv/uv estimates
    // NB all vectors are columns
    foreach est in mv uv {
        if "``est''"!="no`est'" {
            tempname `est'b `est'se
            if "`est'"=="mv" {
                mat `mvb' = e(b)
                mat `mvse' = e(V)
            }
            else if "`est'"=="uv" {
*                qui mvmeta_runuv
*                mat `uvb' = r(b)
*                mat `uvse' = r(V)
                mat `uvb' = e(b_uv)
                mat `uvse' = e(V_uv)
            }
            mat ``est'b' = ``est'b'[1,1..`p']'
            mat ``est'se' = vecdiag(cholesky(diag(vecdiag(``est'se'[1..`p',1..`p']))))'
            mat colnames ``est'b' = "`est'" 
            // prediction intervals
            if !mi("``est'predict'") {
                tempname `est'se2
                mat ``est'se2' = e(V)
                mat ``est'se2' = ``est'se2'[1..`p',1..`p'] + e(Sigma)
                mat ``est'se2' = vecdiag(cholesky(diag(vecdiag(``est'se2'))))'
            }
        }
    }

    // compile plot objects for diamonds
    forvalues r=1/`p' {
        local yvar = word(e(yvars),`r')
*        local ylabel : var label `yvar'
*        if mi("`ylabel'") local ylabel `yvar'
        local ylabel = word(e(ylabels),`r')
        // start with study-specific results
        if "`ll'`ul'"=="" {     // no limits on confidence intervals
            local thisplot (m(`ystub'[,`r']), se(`Sstub'[,`r']))
        }
        else if "`ll'"!="" & "`ul'"!="" {   // lower and upper limits
            local thisplot (m(`ystub'[,`r']), se(`Sstub'[,`r']) ///
                transform(* = cond(@<`ll'&@<@b,min(`ll',@b),cond(@>`ul'&@<.&@>@b,max(`ul',@b),@))))
        }
        else if "`ll'"!="" {                // lower limit only
            local thisplot (m(`ystub'[,`r']), se(`Sstub'[,`r']) ///
                transform(* = cond(@<`ll'&@<@b,min(`ll',@b),@)))
        }
        else if "`ul'"!="" {                // upper limit only
            local thisplot (m(`ystub'[,`r']), se(`Sstub'[,`r']) ///
                transform(* = cond(@>`ul'&@<.&@>@b,max(`ul',@b),@)))
        }
        // mv results
        local psty 1
        if "`mv'"!="nomv" { // diamond
            local ++psty
            local thisplot `thisplot'         ///
                (m(`mvb'[`r',]), se(`mvse'[`r',]) ms(i) transform(* = @ll))    ///
                (m(`mvb'[`r',]), se(`mvse'[`r',]) ms(i) noci offset(`diamondheight'))      ///
                (m(`mvb'[`r',]), se(`mvse'[`r',]) ms(i) transform(* = @ul))    ///
                (m(`mvb'[`r',]), se(`mvse'[`r',]) ms(i) noci offset(-`diamondheight'))     ///
                (m(`mvb'[`r',]), se(`mvse'[`r',]) ms(i) transform(* = @ll))   
            if !mi("`mvpredict'") { // prediction interval
                local thisplot `thisplot' (m(`mvb'[`r',]), se(`mvse2'[`r',]) ///
                    ms(i) psty(p`psty') `mvpredict2')
            }
        }
        // uv results
        if "`uv'"!="nouv" { // diamond
            local ++psty
            local thisplot `thisplot'         /// 
                (m(`uvb'[`r',]), se(`uvse'[`r',]) ms(i) transform(* = @ll))    ///
                (m(`uvb'[`r',]), se(`uvse'[`r',]) ms(i) noci offset(`diamondheight'))      ///
                (m(`uvb'[`r',]), se(`uvse'[`r',]) ms(i) transform(* = @ul))    ///
                (m(`uvb'[`r',]), se(`uvse'[`r',]) ms(i) noci offset(-`diamondheight'))     ///
                (m(`uvb'[`r',]), se(`uvse'[`r',]) ms(i) transform(* = @ll))    
            if !mi("`uvpredict'") { // prediction interval
                local thisplot `thisplot' (m(`uvb'[`r',]), se(`uvse2'[`r',]) ///
                    ms(i) psty(p`psty') `uvpredict2')
            }
        }
        // weights and tabulate
        forv j=1/`tab_j' {
            if `"`tab_x_`j'_`r''"'=="" continue, break
            local thisplot `thisplot' (m(`ystub'[,`r']), keep(1) noci ms(i) ///
                transform(* = `tab_x_`j'_`r'') mlabels(`tab_ti_`j'_`r'') ///
                offset(`tab_tskip_`j'') mlabgap(0) psty(p1) `tab_opts_`j'')
            local thisplot `thisplot' (m(`ystub'[,`r']), noci ms(i) ///
                transform(* = `tab_x_`j'_`r'') mlabels(`tab_`j'_`r'') ///
                mlabgap(0) psty(p1) `tab_opts_`j'')
        }
        local thisplot `thisplot', bylabel(`ylabel')
        if `r'>1 local plots `plots' ||
        local plots `plots' `thisplot'
    }

    // compile addplot option for diamonds
    local start = 2
    local end = `start' + 4
    local lines
    local dpipe
    local psty 1
    if "`mv'"=="" {
        local ++psty
        local lines line @at @b if @plot>=`start' & @plot<=`end', psty(p`psty') `mvopts'
        local start = `end' + 1 + !mi("`mvpredict'")
        local end = `start' + 4
        local dpipe "||"
    }
    if "`uv'"=="" {
        local ++psty
        local lines `lines' `dpipe' line @at @b if @plot>=`start' & @plot<=`end', psty(p`psty') `uvopts'
        local dpipe "||"
    }
    
    // compile addplot option for truncated CIs
    if "`ll'"!="" {
        local lines `lines' `dpipe' pcarrow @at @b @at @ll if @plot==1&@ll==`ll', pstyle(p1) mlcol(black) lstyle(none) `ropts'
        local dpipe "||"
    }
    if "`ul'"!="" {
        local lines `lines' `dpipe' pcarrow @at @b @at @ul if @plot==1&@ul==`ul', pstyle(p1) mlcol(black) lstyle(none) `ropts'
    }

    // run coefplot
    if `p'==1 {
        if `"`byopts'"'!="" local byopts byopts(`byopts')
        local byopts legend(off) `title' `byopts'
    }
    else {
        parse_byopts `xrescale', `byopts'
        local byopts byopts(`title' `byopts')
    }
    `dicmd' quietly coefplot `plots' ||, /// 
        weight(1/@se^2) ms(S) mcol(*.6) /*mcol(gray) ciopts(lcol(black))*/ citop ///
        nooffset `byopts' `yrange' `coeflabels' `coefplot_options' addplot(`lines') ///
        nodraw name(`name')
    if `"`r(graph)'"'=="" {
        exit // no graph produced
    }

    // get name of graph
    if `"`name'"'=="" local grname Graph
    else {
        gettoken grname : name, parse(" ,")
    }
    
    // add lines at mv/uv estimates
    local psty 2
    if "`uvline'"!="" { // uvline first so that mvline is upfront in case of overlap
        if "`mv'"=="" {
            local ++psty
        }
        local uvline2 lstyle(p`psty') lp(dash) `uvline2'
        _parse combop uvline2 : uvline2, option(LSTYle) rightmost opsin
        _parse combop uvline2 : uvline2, option(LPattern) rightmost opsin
        forvalues r = 1/`p' {
            local xval = `uvb'[`r',1]
            if !mi("`eform'") local xval = exp(`xval')
            if `p'==1 local graph_i
            else      local graph_i ".graphs[`r']"
            `dicmd' .`grname'`graph_i'.parse , xline(`xval', `uvline2') norescaling
        }
        local --psty
    }
    if "`mvline'"!="" {
        local mvline2 lstyle(p`psty') lp(dash) `mvline2'
        _parse combop mvline2 : mvline2, option(LSTYle) rightmost opsin
        _parse combop mvline2 : mvline2, option(LPattern) rightmost opsin
        forvalues r = 1/`p' {
            local xval = `mvb'[`r',1]
            if !mi("`eform'") local xval = exp(`xval')
            if `p'==1 local graph_i
            else      local graph_i ".graphs[`r']"
            `dicmd' .`grname'`graph_i'.parse , xline(`xval', `mvline2') norescaling
        }
    }
    
    // display graph
    if "`nodraw'"=="" {
        graph display `grname'
    }
end

program parse_mvuvopts
    syntax anything [, Label(str) LIne LIne2(str) Predict Predict2(str) * ]
    c_local `anything'label `"`label'"'
    if `"`line2'"'!="" local line line
    c_local `anything'line  `line'
    c_local `anything'line2 `line2'
    if `"`predict2'"'!="" {
        local predict predict
        parse_predict2, `predict2'
    }
    c_local `anything'predict  `predict'
    c_local `anything'predict2 `predict2'
    c_local `anything'opts `options'
end
program parse_predict2
    syntax [, df(passthru) Levels(passthru) * ]
    if `"`options'"'!="" {
        local options ciopts(`options')
    }
    c_local predict2 `df' `levels' `options'
end

program parse_range
    syntax anything [, * ]
    capt numlist `"`anything'"', missingokay min(2) max(2)
    if _rc {
        di as err "invalid range()"
        exit 198
    }
    local ll: word 1 of `r(numlist)'
    local ul: word 2 of `r(numlist)'
    if `ll'>=. local ll
    if `ul'>=. local ul
    c_local ll `ll'
    c_local ul `ul'
    c_local ropts `options'
end

program parse_weights
    syntax [, Xpos(str) Title(str) TSkip(real 0.5) Alignment(str) Format(str) * ]
    if `"`title'"'==""     local title "Weight"
    parse_align, `alignment'
    if `"`format'"'==""    local format %6.1f
    c_local w_xpos   `"`xpos'"'
    c_local w_title  `"`title'"'
    c_local w_tskip  `"`tskip'"'
    c_local w_align  `"`alignment'"'
    c_local w_format `"`format'"'
    c_local w_opts   `options'
end
program parse_tabulate
    syntax varlist [, Xpos(str) noLabel TSkip(real 0.5) Alignment(str) * ]
    if `"`title'"'==""     local title "Weight"
    parse_align, `alignment'
    c_local t_vars  `varlist'
    c_local t_xpos   `"`xpos'"'
    c_local t_label  `label'
    c_local t_tskip  `"`tskip'"'
    c_local t_align  `"`alignment'"'
    c_local t_opts   `options'
end
program parse_align
    syntax [, Left Center Right ]
    local align `left' `center' `right'
    if `:list sizeof align'>1 {
        di as err "alignment(): only one of left, center, or right allowed"
        exit 198
    }
    c_local alignment `align'
end

program parse_byopts 
    syntax [anything] [, XRescale IMargin(passthru) LEGend(passthru) ///
        Rows(passthru) Cols(passthru) * ]
    if "`xrescale'"==""     local xrescale `anything'
    if `"`imargin'"'==""    local imargin  imargin(medium)
    if `"`legend'"'==""     local legend   legend(off)
    if `"`rows'`cols'"'=="" local rows     rows(1)
    c_local byopts `xrescale' `imargin' `legend' `rows' `cols' `options'
end


*=========================== END OF MVMETA_FOREST PROGRAM ===========================

