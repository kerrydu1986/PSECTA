* revised at 2017-10-27
* revised at 2017-6-18
* revised at 2017-6-1
* revised at 2017-5-28
* By Kerui Du, kerrydu@sdu.edu.cn
capture program drop psecta
program define psecta, eclass prop(xt)
	version 12.1 
	syntax varname, ///
	[name(varname) Gen(str) kq(real 0.3) cr(real 0) incr(real 0.05) maxcr(real 50)  Adjust fr(real 0) NOMata NOPRTlogtreg]
	
	local cmdline `0'

	if (`kq'>=1 | `kq'<0 ) {
		disp as red "kq should be set between 0 and 1."
		error 121
	}

	if (`fr'<0 | `fr'>1){
		disp as red "fr should be set between 0 and 1."
		error 121
	}

	_xt, trequired 
	local id=r(ivar)
	local time=r(tvar)

	
	if ("`noprtlogtreg'"!="") local prt="qui"
	qui tab `id', nofreq
	local Ncross=r(r)
	if (`Ncross'==1){
	   disp as red "Error:The number of individuals should be greater than one!"
	   error 2000
	   //exit
	}

	tempvar _club tempid

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


	local vgetcluster getcluster

	if ("`nomata'"!=""){
		local vgetcluster getclusterstata
	}

	//disp "`vgetcluster'"
	tempname rclub
	 `vgetcluster' `varlist', id(`id') time(`time') gen(`_club') kq(`kq') fr(`fr') cr(`cr') incr(`incr') maxcr(`maxcr')  `adjust'
	
	mat `rclub'=e(club)
	qui tab `_club', nofreq
	local nclub = r(r)

	qui count if missing(`_club')
	local flag=r(N)
	if `flag'==_N {
	        
			//disp as red "There are no convergent subgroups."
		    if ("`gen'"!=""){
		    	qui gen `gen'=`_club'
		      }
			  
			ereturn scalar nclub=`nclub' 
			ereturn matrix club=`rclub'
			mat tmp=J(1,1,.)
			ereturn matrix bm= tmp
			mat tmp=J(1,1,.)
			ereturn matrix tm= tmp
			ereturn local cmd="psecta"
			ereturn local varlist `varlist'
			ereturn local cmdline psecta `cmdline'
			
		    exit
	}


	//qui tab `_club', nofreq
	//local nclub = r(r)
	tempname beta tvalue
	mat `beta'=J(1,`nclub',.)
	mat `tvalue'=J(1,`nclub',.)

	
	disp _n

	disp as green "xxxxxxxxxxxxxxxxxxxxxxxxxxxx Club classifications xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"


	forvalues j=1/`nclub' {
		local cnames `cnames' " Club`j'"
	    qui tab `id' if `_club'==`j', nofreq
		local nm=r(r)
		//disp _n
		disp as green "------------------------------- Club `j' :(`nm')-------------------------------"
		
		qui putmata txt=(`tempid') if `_club'==`j'& `time'==`time'[1], replace
		mata: _prttext(txt',62)

	    disp as green "--------------------------------------------------------------------------"
		//disp _n
	    
		`prt' logtreg `varlist' if `_club'==`j',  kq(`kq') `nomata'
		mat `beta'[1,`j']=e(beta)
		mat `tvalue'[1,`j']=e(tstat)
		//sleep 500

	}
	//sleep 500
	if `flag'>0 {
		qui tab `id' if missing(`_club'), nofreq
		local nm=r(r)
		//disp _n
		disp as green "----------------------- Not convergent Group `=`nclub'+1' :(`nm') ----------------------"
		qui levelsof `id' if missing(`_club'), local(noncon) clean
		qui putmata txt=(`tempid') if missing(`_club') & `time'==`time'[1], replace
		mata: _prttext(txt',62)
		disp as green "--------------------------------------------------------------------------"
		if `:word count `noncon''>=2 {
				`prt' logtreg `varlist' if missing(`_club'),  kq(`kq') `nomata'
				mat `beta'=(`beta',e(beta))
		        mat `tvalue'=(`tvalue',e(tstat))
		        local cnames `cnames' "Group`=`nclub'+1'"	
			}
			
    }

    disp "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    if ("`gen'"!=""){
    	qui gen `gen'=`_club'
    }

	ereturn scalar nclub=`nclub'
    ereturn matrix club=`rclub'
    mat colnames `beta' = `cnames'
	mat rownames `beta' = "Coeff"
	mat colnames `tvalue' = `cnames'
	mat rownames `tvalue' = "T-stat"
	ereturn matrix bm=`beta'
	ereturn matrix tm=`tvalue'
    ereturn local cmd="psecta"
    ereturn local varlist `varlist'
	ereturn local cmdline psecta `cmdline'

 

 end

 
////////////////////////////////////////
**New version 2016-11-01 Afternoon
* Kerui Du, kerrydu@sdu.edu.cn

capture program drop  getcluster
program define getcluster, eclass
	version 12.1
	syntax varname, ///
	       id(varname) time(varname) ///
	       [Gen(str) kq(real 0.3) fr(real 0) cr(real 0) incr(real 0.05) maxcr(real 50) Adjust]

/*
	if ("`fr'"=="") {
		local fr=0
	}
	else{
		if (`fr'<0 | `fr'>1){
			disp as red "fr should be set between 0 and 1."
			error 121
		}

	}
*/


	if ("`adjust'"=="") {
		local adj=0
	}
	else {
	     local adj=1
	}


/*
	if ("`kq'"==""){
		local kq=0.3
	 } 
	else{
		if (`kq'>=1 | `kq'<0 ) {
		   disp as red "kq should be set between zero and one."
		   error 121
		}
	}

	
	if ("`cr'"=="") local cr=0
	//if ("`kq'"=="") local kq=0.3
	if ("`incr'"=="") local incr=0.05
	if ("`maxcr'"=="") local maxcr=50
*/


	qui tab `id', nofreq
	local N=r(r)
	qui tab `time', nofreq
	local T=r(r)
    
    //tempvar id2 
	//egen `id2'=group(`id')
	   
	tempvar _club
	qui gen `_club'=.

	//test whether it is convergent for the whole sample
	// 2017-7-3
	qui logtreg `varlist', kq(`kq') 
	if e(tstat)>-1.65 {
		qui replace `_club'=1
	}

	else {
		qui sort `time' `id'

		qui putmata vlx=(`varlist'),replace
		mata: id3=1::`N'
		mata: XX=id3,_vec2mat(vlx,`N',`T')
		qui putmata id2=(`id'),replace
		
		mata:res=_getcluster(id2,id3,XX,`cr',`kq',`adj',`incr',`maxcr',`fr',"`_club'")
		//mata: st_matrix("club",res)
		
		qui count if missing(`_club')
		local flag=r(N)
		if `flag'==_N {        
				//disp as red "There are no convergent subgroups."
			    exit
		}
		

	}


	if ("`gen'"!=""){
		qui gen `gen'=`_club'
			//disp "A new variable (`gen') is generated to store the results of clustering."

	}
	
	tempname rclub
	
	qui sort `time' `_club' `id'
	mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                mat(`rclub') 

	mat colnames `rclub' = "Club" "panel_id"
	
	//mat rownames club = `rname'

	ereturn local cmd="getcluster"
	ereturn matrix club=`rclub'
	//disp "Done!"
	
end


///////////////////////////////////////////////////////////
//use stata routines
//////////////////////////////////////////////////////////
*2016-10-26
* use findclubstata
capture program drop  getclusterstata
program define getclusterstata, eclass
	version 12.1
	syntax varname, ///
	       id(varname) time(varname) ///
	       [Gen(str) kq(real 0.3) fr(real 0) cr(real 0) incr(real 0.05) maxcr(real 50) Adjust]

/*	
    // set default parameters
	if ("`cr'"=="") local cr=0
	if ("`incr'"=="") local incr=0.05
	if ("`maxcr'"=="") local maxcr=50
    //if ("`adjust'"=="") local adjust=""
	if ("`fr'"=="") {
		local fr=0
	}
	else{
		if (`fr'<0 | `fr'>1){
			disp as red "fr should be set between 0 and 1."
			error 121
		}

	}
*/
	//tempvar id2 _club
	//
	//tempname clubmember
	//qui egen `id2'=group(`id')
	   
	tempvar _club
	qui gen `_club'=.

	qui logtreg `varlist', kq(`kq') nomata
	if e(tstat)>-1.65 {
		qui replace `_club'=1
		qui sort `time' `_club' `id'
		qui mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                mat(club) 
		mat colnames club = "Club" "panel_id"
		if ("`gen'"!="") qui gen `gen'=`_club'

		ereturn local cmd="getclusterstata"
		ereturn matrix club=club
		exit

	}


    tempname clubmember
	qui findclubstata `varlist', id(`id') time(`time') fr(`fr') cr(`cr') kq(`kq') incr(`incr') maxcr(`maxcr') `adjust'
	local flag=e(flag)
	//disp "flag=" `flag'
	if `flag'==0 {
		disp as yellow "There are no convergent subgroups."
		if ("`gen'"!="") qui gen `gen'=`_club'
		exit
	   }

	
		mat `clubmember'=e(clubmember)
		local nclub=rowsof(`clubmember')
		
		forvalues q=1/`nclub' {
		    qui replace `_club'=1 if `id'==`clubmember'[`q',1]
		   }
		
		qui levelsof `id' if missing(`_club'), local(noncon)
		    if (`:word count `noncon''<2) {
			    qui sort `time' `_club' `id'
				qui mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                 mat(club) 
				mat colnames club = "Club" "panel_id"

				ereturn local cmd="getclusterstata"
				ereturn matrix club=club
				if ("`gen'"!="") qui gen `gen'=`_club'
				exit
			 }
		
		
		qui logtreg `varlist' if missing(`_club'), kq(`kq') nomata
		local tstat=e(tstat)
		
		if (`tstat'>-1.65) {
		   qui replace `_club'=2 if missing(`_club')
		   qui sort `time' `_club' `id'
		   qui mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                     mat(club) 
		   mat colnames club = "Club" "panel_id"

		   ereturn local cmd="getclusterstata"
		   ereturn matrix club=club
		   if ("`gen'"!="") qui gen `gen'=`_club'
		   exit
		  
		     }

		else {
			local eflag=1
			local jt=2
			while (`eflag'==1) {
					qui findclubstata `varlist' if missing(`_club'), id(`id') time(`time') fr(`fr') cr(`cr') kq(`kq') incr(`incr') maxcr(`maxcr') `adjust'
					local eflag=e(flag)
					//disp `eflag'
					if (`eflag'==0) {
					    qui sort `time' `_club' `id'
						qui mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                     mat(club) 
						mat colnames club = "Club" "panel_id"
						

						ereturn local cmd="getclusterstata"
						ereturn matrix club=club
						if ("`gen'"!="") qui gen `gen'=`_club'
						exit
						}

					else{

					   *local clubmember=e(club)
					   
			           *qui replace `_club'=`jt' if inlist(`id',`clubmember')
						mat `clubmember'=e(clubmember)
						local nclub=rowsof(`clubmember')
						forvalues q=1/`nclub' {
							qui replace `_club'=`jt' if `id'==`clubmember'[`q',1]
						   }
						 
					   qui levelsof `id' if missing(`_club'), local(noncon)
					   if (`:word count `noncon''<2) {
					       qui sort `time' `_club' `id'
					   	   qui mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                     mat(club) 
						   mat colnames club = "Club" "panel_id"

						   ereturn local cmd="getclusterstata"
						   ereturn matrix club=club
						   if ("`gen'"!="") qui gen `gen'=`_club'
					       exit
					     }
		
					
			            
			           qui logtreg `varlist' if missing(`_club'), kq(`kq') nomata

			           local tstat=e(tstat)
		
						if (`tstat'>-1.65) {
						   qui replace `_club'=`jt'+1 if missing(`_club')
						   qui sort `time' `_club' `id'
						   qui mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                     mat(club) 
						   mat colnames club = "Club" "panel_id"
						   ereturn local cmd="getclusterstata"
						   ereturn matrix club=club
						   if ("`gen'"!="") qui gen `gen'=`_club'
						   exit
						   }
					    
			        local jt=`jt'+1
			        }
			   }
			  qui sort `time' `_club' `id'
			  qui mkmat `_club' `id' if `time'==`time'[1]& !missing(`_club' ), ///
			                mat(club) 
			  mat colnames club = "Club" "panel_id"
			  if ("`gen'"!="") qui gen `gen'=`_club'

			  ereturn local cmd="getclusterstata"
			  ereturn matrix club=club
			  
			 // disp "Done!"
		

	
	
	end
//////////////////////////////////////////////////////////////////////////////////

*version 4.4
*! coded in stata 12.1, change the arguement of inlist to meet large number of individuals
*For inlist, the number of arguments is between 2 and 255 for reals and between 2 and 10 for strings.
*This version use anymatch instead
 
* 2016-11-10
**The code is designed to find the initial convergence club 
* by Kerui Du, kerrydu@sdu.edu.cn


capture program drop  findclubstata
program define findclubstata,eclass
 version 12.1
	syntax varname [if] [in], ///
	id(varname) time(varname) [kq(real 0.3) fr(real 0) cr(real 0) incr(real 0.05) maxcr(real 50) Adjust]

  /*  
    // set default parameters
	if ("`cr'"=="") local cr=0
	if ("`incr'"=="") local incr=0.05
	if ("`maxcr'"=="") local maxcr=50
    //if ("`adjust'"=="") local adjust=""
	if ("`fr'"=="") {
		local fr=0
	}
	else{
		if (`fr'<0 | `fr'>1){
			disp as red "fr should be set between 0 and 1."
			error 121
		}

	}	
	*/    

	marksample touse
	preserve
	qui keep if `touse'


	tempvar _order inarg
	tempname tt tmax getid idts


    // step 1 corss-section sorting
	/*Cross-section [decreasing] sorting based on the final period T*/
	if (`fr'==0){
	    gsort -`time' -`varlist'  
		qui gen `_order'=_n 
	    sort `id' `time'
		qui bys `id': replace `_order'=`_order'[_N]
	    *tab `_order'
		qui su `_order'
		local mid=r(max)

		sort `_order' `id' `time'		

	}
	else {
		tempvar vsort tperiod
		qui tab `time', nofreq
		local nperiod=r(r)
		local nperiod=int((1-`fr')*`nperiod')+1
		sort `id' `time'
		qui bys `id': gen `tperiod'=_n
		qui bys `id': egen `vsort'=mean(`varlist') if `tperiod'>=`nperiod'
		gsort -`time' -`vsort'  
		qui gen `_order'=_n 
	    sort `id' `time'
		qui bys `id': replace `_order'=`_order'[_N]
	    *tab `_order'
		qui su `_order'
		local mid=r(max)

		sort `_order' `id' `time'	
	}

	*list `id' `_order' if `time'==1
	//
  

    // step 2 Form a core group

    // step 2.1 find the first two successive countries with tt>-1.65
	local k=1
	scalar `tt'=-100 
	
	while (`tt'<=-1.65 &`k'<`mid') {
			qui logtreg `varlist' if `_order'==`k'| `_order'==`k'+1, kq(`kq') nomata
			scalar `tt'=e(tstat)
			local k=`k'+1
	
		}

	//test	
    /*
	scalar `tt'=-100
	local k=1000
	*/
	// If the above loop exits with failing to find the first two successive countries with tt>-1.65
	// No convergent groups exist, program ends.

	if (`k'>=`mid'&`tt'<=-1.65){
			//disp as red "Exit: No convergent groups are found."
			ereturn scalar flag=0   // record whether convergent club exists

			restore
			exit 
		}

    // If the first two successive countries with tt>-1.65 are found, next to step 2.2
	// step 2.2 increase k to find the core group	
	*else {
	
			local j=`k'+1
			local idlist `=`k'-1' `k'
			scalar `tmax'=`tt' 
			local tmaxindex `=`k'-1' `k'  // record k for which yields the hihgest value of tt
			while (`j'<=`mid' & `tt'>-1.65){


				local idlist `idlist' `j'
				qui cap drop `inarg'
				qui egen `inarg'=anymatch(`_order'), values(`idlist')
			
				qui logtreg `varlist' if `inarg'==1, kq(`kq') nomata
				scalar `tt'=e(tstat)
			    
			    // record the j when the maixmum t statistic is obtainded
				if `tmax'<=`tt'{
						scalar `tmax'=`tt'
						local tmaxindex `idlist'
					}
				local j=`j'+1
				}
				
	//
	// step 3 extend the core group to an initial convergence club

	    //step 3.1 Form a complementary core group	
	
		
			qui cap drop `inarg'
			qui egen `inarg'=anymatch(`_order'), values(`tmaxindex')
			qui levelsof `_order' if `inarg'==0, local(cin1) clean  // record the complementary core group
			
 		
        // step 3.2 add one country at a time 
			local initialclub `tmaxindex'
			
			foreach i of local cin1{


			    local inarg2 `tmaxindex' `i'
				qui cap drop `inarg'
				qui egen `inarg'=anymatch(`_order'), values(`inarg2')
				
				qui logtreg `varlist' if `inarg'==1, kq(`kq') nomata
				
				scalar `tt'=e(tstat)


				//record i such that the t statistic is greater than cr
				if `tt'>`cr' {
					
					local initialclub `initialclub' `i'
					}
				}
							
				//disp "`initialclub'"
				//disp `:word count `initialclub''
   
	    // step  3.3 check if the convergence hypothesis holds for the obtainded group in step 3.2
		
		    qui cap drop `inarg'
			qui egen `inarg'=anymatch(`_order'), values(`initialclub')
			qui logtreg `varlist' if `inarg'==1, kq(`kq') nomata
			scalar `tt'=e(tstat)

			// check whether initialclub=tmaxindex
			local ifempty: list initialclub-tmaxindex


			if (`tt'<=-1.65 & "`ifempty'"!="") {
				if "`adjust'"=="" { // use the original method of PS-2007
					while (`tt'<=-1.65 & `cr'<`maxcr') {
						// set the maximum value of cr to ensure the exit of the loops
						local cr=`cr'+`incr' // raise cr, then repeat step 3.2
						local initialclub `tmaxindex'
					    foreach i of local cin1{
							local inarg2 `tmaxindex' `i'
							qui cap drop `inarg'
						    qui egen `inarg'=anymatch(`_order'), values(`inarg2')
						    qui logtreg `varlist' if `inarg'==1, kq(`kq') nomata
						    scalar `tt'=e(tstat)
						    if `tt'>`cr' {
							   local initialclub `initialclub' `i'
							}
						}
						qui cap drop `inarg'
						qui egen `inarg'=anymatch(`_order'), values(`initialclub')
						qui logtreg `varlist' if `inarg'==1, kq(`kq') nomata
					    scalar `tt'=e(tstat)
					    


					}
					if (`tt'<=-1.65) local initialclub `tmaxindex'

				}
				else {
				// adjusted step  3.3
					local cin1: list initialclub - tmaxindex
					local initialclub `tmaxindex'
				
					while ("`cin1'"!="") {
					    local tcan
						foreach i of local cin1{
							local inarg2 `initialclub' `i'
							qui cap drop `inarg'
							qui egen `inarg'=anymatch(`_order'), values(`inarg2')
							qui logtreg `varlist' if `inarg'==1, kq(`kq') nomata
							
							local tcan `tcan' `=e(tstat)'
							}
							
						mata: tscin=-strtoreal(tokens(st_local("tcan")))',strtoreal(tokens(st_local("cin1")))'
						mata: st_numscalar("`getid'",sort(tscin,1)[1,2])
						local getid2=`getid'
						mata: st_numscalar("`idts'",-sort(tscin,1)[1,1])
						
						if (`idts'<=-1.65) {
						   continue, break
						}
						else {
						  local initialclub `initialclub' `getid2'
						  *disp "`initialclub'"
						 }
						local cin1: list cin1 - initialclub 

					 }

				 }

             }
		  

	  
			// return matrix instead
			tempname clubmem remaind
			qui cap drop `inarg'
			qui egen `inarg'=anymatch(`_order'), values(`initialclub')
			gsort -`inarg' `time' `id'
			*qui tab `id' if `inarg', nofreq
			*local nclub=r(r)
			
			mkmat `id' if (`inarg'==1  & `time'==`time'[1]), mat(`clubmem')
			//mat list clubmember
			ereturn mat clubmember=`clubmem'

			mkmat `id' if (`inarg'==0  & `time'==`time'[1]), mat(`remaind')
			ereturn mat remainder=`remaind'
			ereturn scalar flag=1



	 *}

	restore
 end
