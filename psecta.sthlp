{smcl}
{title:Title}

{phang}{bf: psecta {hline 2}  club convergence test and clustering }


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt psecta} {varname} [, name(panelvar) kq(#) {cmdab:g:en(newvar)} cr(#) incr(#) maxcr(#) {cmdab:a:dust} fr(#) {cmdab:nom:ata} {cmdab:noprt:logtreg}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt name(panelvar)}}specify a panel variable to be displayed for the clustering results; by default, the panel variable specified by {help xtset} is used{p_end}
{synopt :{opt kq(#)}}set the first {it:kq} proportion of the data to be discarded before regression; default is 0.3 {p_end}
{synopt :{opt gen(newvar)}}create a variable for club classifications{p_end}
{synopt :{opt cr(#)}}the critical value for club clustering; default is 0 {p_end}
{synopt :{opt incr(#)}}the increment of cr when the initial cr value fails to sieve individuals for clusters; default is 0.05{p_end}
{synopt :{opt maxcr(#)}}the maximum of cr value; default is 50 {p_end}
{synopt :{opt adjust}}use the adjusted method proposed by Schnurbus et al.(2016) instead of raising cr when the initial cr value fails to sieve individuals for clusters. See Schnurbus et al.(2016) for more details {p_end}
{synopt :{opt fr(#)}}specify sorting individuals by the time series average of the last {it:fr} proportion of the data; by default,fr=0, sorting individuals according to the last period {p_end}
{synopt :{opt nomata}}use Stata routines; by default, user-written mata functions are used{p_end}
{synopt :{opt noprtlogtreg}}suppress the estimation results of the logtreg{p_end}
{synoptline}
{p 4 6 2}
A panel variable and a time variable must be specified. Use {helpb xtset}. The unbalanced panel data would be rectangularized temporally by  {helpb tsfill}. But note that observations at the starting period for all individuals must not be missing.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd: psecta} conducts club convergence and clustering analysis using the algorithm proposed by Phillips and Sul (2007a). 

{synoptline}
{p2colreset}{...}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}

{phang2}{cmd:. use ps2009}{p_end}

{phang2}{cmd:. egen id = group(country)}{p_end}

{phang2}{cmd:. xtset id year}{p_end}

{phang2}{cmd:. gen lnpgdp=ln(pgdp)}{p_end}

{phang2}{cmd:. pfilter lnpgdp,  method(hp) trend(lnpgdp2) smooth(400)}{p_end}

{phang2}{cmd:. psecta lnpgdp2, name(country) kq(0.333) gen(club)}  {p_end}

{phang2}{cmd:. mat b=e(bm)}{p_end}

{phang2}{cmd:. mat ts=e(tm)}{p_end}

{phang2}{cmd:. mat club=e(club)}{p_end}

{phang2}{cmd:. mat list b}{p_end}

{phang2}{cmd:. mat list ts}{p_end}

{phang2}{cmd:. mat list club}{p_end}

{phang2}{cmd:. disp "`e(cmd)'"}{p_end}

{phang2}{cmd:. disp "`e(cmdline)'"}{p_end}

{phang2}{cmd:. disp "`e(varlist)'"}{p_end}

{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:psecta} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(nclub)}}number of convergent clubs{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrixs}{p_end}
{synopt:{cmd:e(bm)}}log t coefficients {p_end}
{synopt:{cmd:e(tm)}}t statistics {p_end}
{synopt:{cmd:e(club)}}club classifications {p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:psecta}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(varlist)}}name of the variable for log t test{p_end}


{p2colreset}{...}

{marker references}{...}
{title:References}

{phang}
Phillips PCB, Sul D. 2007a. Transition modeling and econometric convergence tests. Econometrica 75:1771-1855.
{p_end}
{phang}
Phillips PCB, Sul D. 2007b. Some Empirics on Economic Growth under Heterogeneous Technology. Journal of Macroeconomics 29 :455-469¡£
{p_end}
{phang}
Phillips PCB, Sul D. 2009. Economic Transition and Growth. Journal of Applied Econometrics 24:1153-1185.
{p_end}
{phang}
Schnurbus J, Haupt H., Meier V. 2016. Economic Transition and Growth: A replication. Journal of Applied Econometrics, forthcoming.
{p_end}


{hline}


{title:Authors} 

{phang}
{cmd:Kerui Du}, Center for Economic Research, Shandong University, China.{break}
 E-mail: {browse "mailto:kerrydu@sdu.edu.cn":kerrydu@sdu.edu.cn}. {break}


{title:Also see}

{p 7 14 2}Help:  {help psectastata}(if installed) {p_end}

