*! Version 3.0
*revised at 2017-5-17
*revised at 2017-6-2
*30Jun 2017
capture program drop scheckmerge
program define scheckmerge, eclass prop(xt)
	version 12.1
	syntax varname, ///
	 club(varname) kq(numlist max=1) [ MDiv NOMata]

    local cmdline `0'
    //qui xtset
    //local id `r(panelvar)'
	//local time `r(timevar)'
	qui tab `club', nofreq
	local nclub=r(r)-1
    //disp "logtreg`stata'" 
    tempname beta tvalue
	mat `beta'=J(1,`nclub',.)
	mat `tvalue'=J(1,`nclub',.)
	//dis _n
	forvalues j=1/`nclub' {
		local i=`j'+1
		local cnames `cnames' " Club`j'+`i'"
		disp _n
		//disp  _s(10) as green "The log t test for " as red "Club `j'+`i'" 
		disp  _s(10) as green "The log t test for "  "  Club `j'+`i'" 
		logtreg  `varlist' if `club'==`i' | `club'==`j',kq(`kq') `nomata'
		disp "------------------------------------------------------"
		//local b=e(beta)
		//local tval=e(tstat)
		mat `beta'[1,`j']=e(beta)
		mat `tvalue'[1,`j']=e(tstat)
		
	}

    qui count if missing(`club')

	if ("`mdiv'"!="" & r(N)>0){

		local j=`i'+1
		local cnames `cnames' "Club`i'+Group `j'"
		//disp  _s(6) as green "The log t test for " as red "Club `i' + Group `j'"
		disp  _s(6) as green "The log t test for " "  Club `i' + Group `j'"
		logtreg `varlist' if `club'==`i' | missing(`club'), kq(`kq') `nomata'
		disp "------------------------------------------------------"
		//local b=e(beta)
		//local tval=e(tstat)
		mat `beta'=(`beta',e(beta))
		mat `tvalue'=(`tvalue',e(tstat))
	}

	mat colnames `beta' = `cnames'
	mat rownames `beta' = "Coeff"
	mat colnames `tvalue' = `cnames'
	mat rownames `tvalue' = "T-stat"

	
   
	ereturn matrix bm=`beta'
	ereturn matrix tm=`tvalue'
	ereturn local cmd="scheckmerge"
	ereturn local varlist `varlist'
	ereturn local cmdline scheckmerge `cmdline'




 end

 

