*!version 2.0
*2016-11-01
*By Kerry Du, kerrydu@sdu.edu.cn
	capture program drop tranpath
    program define tranpath, rclass
    version 12.1 
	syntax varname [if] [in], id(varname) time(varname) [Gen(str) lopt(str) gopt(str)]
	
   
	local cmdline `0'
	if ("`gopt'"==""){
	
	   local gopt ytitle("Relative Transition Parameter") xtitle("`time'") ///
				xscale(titlegap(2)) yscale(titlegap(2))legend( pos(3) col(1))
	}
	if (strpos("`gopt'","xtitle")==0){
	    local gopt `gopt' xtitle("`time'") xscale(titlegap(2))
	}
	if (strpos("`gopt'","ytitle")==0){
	    local gopt `gopt' ytitle("Relative Transition Parameter") yscale(titlegap(2))
	}
	if (strpos("`gopt'","legend")==0){
	    local gopt `gopt' legend( pos(3) col(1))
	}

	tempname nlopt
	if ("`lopt'"!=""){
		mata: lineopt=tokens(st_local("lopt"),";")
		mata: lineopt=lineopt[mm_which(lineopt:!=";")]
		mata: st_numscalar("`nlopt'",length(lineopt))
		
	}
	else {
		scalar `nlopt'=0
	}



	marksample touse
	tempvar myid
	gen `myid'=_n
	preserve 
	qui keep if `touse'
	tempvar hi him id2 _order
	qui sort `id' `time'

	qui bys `time': egen `him'=mean(`varlist')
	
	qui gen `hi'=`varlist'/`him'
	qui putmata xx=(`hi'), replace
	qui putmata myid=(`myid'), replace
  
	
	sort `time' `hi'
	bys `time': gen `_order'=_n
	
	
	qui tab `id', nofreq
	
	if (`r(r)'<=10){
	  qui separate `varlist', by(`id') veryshortlabel 
		  local yvars `r(varlist)' 
		  if ("`lopt'"==""){
			line `yvars' `time', `gopt'
		 }
		 else {
		 	local j=1

		 	foreach k of local yvars {
		 		if (`j'<=`nlopt'){
		 			mata: st_local("use`j'",lineopt[1,`j'])
		 			if ("`use`j''"!="-"){
		 				
		 				local gr `gr' (line `k' `time',`use`j'')
		 				local j=`j'+1
		 				continue
		 				} 
		 		}
		 		

		 			local gr `gr' (line `k' `time')


		 		local j=`j'+1

		 	}

			graph twoway `gr' , `gopt'
		 
		 }

		  restore
		  if ("`gen'"!="") {
		  	local genstr `gen'
		  	gettoken gname gstyle: genstr
		  	qui getmata (`gname')=xx,  id(`myid'=myid)  `gstyle'
		  }
		  exit
	}
	
	
	qui su `id'
	
	if (`r(N)'==0) {
	
	   qui gen `id2'=`id'
	   }
	 else{
	 
	   qui gen `id2'=string(`id')
	 }
	 
		
	gsort `time' `_order'
	qui gen f1min=1 if `id'==`id'[1]
	local pos12=`hi'[1]
	local pos11=`time'[1]+1
	local c1 =`id'[1]
	gsort -`time' `_order'
	qui gen f2min=1 if `id'==`id'[1]
	local pos22=`hi'[1]
	local pos21=`time'[1]-1
	local c2 =`id'[1]
	gsort `time' -`_order'
	qui gen f1max=1 if `id'==`id'[1]
	local pos32=`hi'[1]
	local pos31=`time'[1]+1
	local c3 =`id'[1]
	gsort -`time' -`_order'
	qui gen f2max=1 if `id'==`id'[1]
	local pos42=`hi'[1]
	local pos41=`time'[1]-1
	local c4= `id'[1]
	
	local minmax f1min f2min f1max  f2max

   

	if ("`lopt'"==""){
		local middle "col(gs5)"
	}
	else {
		mata: st_local("middle",lineopt[1,1])
		if ("`middle'"=="-") local middle "col(gs5)"
	}




	local colour red blue red blue  

	

	
	qui levelsof `id2', local(level) clean
	
	
	foreach k of local level { 
	        
			local gr `gr' (line `hi' `time' if `id2' == "`k'", `middle')
			} 
					

	
	local j=2
	foreach k of local minmax {
		    local s=`j'-1 
		    gettoken usc colour: colour

		    if (`j'<=`nlopt') {
		    	mata: st_local("use`j'",lineopt[1,`j'])
		    	
		    	if ("`use`j''"!="-") {
		    		local gr `gr' (line `hi' `time' if `k'==1, `use`j'' text(`pos`s'2'  `pos`s'1' "`c`s''"))
		    		local j=`j'+1
		    		continue
		    	}

		    }
		    
		    	
		    local gr `gr' (line `hi' `time' if `k'==1, col(`usc') lwidth(medthick) text(`pos`s'2'  `pos`s'1' "`c`s''"))

			local j=`j'+1
		}
			
	

	  graph twoway `gr' , `gopt' legend(off)
	 
	 
	
	restore
		if ("`gen'"!="") {
		  	local genstr `gen'
		  	gettoken gname gstyle: genstr
		  	qui getmata (`gname')=xx,  id(`myid'=myid)  `gstyle'
		  }

	return local cmd "rtranpath"
	return local varlist `varlist'
	return local cmdline rtranpath `cmdline'

end



