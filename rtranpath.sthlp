{smcl}
{title:Title}

{phang}{bf: rtranpath {hline 2} Relative transition path plot }


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt rtranpath} {varname}  {ifin} 
   {cmd:, id(varname) time(varname) {cmdab:o:ver}(varname) {cmdab:a:gainst}(varname)} [{cmdab:g:en(newvar)} lopt(str) gopt(str)]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt id(varname)}}specify the cross sections; required*{p_end}
{synopt :{opt time(varname)}}specify the time periods; required*{p_end}
{synopt :{opt over(varname)}}specify the groups for plotting; required*{p_end}
{synopt :{opt against(varname)}}a dummy variable specifies the cross sections used as benchmarks; required*{p_end}
{synopt :{opt gen(newvar)}}create a variable for the relative transition parameter {p_end}
{synopt :{opt lopt(str)}}{helpb connect_options}; see the description for more details {p_end}
{synopt :{opt gopt(str)}}graph {helpb twoway_options} {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd: rtranpath} calculates the transition parameters for groups relative to some benchmarks over time and plots their transition paths. See Phillips and Sul (2007b), Phillips and Sul (2009) for the calculation of the relative
 transition parameters. {p_end}
{pstd}
The command has default settings for the plot. One can change them through lopt(str) and gopt(str) options. lopt(str) passes graph parameters as follows. The string before the first semicolon is passed to the plot of the first group;
 the string between the second and the third semicolons are passed to the plot of the second one, so on and so forth. If there is only the symbol "-" between two semicolons, it means nothing is passed to the corresponding plot.
 For example, "lopt(col(red) lw(thick);-;lw(thick) col(blue))" means that "col(red) lw(thick)" is set to the plot of the first group; "lw(thick) col(blue)" is set to the plot of the third one. {p_end}
{synoptline}
{p2colreset}{...}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}

{phang2}{cmd:. use ps2009}{p_end}

{phang2}{cmd:. gen lnpgdp=ln(pgdp)}{p_end}

{phang2}{cmd:. pfilter lnpgdp, id(country) time(year) method(hp) trend(lnpgdp2) smooth(400)}{p_end}

{phang2}{cmd:. rtranpath lnpgdp2, id(country) time(year) over(group) against(bench)}{p_end}

{phang2}{cmd:. local goption title(Transition path)}{p_end}

{phang2}{cmd:. local loption  "-;lw(thick) col(green);-;lw(thick) col(green);lw(thick) col(red)"}{p_end}

{phang2}{cmd:. rtranpath lnpgdp2, id(country) time(year) over(group) against(ben)lopt(`loption') gopt(`goption')}{p_end}

{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:tranpath} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:rtranpath}{p_end}
{synopt:{cmd:r(cmdline)}}command as typed{p_end}
{synopt:{cmd:r(varlist)}}name of the variable used to calculate transition parameters{p_end}


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
{cmd:Kerry Du}, Center for Economic Research, Shandong University, China.{break}
 E-mail: {browse "mailto:kerrydu@sdu.edu.cn":kerrydu@sdu.edu.cn}. {break}


{title:Also see}

{p 7 14 2}Help:  {help tranpath}(if installed) {p_end}

