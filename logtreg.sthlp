{smcl}
{title:Title}

{phang}{bf: logtreg {hline 2} Linear regression for the log t test}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt logtreg} {varname}  {ifin} [, kq(#) {cmdab:nom:ata}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt kq(#)}}set the first {it:kq} proportion of the data to be discarded before regression; default is 0.3{p_end}
{synopt :{opt nomata}}conduct the regression mainly through the Stata routines; by default, user-written mata functions are used{p_end}
{synoptline}
{p 4 6 2}
A panel variable and a time variable must be specified. Use {helpb xtset}. The unbalanced panel data must be rectangularized. Use {helpb fillin}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:logtreg} conducts the log t test using linear regression with heteroskedasticity- and autocorrelation-consistent standard errors. See Phillips and Sul (2007a) for more technical details.

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

{phang2}{cmd:. logtreg lnpgdp2 }{p_end}

{phang2}{cmd:. logtreg lnpgdp2, kq(0.333)}{p_end}

{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:logtreg} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of individuals{p_end}
{synopt:{cmd:e(T)}}number of time periods{p_end}
{synopt:{cmd:e(nreg)}}number of observations used for the regression{p_end}
{synopt:{cmd:e(beta)}}log t coefficient {p_end}
{synopt:{cmd:e(tstat)}}t statistic for log t{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:e(res)}}table of estimation results{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:logtreg}{p_end}
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

{p 7 14 2}Help:  {help psecta}(if installed) {p_end}

