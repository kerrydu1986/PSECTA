*! Version 2.2 
* Get the trend and cyclical components using filters for panel data
* By Kerui Du, kerrydu@sdu.edu.cn
* 23Jul 2017, use _xt 
* 16May 2017, use xtset command
* 14Jun 2017
* 16Jun 2017
* 30Jun 2017
capture program drop  pfilter
program define pfilter,rclass prop(xt)
    version 12.1

syntax varname,  method(str) [trend(str) cyc(str) *]
	
	local cmdline `0'
	
	_xt, trequired 
	local ivar=r(ivar)
	local tvar=r(tvar)
	//_xt, i(`i') t(`t') trequired
	//local ivar "`r(ivar)'"
	//local tvar "`r(tvar)'"

	sort `ivar' `tvar'
	
	qui levelsof `ivar', local(unqid) clean
	

	mata: tre=J(0,1,.)
	mata: cyc=J(0,1,.)

    tempvar temp1 temp2 
	foreach j of local unqid{

	    preserve
	    qui keep if `ivar'==`j'
	    sort `tvar'
	    cap drop `temp1'
	    cap drop `temp2'
		qui tsfilter `method' `temp1' = `varlist' , trend(`temp2') `options'
		qui putmata xtrend=(`temp2') ,replace
		qui putmata xcyc=(`temp1'),replace
		mata: tre= tre \ xtrend
		mata: cyc=cyc \ xcyc
		restore
		*continue,break
		

	}

	sort `ivar' `tvar'
	if ("`trend'"!="")  {
		qui getmata (`trend')=tre
		//disp "A new variable is generated to store the trend component." 
	}
	if ("`cyc'"!="") {
		qui getmata (`cyc')=cyc
		//disp "A new variable is generated to store the cyclical component." 
	}
	//disp "Done!"
	return local cmd "pfilter"
	return local varlist `varlist'
	return local cmdline pfilter `cmdline'

	end





 
