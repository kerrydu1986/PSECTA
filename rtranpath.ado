*!version 2.0
*2016-11-01
*By Kerry Du, kerrydu@sdu.edu.cn
capture program drop rtranpath
program define rtranpath, rclass
    version 12.1 
	syntax varname, id(varname) time(varname) Over(varname) Against(varname) [Gen(str) lopt(str) gopt(str)] 
	
	local cmdline `0'
	preserve
	tempvar hi hi2 him temp1 temp2 over2
	qui gen `hi'=.
	qui gen `hi2'=.
	qui gen `him'=.
	qui su `over'
	if (`r(N)'==0) qui gen `over2'=`over'
	else qui gen `over2'=string(`over')
	qui levelsof `over2', local(level) clean

	tempname nlopt
	if ("`lopt'"!=""){
		mata: lineopt=tokens(st_local("lopt"),";")
		mata: lineopt=lineopt[mm_which(lineopt:!=";")]
		mata: st_numscalar("`nlopt'",length(lineopt))
		
	}
	else {
		scalar `nlopt'=0
	}
	

		
		local t=1
		qui sort `over2' `id' `time'
		foreach j of local level {
		    local lname "`j'"
			local legend `legend' label(`t' `lname')
			
			
			cap drop `temp1'
			qui bys `time': egen `temp1'=mean(`varlist') if `over2'=="`j'" | `against'==1
			qui replace `him'=`temp1'  if `over2'=="`j'" | `against'==1
			qui replace `hi'=`varlist'/`him' if `over2'=="`j'" | `against'==1
			cap drop `temp2'
			qui bys `time': egen `temp2'=mean(`hi') if `over2'=="`j'" & `against'==0
			qui replace `hi2'=`temp2' if `over2'=="`j'"


			
			if ("lopt"=="" | `t'>`nlopt') {
			
				local gr `gr' (line `hi2' `time' if `over2' == "`j'")
				local t=`t'+1
				continue
			}

			mata: st_local("use`t'",lineopt[1,`t'])
			if ("`use`t''"!="-"){
				local gr `gr' (line `hi2' `time' if `over2' == "`j'",`use`t'')
			 }
			 else{
			 	local gr `gr' (line `hi2' `time' if `over2' == "`j'")

			 }
			 
			local t=`t'+1
		 }
			

	
    sort `over'  `id'  `time'
	qui putmata xx=(`hi2'), replace

	qui drop if `against'==1

    qui duplicates drop `over' `time', force
	
	if ("`gopt'"==""){
	
	   local gopt ytitle("Relative Transition Parameter") xtitle("`time'") ///
				xscale(titlegap(2)) yscale(titlegap(2))legend(`legend' pos(3) col(1))
	}
	if (strpos("`gopt'","xtitle")==0){
	    local gopt `gopt' xtitle("`time'") xscale(titlegap(2))
	}
	if (strpos("`gopt'","ytitle")==0){
	    local gopt `gopt' ytitle("Relative Transition Parameter") yscale(titlegap(2))
	}
	if (strpos("`gopt'","legend")==0){
	    local gopt `gopt' legend(`legend' pos(3) col(1))
	}
	
	
	graph twoway `gr', `gopt'

	restore
	if ("`gen'"!=""){
		local genstr `gen'
		gettoken gname gstyle: genstr
		sort `over'  `id'  `time'
	   qui getmata (`gname')=xx, `gstyle'

	}

		return local cmd "rtranpath"
		return local varlist `varlist'
		return local cmdline rtranpath `cmdline'

	end
	
