{smcl}
{title:Title}

{phang}{bf: pfilter {hline 2}  Filter a time-series variable in panel data}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt pfilter} {varname}, method(string) [trend(newvar) cyc(newvar) {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt method(string)}}filter method; it should be chosen from {bk, bw, cf, hp}; required*{p_end}
{synopt :{opt trend(newvar)}}create a variable for the trend component{p_end}
{synopt :{opt cyc(newvar)}}create a variable for the cyclical component{p_end}
{synopt :{opt options}}are any options available for {manhelp tsfilter TS} {p_end}
{synoptline}
{p 4 6 2}
A panel variable and a time variable must be specified. Use {helpb xtset}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd: pfilter} extends the {help tsfilter} command to operate on each time series in a panel. It extracts trend and cyclical components for each individual, respectively. See {manhelp tsfilter TS} for detailed techniques.

{synoptline}
{p2colreset}{...}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}

{phang2}{cmd:. use ps2009}{p_end}

{phang2}{cmd:. egen id = group(country)}{p_end}

{phang2}{cmd:. xtset id year}{p_end}

{phang2}{cmd:. gen lnpgdp=ln(pgdp)}{p_end}

{phang2}{cmd:. pfilter lnpgdp, method(hp) trend(lnpgdp2) smooth(400)}  {p_end}


{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:pfilter} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:pfilter}{p_end}
{synopt:{cmd:r(cmdline)}}command as typed{p_end}
{synopt:{cmd:r(varlist)}}name of the variable {p_end}

{hline}


{title:Authors}

{phang}
{cmd:Kerui Du}, Center for Economic Research, Shandong University, China.{break}
 E-mail: {browse "mailto:kerrydu@sdu.edu.cn":kerrydu@sdu.edu.cn}. {break}


{title:Also see}

{p 7 14 2}Help:  {help tsfilter}, {help hprescott}(if installed) {p_end}

