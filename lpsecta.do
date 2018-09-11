*revised on May04, 2017
version 12.1
mata:
mata clear

//////////////////////////////////////////////////////
//mata function _getcluster: 
//It is used to identify convergent clubs using PS(2007) method
//Kerui Du, 2016-10-31
// revised, add an argument _club to store results
// mata function, results is stored in variable _club
//revised 2016-11-01, return a matrix "stores" whose first collum is club, 
// and second collum is clubmember

 function _getcluster( real matrix id2,
                       real matrix id3,
					   real matrix XX,
					   real scalar cr,
					   real scalar kq,
					   real scalar adj,
					   real scalar incr,
					   real scalar maxcr,
					   real scalar forder,
					   string scalar _club)
 {
	
	
	
	club=J(length(id2),1,.)
	stores=J(0,2,.)
		 
    clubmember=_findclub(XX,cr,kq,adj,incr,maxcr,forder)
	
	if (length(clubmember)==0) {
		printf("There are no convergent subgroups.\n ")

		exit()
	  }

	else { 

		// record the position of clubmember of club 1 in the data
		pid=_posmatch(id2,clubmember) 
		club[pid,1]=J(length(pid),1,1)
		stores=stores \ (J(length(clubmember),1,1),clubmember)
		// collect the remainders 
		remainder=_vecdiff(id3, clubmember)
		if (length(remainder)<2) {
		// getmata command can be used instead
			st_view(tempclub=.,.,_club)
		    tempclub[1::rows(tempclub)]=club
		    return(stores)
		    exit()
		}

		 rpid=_posmatch(id3,remainder)
		 res=_reglogt(XX[rpid,2..cols(XX)],kq)
		 tstat=_getts(res)[1,1]
		// check if the remainders form a convergent club
		if (tstat>-1.65 & tstat!=.) {
			pid=_posmatch(id2,remainder)
			club[pid,1]=J(length(pid),1,2)
			st_view(tempclub=.,.,_club)
		    tempclub[1::rows(tempclub)]=club
		    stores=stores \ (J(length(remainder),1,2),remainder)
		    return(stores)
		    exit()
		  
		     }
        // if not, repeat finding clubs
		else {
			jt=2
			while (length(clubmember)) {
			     rpid=_posmatch(id3,remainder)
			
                 clubmember=_findclub(XX[rpid,.],cr,kq,adj,incr,maxcr,forder)
				 	
					if (length(clubmember)) {
						pid=_posmatch(id2,clubmember)
						club[pid,1]=J(length(pid),1,jt)
						stores=stores \ (J(length(clubmember),1,jt),clubmember)
						remainder=_vecdiff(remainder, clubmember)
						if (length(remainder)<2) {
							st_view(tempclub=.,.,_club)
						    tempclub[1::rows(tempclub)]=club
						    return(stores)
						    exit()
		                }

		                rpid=_posmatch(id3,remainder)
						res=_reglogt(XX[rpid,2..cols(XX)],kq)
						tstat=_getts(res)[1,1]
						
						if (tstat>-1.65 & tstat!=.) {
							pid=_posmatch(id2,remainder)
							club[pid,1]=J(length(pid),1,jt+1)
							st_view(tempclub=.,.,_club)
						    tempclub[1::rows(tempclub)]=club
						    stores=stores \ (J(length(remainder),1,jt+1),remainder)
						    return(stores)						    
						    exit()
		  
						 }


				    }
					jt=jt+1
					
             }
			 // exchange results between mata and stata
			 st_view(tempclub=.,.,_club)
			 tempclub[1::rows(tempclub)]=club
			 return(stores)

		 }


	  }
	  
	}




/////////////////////////////////////////////////////////
function _findclub(real matrix x, // x should be arranged as: the first collum is id;
                                  // the second one to the end is observations of individuals 
								  // for each time period. 
                  real scalar cr,
				  real scalar kq,
				  real scalar adj,
				  real scalar incr,
				  real scalar maxcr,
				  real scalar forder)
{ 
  
  //Initialize the return results 
  clubmember=J(0,0,.)
  T=cols(x)
  N=rows(x)
  //If the data only contains one individual, exit.
  if (N<2){
    return(clubmember)
	exit()
  }
  // Step 1 Cross-section sorting according the final period
  if (forder==0){
	  x1=x
	  x1=-sort(-x1,T) // decreasing order
	  id=x1[.,1]
	  x2=x1[.,2..T]  	
  }
  else{
  	x1=x[.,(trunc((1-forder)*(T-1))+2)..T]
  	x1=rowmean(x1)
  	x1=x,x1
  	x1=-sort(-x1,T+1)
  	id=x1[.,1]
  	x2=x1[.,2..T]
  }

  tt=-100
  k=1
  // Step 2.1 find the first two successive individuals for which the t-stat >-1.65 
  while (tt<=-1.65  & k<N){
     res=_reglogt(x2[k..(k+1),.],kq)
	 tt=_getts(res)[1,1]
	 k=k+1
	 }
	 
   // If step 2.1 fails, no convergent club exists.	 
	if (tt==.){
	    
	    return(clubmember)
		exit()
	 }

	if (k>=N & tt<=-1.65){
	    
	    return(clubmember)
		exit()
	 }
	 else {
		 // Step 2.2 find the core group by
		 // increasing k until t-stat <=-1.65
		 // and recording the largest k
	    // flag=1
		 j=k
		 tmat=J(N,2,.)
		 while (j<=N & tt>-1.65){
			 res=_reglogt(x2[(k-1)..j,.],kq)
			 tt=_getts(res)[1,1]
			 if(tt==.){
			 	break
			 }
			 tmat[j,.]=tt,j
			 j=j+1
			 }
		 jtmax=-sort(-tmat,1)[1,2]
		 coreid=id[(k-1)::jtmax,.] // record the core group
		 // Step 3.1 form the comlemmentary group
		 cin1=_vecdiff(id,coreid) 
	     // Step 3.2 add one at a time from the comlemmentary group
		 // run the logt test and if t-stat>cr, put it into the club.
		 iniclub=coreid
		 for (j=1;j<=length(cin1);j++) { 
		      idlist=coreid \ cin1[j,1]
			  zflag=_posmatch(id,idlist)
			  res=_reglogt(x2[zflag,.],kq)
			  tt=_getts(res)[1,1]
			  if (tt>cr&tt!=.) iniclub=iniclub \ cin1[j,1]
		 
		      }
           // check the club formed in Step 3.2 is convergent
		   zflag=_posmatch(id,iniclub)
		   res=_reglogt(x2[zflag,.],kq)
		   tt=_getts(res)[1,1]
		   
		   // examine if new members is added to the core group
		   // if not, no ones can be further added
		   inieqcore=(length(iniclub)==length(coreid))
		   
		   if (tt<=-1.65 & inieqcore!=1) {

		      if (adj==0) { // default, use the original PS method (increasing cr)
			  
			      while (tt<=-1.65 & cr<maxcr){
				      cr=cr+incr // increase cr to exclue some individuals
					  cin1=_vecdiff(iniclub,coreid)
					  iniclub=coreid
					  for (j=1;j<=length(cin1);j++) { 
						   idlist=coreid \ cin1[j,1]
						   zflag=_posmatch(id,idlist)
						   res=_reglogt(x2[zflag,.],kq)
						   tt=_getts(res)[1,1]
						   if (tt>cr & tt!=.) iniclub=iniclub \ cin1[j,1]
						   }
					   zflag=_posmatch(id,iniclub)
					   res=_reglogt(x2[zflag,.],kq)
					   tt=_getts(res)[1,1]
		           }
				   //revised at 2016-10-28
				   // check if exit without a convergent group
				   if (cr>=maxcr & tt<=-1.65) iniclub=coreid
				 }
				
				if (adj==1) { // use the adjusted method in JAE-2016
				    cin1=_vecdiff(iniclub,coreid)
					cin0=cin1
					iniclub=coreid
					ncin1=length(cin1)
					

					while (ncin1>0) {
					    tmat=J(0,2,.)
                        for (j=1;j<=length(cin1);j++) { 
							   idlist=coreid \ cin1[j,1]
							   zflag=_posmatch(id,idlist)
							   res=_reglogt(x2[zflag,.],kq)
							   tt=_getts(res)[1,1]
							   tmat=tmat \ (tt,cin1[j,1])
						 }
						 tmat=-sort(-tmat,1)
						 tmax=tmat[1,1]
					   
						 if (tmax<=-1.65) {
						   break
						 }
						 iniclub=iniclub \ tmat[1,2]
						 cin1=_vecdiff(cin0,iniclub)
						 ncin1=length(cin1)   
						 	   
					
					 }
					
					
				 }
			  
					  
				
					  
					
			  }

			  clubmember=iniclub
			  
		 }
		   
		 
		 return(clubmember)	 
	 
}


////////////////////////////////////////////////////
//mata function: identify the positions of the elements 
//of x matching the elements of y

function _posmatch(real colvector x, real colvector y)
	{
	
	  //z=J(length(y),1,.)
	  //for (i=1;i<=length(y);i++){
	  //   z[i,1]=mm_which(x:==y[i])
	  //}
	    z=J(0,1,.)
		for (i=1;i<=length(y);i++){
		    z=z \ mm_which(x:==y[i])
	    }
		   return(z)

		}
   
  
   
   
   
   
/////////////////////////////////////////////////////////

/*
function _getmatch(real colvector x, real colvector y)
	{
	
	  z=J(length(y),1,.)
	  for (i=1;i<=length(y);i++){
	     z[i,1]=mm_which(x:==y[i])
	  }

		   return(z)

		}
 */ 
 
//////////////////////////////////////////////////////////
// mata function: check whether the elements of x is in y

function _checkmatch(real colvector x, real colvector y)
 {
	
	  z=J(length(x),1,0)
	  for (i=1;i<=length(y);i++){
	      flag=mm_which(x:==y[i])
	      z[flag,1]=J(length(flag),1,1)
	  
	  }

		   return(z)

 }
   
 
   
   
   
///////////////////////////////////////////////////////
// mata function: set difference of x and y
// identifying the elements of x not belonging to y

function _vecdiff(real colvector x, real colvector y)
	{
	
	  z=J(length(x),1,1)
	  for (i=1;i<=length(y);i++){
	      flag=mm_which(x:==y[i])
	      z[flag,1]=J(length(flag),1,0)
		  s=select(x,z)
	  
	     }
		   return(s)

		}
   
   

	
  //////////////////////////////////////////////
  /// define structure to store estimate results

	  struct getres { real colvector b
	                  real matrix V
					  real colvector ts
					  real scalar N
					  }
	  
 ///////////////////////////////////////////////  
// log t regression
   function _reglogt(real matrix x,
                     real scalar r)
	 {
	   T=cols(x)
	   n=rows(x)
	   xcm=colmean(x)
	   hi=x:/xcm#J(n,1,1)
	   hi=(hi:-1):^2
	   Ht=colmean(hi)'
	   logt=log(1::T)
	   Ht=log(Ht[1,1]:/Ht):-2*log(logt)
	   xx=logt,J(T,1,1)
	   //p=ceil(r*T)
	   p=round(r*T)+1
	   logt=logt[p::T]
	   xx=xx[p::T,.]
	   Ht=Ht[p::T,1]

	   //b=invsym(xx'*xx)*xx'*Ht
	   b=invsym(cross(xx,xx))*xx'*Ht
	   rs=Ht-xx*b
	   rs=rs:-mean(rs)
	   omega=_andrs(rs)
	   //V=invsym(xx'*xx)*omega
	   V=invsym(cross(xx,xx))*omega
	   stde=sqrt(diagonal(V))
	   ts=b:/stde
	   struct getres scalar reslogt
	           reslogt.b=b
			   reslogt.V=V
			   reslogt.ts=ts
			   reslogt.N=length(logt)
	    
		return(reslogt)
	   }
	   
	   
	 
	//////////////////////////////////////////////
	// extract elements from the structure

	  function _getb(struct getres scalar res)
	  {
	    b=res.b
		return(b)
	  }
	  
	 
	  
	
	  function _getV(struct getres scalar res)
	  {
	    V=res.V
		return(V)
	  }
	  
	 
	  

	  function _getN(struct getres scalar res)
	  {
	    N=res.N
		return(N)
	  }
	  
	  
	  

	  function _getts(struct getres scalar res)
	  {
	    ts=res.ts
		return(ts)
	  }
	  
	 
	 /////////////////////////////////////// 
	  
	 //calculate collum mean
	 
	 real matrix function colmean(real matrix z)
	    {
		  n=colnonmissing(z) 
		  s=colsum(z)
		  s=s:/n
		  return(s)
		
		}
		
	// calculate row mean
		 real matrix function rowmean(real matrix z)
	    {
		  n=rownonmissing(z) 
		  s=rowsum(z)
		  s=s:/n
		  return(s)
		
		}
		
		
		
		
///////////////////////////////////////////
// calculate long run variance
// This code is translated from Donggyu Sul's gauss code 
function _andrs(real matrix x)
	{
		mr=rows(x)
		nc=cols(x)
		x1=x[(1::(mr-1)),.]
		y1=x[(2::mr),.]
		b1=colsum(x1:*y1):/colsum(x1:*x1)
		a2=4*(b1:^2):/((1:-b1):^4)
		band2=1.3221*(a2:*mr):^(1/5)
		jb2=(1..(mr-1))'

		jb2=jb2:/band2
		jband2=jb2:*(1.2*pi())
		kern1=(sin(jband2):/jband2-cos(jband2)):/((jb2:*pi()):^2*12):*25
		lam=J(nc,nc,0)
		t=mr-1

		for(i=1;i<=(t-1);i++){
		   ttp1=(x[1..(t-i),.]'*x[(1+i)..t,.]):*kern1[i,.]/t
		   ttp=((x[1..(t-i),.]'*x[(1+i)..t,.])'):*kern1[i,.]/t
		   lam=lam+ttp+ttp1
		    }
		   
		   sigm=x'*x/t
		   V=sigm+lam
		   // st_matrix("r(V)", V)
		   return(V)

		}
		
		
		
		
   
 ///////////////////////////////////////////////////////////////////////// 
 ///convert vector to matrix	  
	
function _vec2mat(real vector x,
                 real scalar nr,
				 real scalar nc)
{
  z=J(nr,nc,.)
  for (i=1;i<=nc;i++){
      z[.,i]=x[(i*nr-nr+1)..i*nr]
  }

   return(z)

}


/////////////////////////////////////////////////////////////////////////  

// display function

void _prttext(string vector txt, 
             real scalar c)
{
	  len=length(txt)
	  if (len==0) exit() 
	  temp1=txt[1,1]
	  for(i=2;i<=len;i++){
	     temp2=temp1
	     temp1=temp1,txt[1,i]
		 ns=sum(strlen(temp1))+2*length(temp1)
		if(length(temp1)==1 & ns>=c){
			printf(" |")
		    printf(" %s |",temp2)
			temp1=J(1,0,"")
		  }

		 if (length(temp1)>1 & ns>=c){
		       printf(" |")
		 	   for(j=1;j<=length(temp2);j++){
				  printf(" %s |",temp2[1,j])
	           }
			   printf("\n")
			   temp1=txt[1,i]
			   
		  } 
		 
	    }
	
	  if (length(temp1)>0){
	     printf(" |")
	     for(j=1;j<=length(temp1);j++){
		     printf(" %s |", temp1[1,j])
		 
		 }
		 printf("\n")
	  
	  }


}


/*
void _prttext(string vector txt, 
             real scalar c)
{
	  len=length(txt)
	  if (len==0) exit() 
	  temp1=txt[1,1]
	  for(i=2;i<=len;i++){
	     temp2=temp1
	     temp1=temp1,txt[1,i]
		if(length(temp1)==1){
		   if (sum(strlen(temp1))>=c){
			printf(" |")
		    printf(" %s |",temp2)
			temp1=J(1,0,"")
		    }
		  }

		 if (length(temp1)>1 & sum(strlen(temp1))>c){
		       printf(" |")
		 	   for(j=1;j<=length(temp2);j++){
				  printf(" %s |",temp2[1,j])
	           }
			   printf("\n")
			   temp1=txt[1,i]
			   
		  } 
		 
	    }
	
	  if (length(temp1)>0){
	     printf(" |")
	     for(j=1;j<=length(temp1);j++){
		     printf(" %s |", temp1[1,j])
		 
		 }
		 printf("\n")
	  
	  }


}
*/


/*
// calculate long run variance
// for nomata option
//This code is translated from Donggyu Sul's gauss code
real matrix _andrs2(string scalar res)
	{
		st_view(x=.,.,tokens(res))
		mr=rows(x)
		nc=cols(x)
		x1=x[(1::(mr-1)),.]
		y1=x[(2::mr),.]
		b1=colsum(x1:*y1):/colsum(x1:*x1)
		a2=4*(b1:^2):/((1:-b1):^4)
		band2=1.3221*(a2:*mr):^(1/5)
		jb2=(1..(mr-1))'

		jb2=jb2:/band2
		jband2=jb2:*(1.2*pi())
		kern1=(sin(jband2):/jband2-cos(jband2)):/((jb2:*pi()):^2*12):*25
		lam=J(nc,nc,0)
		t=mr-1

		for(i=1;i<=(t-1);i++){
		   ttp1=(x[1..(t-i),.]'*x[(1+i)..t,.]):*kern1[i,.]/t
		   ttp=((x[1..(t-i),.]'*x[(1+i)..t,.])'):*kern1[i,.]/t
		   lam=lam+ttp+ttp1
		    }
		   
		   sigm=x'*x/t
		   V=sigm+lam

		   // st_matrix("r(V)", V)
		   return(V)

		}
  */
  

// calculate standard error
// for nomata option
   void _stderror(string scalar res,
                 string scalar regressor,
                 real rowvector beta)

        {
        	st_view(XX=.,.,tokens(regressor))
        	
        	con=J(rows(XX),1,1)
        	XC=XX,con

    		st_view(y=.,.,tokens(res))

        	omega=_andrs(y)
        	V=invsym(XC'*XC)*omega
        	stde=sqrt(diagonal(V))
        	tstat=beta:/stde'
        	//st_scalar("r(stde)", stde[1])
        	st_numscalar("r(tstat)",tstat[1,1])
        	st_matrix("r(V)",V)
        }


  

//////////////////////////////////////////////////////////////////////////
					
 mata  mlib create lpsecta, replace 
 mata mlib add lpsecta *()
 mata mlib index
 
 end
