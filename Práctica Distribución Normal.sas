/* Cálculo de probabilidades /**/

data fi;
	fi_0_96=probnorm(0.96);
	fi_1_96=probnorm(1.96);
	p_0_96_le_Z_le_1_96=fi_1_96-fi_0_96;
	label p_0_96_le_Z_le_1_96="P(0.96 <= Z <= 1.96)";
run;


/* Obtención de FDA y fd/**/

data fi_2;
	pi=constant("pi");
	do i=-10 to 10 by 0.1;
		z=i; fi_z=probnorm(i); f_z=(1/sqrt(2*pi))*exp(-0.5*z*z);
		output;
	end;
run;

title "FDA Z";
proc sgplot data=fi_2;
  series x=z y=fi_z;
run;
title;

title "fd Z";
proc sgplot data=fi_2;
  series x=z y=f_z;
run;
title;

/* simulación /**/

data fi_3;
	do i=1 to 200000;
		z=rand('normal');
		output;
	end;
run;	

proc univariate data=fi_3 plots;
	var z;
run;



