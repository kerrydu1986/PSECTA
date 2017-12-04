*! 11July 2017
*By Kerui Du, kerrydu@sdu.edu.cn
capture program drop  logtreg
program define logtreg,eclass prop(xt)
    version 12.1
	syntax varname [if] [in], [kq(real 0.3) NOMata]
		
		if (`kq'>=1 | `kq'<0 ) {
			disp as red "kq should be set between zero and one."
			error 121
		}

		_xt, trequired 
		local id=r(ivar)
		local time=r(tvar)

		marksample touse, novarlist

		qui tab `id' if `touse', nofreq
		local Ncross=r(r)
		if (`Ncross'<=1){
		   disp as red "Error: The number of individuals should be greater than one!"
		   
		   error 2000
		}

        
		local cmdline `0'  

		if "`nomata'"==""{
			// using mata language


			qui sort `time' `id'
		
			qui tab `id' if `touse', nofreq
			local N=r(r)
			qui tab `time' if `touse', nofreq
			local T=r(r)
			//local Tdis=floor(`T'*`kq')
			local Tdis=round(`T'*`kq')
			qui putmata X=(`varlist') if `touse',replace
			mata: xmat=_vec2mat(X,`N',`T')
			mata: res=_reglogt(xmat,`kq')
			tempname b nreg tstat results
			mata: st_matrix("`b'",_getb(res)')
			*mata: st_matrix("V",getV(res))
			mata: st_numscalar("`nreg'",_getN(res))
			mata: st_numscalar("`tstat'",_getts(res)[1])			
		}

		// using stata routines
		else {
			preserve
			qui keep if `touse'
			tempvar hi him t Ht logt _residuals
			tempname b  tstat V  results  
			qui tab `id', nofreq
			local N=r(r)
			qui tab `time', nofreq
			local T=r(r)
			qui sort `id' `time'
			qui bys `time': egen `him'=mean(`varlist')
			qui gen `hi'=`varlist'/`him'
			qui bys `time': egen `Ht'=mean((`hi'-1)^2)
			qui duplicates drop `time',force
			//qui egen `t'=group(`time')
			sort `time'
			qui gen `t'=_n
			qui gen `logt'=ln(`t')
			qui sort `time'
			qui replace `Ht'=ln(`Ht'[1]/`Ht')-2*ln(`logt') if _n>1
		    qui su `t'
			local rn=r(max)
			//local rn=floor(`rn'*`kq')
	        local rn=round(`rn'*`kq')
			qui drop if `t'<=`rn'
			qui reg `Ht' `logt'
			mat `b'=e(b)
			local nreg=e(N)

			qui predict `_residuals', residuals
			qui su `_residuals'
			qui replace `_residuals'=`_residuals'-r(mean)
			
			*mata:b= st_matrix("`b'")
			
			mata: _stderror("`_residuals'","`logt'",st_matrix("`b'"))
			scalar `tstat'=r(tstat) //

			//restore
			ereturn clear


		}

		
        ***return and display results
		
		mat `results'=(`b'[1,1],`b'[1,1]/`tstat',`tstat')
		
		mat rownames `results' = "log(t)"
		mat colnames `results' = "Coeff" "SE" "T-stat"

		local r = rowsof(`results')-1
		local rf "--"
		forvalues i=1/`r' {
			local rf "`rf'&"
		}
		local rf "`rf'-"
		local cf "&  %10s | %12.4f & %12.4f &  %12.4f &"
		dis _n in gr "log t test:"
		matlist `results', cspec(`cf') rspec(`rf') noblank rowtitle("Variable")

		//matlist results, border(rows) rowtitle(Ht)  format(%9.3f) ///
		//        title("log-t test results:")   //noblank
		//matlist results, border(rows) rowtitle(Ht)  format(%9.3f) left(4)

		disp "The number of individuals is `N'."
		disp "The number of time periods is `T'."
		disp "The first `Tdis' periods are discarded before regression."
		
		//ereturn scalar b=b[1,1] //here is wrong
		
		ereturn scalar beta=`b'[1,1]
		ereturn scalar tstat=`tstat'
		ereturn mat res=`results'
		ereturn scalar N=`N'
		ereturn scalar T=`T'
		ereturn scalar nreg=`nreg'
		ereturn local cmd "logtreg"
		ereturn local varlist `varlist'
		ereturn local cmdline logtreg `cmdline'

	
	end
	
	

