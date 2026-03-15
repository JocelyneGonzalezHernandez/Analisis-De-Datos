data cosechas;
	input maiz cacahuate;
	datalines;
2.4 1.33 
3.4 2.12 
4.6 1.80 
3.7 1.65 
2.2 2.00 
3.3 1.76 
4.0 2.11 
2.1 1.63
;

proc corr data = cosechas out=salida
	plots=matrix(histogram);
	var maiz cacahuate;
run;