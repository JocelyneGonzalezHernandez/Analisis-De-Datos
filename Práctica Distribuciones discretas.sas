data test;
	bin=cdf('binomial',5,0.0001,50000)- cdf('binomial',4,0.0001,50000);
	pois=cdf('poisson',5,5)- cdf('poisson',4,5);
run;

data test2;
	bin=pdf('binomial',5,0.0001,50000);
	pois=pdf('poisson',5,5);
run;

data fi_2;
	pi=constant("pi");
	mu=9;
	sigma_c=6.3;
	do i=0 to 30 by 1;
		z=i; 
		f_z=(1/sqrt(2*pi*sigma_c))*exp(-0.5*((z-mu)/sqrt(sigma_c))*((z-mu)/sqrt(sigma_c)));
		bin_z=pdf('binomial',z,0.3,30);	 
		output;
	end;
run;

title "Aproximación binomial por normal";
proc sgplot data=fi_2;
  vbar z/ response=bin_z;
  vline z / response=f_z y2axis;
run;
title;

data fi_2;
	pi=constant("pi");
	mu=36;
	sigma_c=25.2;
	do i=0 to 120 by 1;
		z=i; 
		f_z=(1/sqrt(2*pi*sigma_c))*exp(-0.5*((z-mu)/sqrt(sigma_c))*((z-mu)/sqrt(sigma_c)));
		bin_z=pdf('binomial',z,0.3,120);	 
		output;
	end;
run;

title "Aproximación binomial por normal";
proc sgplot data=fi_2;
  vbar z/ response=bin_z;
  vline z / response=f_z y2axis;
run;
title;

data fi_2;
	pi=constant("pi");
	mu=81;
	sigma_c=56.7;
	p=0.3;
	n=270;
	do i=0 to 270 by 2;
		z=i; 
		f_z=pdf('normal',z,mu,sqrt(sigma_c));
		bin_z=pdf('binomial',z,p,n);	 
		output;
	end;
run;

title "Aproximación binomial por normal";
proc sgplot data=fi_2;
  vbar z/ response=bin_z;
  vline z / response=f_z y2axis;
run;
title;


