
use ps2009
egen id=group(country)
xtset id year
gen lnpgdp=ln(pgdp)
pfilter lnpgdp, method(hp) trend(lnpgdp2) smooth(400)

logtreg lnpgdp2,  kq(0.333)


psecta lnpgdp2, name(country) kq(0.333) gen(club) noprt
mat b=e(bm)
mat t=e(tm)
mat result1=(b \ t)
matlist result1, border(rows) rowtitle("log(t)") format(%9.3f) left(4)


scheckmerge lnpgdp2,  kq(0.333) club(club) mdiv
mat b=e(bm)
mat t=e(tm)
mat result2=(b \ t)
matlist result2, border(rows) rowtitle("log(t)") format(%9.3f) left(4)

imergeclub lnpgdp2, name(country) kq(0.333) club(club) gen(finalclub) noprt
mat b=e(bm)
mat t=e(tm)
mat result3=(b \ t)
matlist result3, border(rows) rowtitle("log(t)") format(%9.3f) left(4)


