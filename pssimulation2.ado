*2017-6-3
program define pssimulation2, rclass

version 14.2
syntax ,Sigma(str) Rho(str) alpha(str)[delta(real 1) delta2(real 2) nid(integer 1) nid2(integer 1) Periods(integer 10) ]

drop _all
qui set obs `=`nid'+`nid2''

//tempvar id time X X1 d1 d2 si ri Y club flag theta
tempvar id time X X1 d1 d2 si ri Y club theta club2 ai
qui gen `id'=_n
qui gen `si'=`sigma'
qui gen `ri'=`rho'
qui gen `d1'=0
qui gen `d2'=0
qui gen `theta'=`delta' if _n<=`nid'
qui replace `theta'=`delta2' if _n>`nid'
qui gen `ai'=`alpha'
qui gen `X1'=`theta'+`si'/log(2)/(1^`ai')*rnormal()
tempname t1 N1 N2
qui putmata Y=`X1', replace
mata: YY=Y
forvalues t=2/`periods' {
tempvar X`t' 
scalar `t1'=`t'-1
qui replace `d2'=`ri'*`d1'+`si'/log(`t'+1)/(`t'^`ai')*rnormal()
qui replace `d1'=`d2'
qui gen `X`t''=`theta'+`d2'
qui putmata Y=`X`t'', replace

mata: YY=YY \ Y

}

qui keep `id'
qui expand `periods'
qui bys `id': gen `time'=_n
qui sort `time' `id'
qui getmata `Y'=YY, replace 
qui drop if `Y'<0
qui xtset `id' `time'
qui xtbalance, range(1 `periods')
//qui gen int `flag'=1 if `id'<=`nid'
qui psecta `Y', gen(`club')
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
tempname f1 f2
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


