{smcl}
{title:Title}

{phang}{bf: imergeclub {hline 2}  iteratively merge adjacent clubs }


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt imergeclub} {varname}  {ifin} 
   {cmd:, club(varname) kq(#)} [name(varname str) {cmdab:g:en(newvar)} imore {cmdab:md:iv} {cmdab:nom:ata}  {cmdab:noprt:logtreg}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt club(varname)}}specify the initial club classifications; required*{p_end}
{synopt :{opt kq(#)}}set the first {it:kq} proportion of the data to be discarded before regression; required*{p_end}
{synopt :{opt name(varname str)}}specify a panel variable to be displayed for the clustering results; by default, the panel variable specified by {help xtset} is used{p_end}
{synopt :{opt gen(newvar)}}create a variable for the final club classifications{p_end}
{synopt :{opt imore}}try to merge clubs iteratively until no clubs can be merged {p_end}
{synopt :{opt mdiv}}include divergence group; by default it is excluded {p_end}
{synopt :{opt nomata}}use Stata routines; by default, user-written mata functions are used{p_end}
{synopt :{opt noprtlogtreg}}suppress the estimation results of the logtreg{p_end}
{synoptline}
{p 4 6 2}
A panel variable and a time variable must be specified. Use {helpb xtset}. The unbalanced panel data must be rectangularized. Use {helpb fillin}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd: imergeclub } iteratively conducts merging all adjacent clubs. The procedure is conducted as follows. First, run the log t test for the cross sections belonging to the initial Clubs 1 and 2 (obtained from club clustering). 
Second, if they fulfill the convergence hypothesis jointly, merge them to be the new Club 1, and then come to the run log t test for the new Club 1 and the initial Club 3; if not, come to run the log t test for initial Clubs 2 and 3, so on and 
so forth.

{synoptline}
{p2colreset}{...}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}

{phang2}{cmd:. use ps2009}{p_end}

{phang2}{cmd:. egen id = group(country)}{p_end}

{phang2}{cmd:. xtset id year}{p_end}

{phang2}{cmd:. gen lnpgdp=ln(pgdp)}{p_end}

{phang2}{cmd:. pfilter lnpgdp, id(country) time(year) method(hp) trend(lnpgdp2) smooth(400)}{p_end}

{phang2}{cmd:. psecta lnpgdp2, id(country) time(year) kq(0.333) gen(club)}  {p_end}

{phang2}{cmd:. imergeclub lnpgdp2, id(country) time(year) kq(0.333) club(club) gen(fclub) }{p_end}

{phang2}{cmd:. mat b=e(bm)}{p_end}

{phang2}{cmd:. mat ts=e(tm)}{p_end}

{phang2}{cmd:. mat list b}{p_end}

{phang2}{cmd:. mat list ts}{p_end}

{phang2}{cmd:. disp "`e(cmd)'"}{p_end}

{phang2}{cmd:. disp "`e(cmdline)'"}{p_end}

{phang2}{cmd:. disp "`e(varlist)'"}{p_end}

{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:imergeclub} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(nclub)}}number of convergent clubs{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrixs}{p_end}
{synopt:{cmd:e(beta)}}log t coefficients {p_end}
{synopt:{cmd:e(tstat)}}t statistics {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:imergeclub}{p_end}
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

{p 7 14 2}Help:  {help scheckmerge}(if installed) {p_end}

