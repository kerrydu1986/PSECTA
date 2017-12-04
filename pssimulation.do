
set more off
timer on 1
set seed 123
mat res111=J(4,3,.)
mat res112=J(4,3,.)
local p=0

foreach j in 20 40 60 {
   local p=`p'+1
   local q=0
   foreach i in 20 40 60 100{
     local q=`q'+1
     clear
     qui simulate ri=r(rightin) wi=r(wrongin), reps(1000): pssimulation1, ///
	 s(runiform(0.02,0.28)) r(runiform(0,0.4)) nid(`j') p(`i') alpha(runiform(0.2,1)) delta(1) delta2(runiform(1.5,5)) nid2(`j') 
	 qui drop if missing(ri) | missing(wi)
	 qui count if ri~=1
	 mat res111[`q',`p']=r(N)/_N
	 qui count if wi==1
	 mat res112[`q',`p']=r(N)/_N

   
   }



}

timer off 1
timer list 1
clear
matsave res111, replace
clear
matsave res112, replace


set seed 456
timer on 2
mat res121=J(4,3,.)
mat res122=J(4,3,.)

local p=0

foreach j in 20 40 60 {
   local p=`p'+1
   local q=0
   foreach i in 20 40 60 100{
     local q=`q'+1
     clear
     qui simulate ri=r(rightin) wi=r(wrongin), reps(1000):pssimulation2, ///
	 s(runiform(0.02,0.28)) r(runiform(0,0.4)) nid(`j') p(`i') alpha(runiform(0.2,1)) nid2(`j') 
	 qui drop if missing(ri) | missing(wi)
	 qui count if ri~=1
	 mat res121[`q',`p']=r(N)/_N
	 qui count if wi==1
	 mat res122[`q',`p']=r(N)/_N
   
   }



}
timer off 2
timer list 2

clear
matsave res121, replace
clear
matsave res122, replace

mata: mata clear
use c3data,clear
egen id=group(country)
xtset id year
gen lny=ln(rgdpna/pop)
pfilter lny, trend(lny2) method(hp) smooth(400)

putmata y1=lny2 if countrycode=="USA"
putmata y2=lny2 if countrycode=="COD"
mata: y1=y1'
mata: y2=y2'

timer on 3
set seed 789
mat res131=J(4,3,.)
mat res132=J(4,3,.)
mat res133=J(4,3,.)
local p=0

foreach j in 20 40 60 {
   local p=`p'+1
   local q=0
   foreach i in 0.1 0.3 0.6 0.8{
     local q=`q'+1
     clear
     qui simulate ri=r(rightin) wi=r(wrongin), reps(1000): pssimulation3, ///
	              nid(`j') p(65) alpha(`i') nid2(`j')
	 qui drop if missing(ri) | missing(wi)
	 qui count if ri~=1
	 mat res131[`q',`p']=r(N)/_N
	 qui count if wi==1
	 mat res132[`q',`p']=r(N)/_N
	 qui su ri
	 mat res133[`q',`p']=r(mean)
   
   }



}
timer off 3
timer list 3

clear
matsave res131, replace
clear
matsave res132, replace
clear
matsave res133, replace


