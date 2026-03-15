/*FDA de la suma de dos dados/**/

data a (drop=i j);
	do i=1 to 6;
		d1=i;
			do j=1 to 6;
				d2=j;
				x=d1+d2;
				output;
			end;
	end;
run;
 
ods select cdfplot;
proc univariate data=A;
cdfplot x / vscale=percent
         odstitle="Empirical CDF" odstitle2="PROC UNIVARIATE";
ods output cdfplot=outCDF;   /* data set contains ECDF values */
run;

/*FDA continua /**/

data b ;
	do i=1 to 10000;
		y=rand('uniform');
		X=sign(9*y-8)*abs(9*y-8)**(1/3);
		fx=x**2/3;
		output;
	end;
run;

proc sort data=b;
	by X;
run;

proc sgplot data=b;
	series x=x y=fx  / markers;
run;

proc univariate data=b noprint;
	cdf X;
run;




	



