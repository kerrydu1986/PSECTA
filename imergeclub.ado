*! Version 4.1
*revised at 2017-5-17 
*revised at 2017-6-2 
*By Kerui Du, kerrydu@sdu.edu.cn

capture program drop imergeclub
program define imergeclub, eclass prop(xt)
	syntax varname, ///
	club(varname) kq(numlist max=1) [name(varname str) Gen(str) IMORE MDiv NOMata NOPRTlogtreg]

    local cmdline `0'
 	_xt, trequired 
	local id=r(ivar)
	local time=r(tvar)
    //qui xtset
	//local id `r(panelvar)'
	//local time `r(timevar)'
    if ("`noprtlogtreg'"!="") local prt="qui"
	tempvar finalclub tempid
	qui gen `finalclub'=`club'

	/*
	if ("`name'"==""){
		qui gen `tempid'=string(`id')
	}
	else {
		qui gen `tempid'=`name'

	}
	*/

	if ("`name'"==""){
		qui gen `tempid'=string(`id')
	}
	else {
		cap confirm numeric var `name'
		if _rc==0 {
			qui gen `tempid'=string(`name')
		}
		else {
			qui gen `tempid'=`name'
		}

	}

	

	if ("`imore'"==""){
		
		icheckmerge `varlist', id(`id') time(`time') kq(`kq') club(`finalclub') `mdiv' `nomata'	

	}
	else {
		   local _mergeclub=1

			while (`_mergeclub'==1) {

				icheckmerge `varlist', id(`id') time(`time') kq(`kq') club(`finalclub') `mdiv' `nomata'
				
				local _mergeclub=e(_mergeclub)
			}
	 }


	 qui tab `finalclub', nofreq
	 local nclub = r(r)

	if ("`gen'"!=""){
		qui gen `gen'=`finalclub'
		}

     //exit without displaying regression when no clubs can be merged.
     tempname beta tvalue
	 qui tab `club', nofreq
	 local onclub=r(r)
	 if (`nclub'==`onclub'){
	 	//disp _n as red _skip(5) "No clubs can be merged!"
	 	disp _n as green _skip(5) "No clubs can be merged!"
	 	`prt' scheckmerge `varlist', kq(`kq') club(`finalclub') `mdiv' `nomata'
	 	mat `beta'=e(bm)
	 	mat `tvalue'=e(tm)
		ereturn scalar nclub=`nclub' 
		ereturn matrix bm=`beta'
		ereturn matrix tm=`tvalue'
		ereturn local cmd="imergeclub"
		ereturn local varlist `varlist'
		ereturn local cmdline imergeclub `cmdline'
		exit

	 }
	

     disp as green "xxxxxxxxxxxxxxxxxxxxxxxxxx Final Club classifications xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	mat `beta'=J(1,`nclub',.)
	mat `tvalue'=J(1,`nclub',.)
	//dis _n
	forvalues j=1/`nclub' {
		
		local cnames `cnames' " Club`j'"
		qui tab `id' if `finalclub'==`j', nofreq
		local nm=r(r)
		//disp _n
		disp as green "------------------------------- Club `j' :(`nm')-------------------------------"
		qui putmata txt=(`tempid') if `finalclub'==`j'& `time'==`time'[1], replace
		mata: _prttext(txt',60)

	    disp as green "--------------------------------------------------------------------------"

		`prt' logtreg  `varlist' if `finalclub'==`j' , kq(`kq') `nomata'
		
		mat `beta'[1,`j']=e(beta)
		mat `tvalue'[1,`j']=e(tstat)
		
	}

	qui count if missing(`finalclub')
	if (`r(N)'>0) {
		qui tab `id' if missing(`finalclub'), nofreq
		local nm=r(r)
		//disp _n
		disp as green "----------------------- Not convergent Group `=`nclub'+1' :(`nm') ----------------------"
		qui levelsof `id' if missing(`finalclub'), local(noncon) clean
		qui putmata txt=(`tempid') if missing(`finalclub') & `time'==`time'[1], replace
		mata: _prttext(txt',60)
		disp as green "--------------------------------------------------------------------------"
		if (`:word count `noncon''>=2) {
			`prt' logtreg `varlist' if missing(`finalclub'),  kq(`kq') `nomata'
			mat `beta'=(`beta',e(beta))
		    mat `tvalue'=(`tvalue',e(tstat))
		    local cnames `cnames' "Group`=`nclub'+1'"	
		}		
			
		


	}

     disp as green "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	mat colnames `beta' = `cnames'
	mat rownames `beta' = "Coeff"
	mat colnames `tvalue' = `cnames'
	mat rownames `tvalue' = "T-stat"

	ereturn scalar nclub=`nclub' 
   
	ereturn matrix bm=`beta'
	ereturn matrix tm=`tvalue'
	ereturn local cmd="imergeclub"
	ereturn local varlist `varlist'
	ereturn local cmdline imergeclub `cmdline'




 end



//////////////////////////////////////////////////////////////////
capture program drop icheckmerge
program define icheckmerge,eclass
	syntax varlist, ///
	id(varname) time(varname) club(varname) kq(numlist) [ MDiv nomata]

	qui sort `club' `id' `time'
	qui su `club'
	local nclub=r(max)
	tempvar  newclub
	qui gen `newclub'=1 if `club'==1
	tempname tt

    local j=1
   
		forvalues k=1/`=`nclub'-1' {
			qui logtreg `varlist' if `newclub'==`j' | `club'==`k'+1, kq(`kq') `nomata'
			scalar `tt'=e(tstat)
			*disp tt
			if (`tt'>-1.65) {
				qui replace `newclub'=`j' if `club'==`k'+1
			}
			else{
				local j=`j'+1
				qui replace `newclub'=`j' if `club'==`k'+1
			}

		}
		//disp `j'
		if ("`mdiv'"!=""){

			qui logtreg `varlist' if `newclub'==`j' | missing(`club'), kq(`kq') `nomata'
		 	scalar `tt'=e(tstat)
			if `tt'>-1.65 {
				qui replace `newclub'=`j' if missing(`club')
			 }


		}

		qui su `newclub'
		local nnewclub=r(max)
		ereturn scalar _mergeclub=(`nnewclub'<`nclub')

		qui replace `club'=`newclub'


 end 
