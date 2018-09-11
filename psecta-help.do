* psecta help
local name = "Convergence_Top10"
log using `name'.log, replace
*
import excel "top10 income wid.world data 1917-2012 stacked data.xls", sheet("Data") firstrow
encode State, gen(st)
xtset st Year
*
drop if State=="Alaska"|State=="Hawaii"
*
keep if Year >= 1986 & Year <= 2013
*
* Transition paths
*
local ll lp(solid) col(black); lp(solid) col(red) ; 
local ll `ll' lp(solid) col(blue)  ; lp(solid)  col(red);
local ll `ll' lp(solid)  col(blue) 
local gopt "title(Transition paths for US states for subsample 1986-2012)"
tranpath top10, id(State) time(Year) gen(tpaths_subsample3) lopt(`ll') gopt(`gopt')
*
* log t regression and clustering 
*
logtreg top10,  kq(0.333)
mat b=e(beta)
mat t=e(tstat)
mat result=(b \ t)
mat rownames result = "Coeff" "t-stat"
mat colnames result = "All_states"
*
psecta top10, name(State) kq(0.333) gen(club_subsmpl3)
mat b=e(bm)
mat t=e(tm)
mat result1=(b \ t)
*
* Test for club merging
*
scheckmerge top10, kq(0.333) club(club_subsmpl3) mdiv
mat b=e(bm)
mat t=e(tm)
mat result2=(b \ t)
*
imergeclub top10, name(State) kq(0.333) club(club_subsmpl3) gen(fnlclb_subsmpl3)
mat b=e(bm)
mat t=e(tm)
mat result3=(b \ t)
*
* Results output (subsample 1946-1980)
*
mat results=(result,result1,result2,result3)
logout, save(Top10_Subsample3) word replace: matlist results, border(rows) /// 
	title("Top10 Subsample 1986-2012") rowtitle("log(t)") format(%9.3f) left(4)
