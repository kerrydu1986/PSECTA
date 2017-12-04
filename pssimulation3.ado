*2017-6-3
program define pssimulation3, rclass

version 14.2
syntax , Periods(integer) [delta(real 1) delta2(real 1) nid(integer 1) nid2(integer 1)  alpha(real 0.3)]

drop _all
clear

mata: data= dgp(`nid',`nid2', `periods',`alpha',`delta',`delta2',y1,y2)
//mata: data
tempvar id time Y club club2

qui {
getmata (`id' `time' `Y')=data, replace
drop if `Y'<0
xtset `id' `time'
xtbalance, range(1 `periods')

}


qui psecta `Y', gen(`club')
//list `club' if `time'==1
//qui su `club'
//local nclub=r(max)
local nclub=e(nclub)
if `nclub'>1 {
   qui imergeclub `Y', kq(0.3) club(`club') gen(`club2')	
}
else {
	qui gen `club2'=`club'
}

qui drop `club'
//qui count if `club'==`flag' & `id'<=`nid'
//scalar `rt'=r(N)

tempvar flag
tempname f1 f2 N1 N2
qui drop if missing(`club2')
qui bys `club2': gen `flag'=_N if `id'<=`nid'
//qui  replace `flag'=(`flag'==`flag'[_N]) if `id'<=`nid'
gsort -`flag'
qui su `id' if `club2'==`club2'[1] & !missing(`club2')
scalar `f1'=(r(max)>`nid')

qui replace `flag'=.
qui bys `club2': replace `flag'=_N if `id'>`nid'
//qui  replace `flag'=(`flag'==`flag'[_N]) if `id'<=`nid'
gsort -`flag'
qui su `id' if `club2'==`club2'[1] & !missing(`club2')
scalar `f2'=(r(min)<=`nid')

qui count if `id'<=`nid'
scalar `N1'=r(N)
qui tab `club2' if `id'<=`nid' , matcell(A)
mata: st_numscalar("max1", max(st_matrix("A")))
mat A=0
qui count if `id'>`nid'
scalar `N2'=r(N)
qui tab `club2' if `id'>`nid' , matcell(A)
mata: st_numscalar("max2", max(st_matrix("A")))

return scalar wrongin=(`f1'|`f2')
return scalar rightin=(max1+max2)/(`N1'+`N2')
//return scalar rightin=(max1==`N1'& max2==`N2')
end


cap mata mata drop dgp()
mata:
real matrix dgp(real scalar nid,
				real scalar nid2,
				real scalar periods,
				real scalar a,
				real scalar delta,
				real scalar delta2,
				real matrix y1,
				real matrix y2)
				
	{
		 
		 si=runiform(nid,1,0.02,0.28)
		 rho=runiform(nid,1,0,0.8)
		 id=J(1,periods,1)#(1::nid)
		
		 d1=J(nid,1,0)
		 X=J(nid,periods,.)
		 et=rnormal(nid,periods,0,1)
		 X[.,1]=delta:+((si:/log(2)):/(1^a)):*et[.,1]
		 X[.,1]=X[.,1]:*y1[.,1]

		  for (i=2;i<=periods;i++) {
			  d2=rho:*d1+((si:/log(i+1)):/(i^a)):*et[.,i]
			  d1=d2
			  X[.,i]=delta:+d2
			  X[.,i]=X[.,i]:*y1[.,i]
		  }
		  
		     si=runiform(nid2,1,0.02,0.28)
			 rho=runiform(nid2,1,0,0.8)
			 id2=J(1,periods,1)#((nid2+1)::(nid2+nid))
			 d1=J(nid2,1,0)
			 X2=J(nid2,periods,0)
			 et=rnormal(nid2,periods,0,1)
			 X2[.,1]=delta2:+((si:/log(2)):/(1^a)):*et[.,1]
			 X2[.,1]=X2[.,1]:*y2[.,1]

			  for (i=2;i<=periods;i++) {
				  d2=rho:*d1+((si:/log(i+1)):/(i^a)):*et[.,i]
				  d1=d2
				  X2[.,i]=delta2:+d2
				  X2[.,i]=X2[.,i]:*y2[.,i]
			  }
			

			id=vec(id \ id2)
			time= vec(J(nid+nid2,1,1)#(1..periods))
			XX=vec(X\ X2)

			data=id,time,XX
			return(data)
		 

	}
   
   end

