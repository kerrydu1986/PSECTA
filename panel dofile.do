egen id=group(countryname)
xtset id time, yearly
pfilter lgdppc, method(hp) trend(lnpgdp2) smooth(400)
logtreg lnpgdp2, kq(0.333)
psecta lnpgdp2, name(countryname) kq(0.333) gen(club)
****in the output would club 7 be converging ?? T Stat = -46.1770***
