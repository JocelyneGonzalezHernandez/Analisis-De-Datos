libname orion "/export/viya/homes/p42526@correo.uia.mx/Courses/YVA1";

/* El pricedimiento univariate nos da las principales medidas de centralidad,
dispersión y ubicación (centiles) /**/

proc univariate data=orion.employees;
	var salary;
run;

/* Si añadimos la opción vardef, calcual la variaza poblacional en lugar
de la varianza muestral que tiene por default/**/

proc univariate data=orion.employees vardef=n;
	var salary;
run;

/* De manera sencilla podemos pedirle que porporcione un histograma de la variable /**/

proc univariate data=orion.employees;
	var salary;
	histogram;
run;

/* Pero podemos inducir los rangos para crear el histograma /**/

proc univariate data=orion.employees;
	var salary;
	histogram /midpoints=(20000 to 41000 by 1000);
run;

/* También podemos seleccionar los percentiles (u otras medidas) 
que necesitemos obtener en un dataset de salida /**/

proc univariate data=orion.employees noprint;
	var salary;
	output out=percentiles pctlpts = 19 35
		   pctlpre = salary
		   pctlname = pct19 pct35;
run;

proc univariate data=orion.employees noprint;
	var salary;
	output out=median median=p50 mode=moda p5=p5str p95=p95str;
run;


/* Finalmente tambíen nos ayuda a generar gráficos de caja y bigote /**/


proc univariate data=orion.employees plots;
   var salary;
run;

/* Pero para generar un polígono de frecuencias es necesario llevar los datos de 
del histograma a un dataset de salida para usarlos en un procedimiento sgplot /**/

title "Histograma de frecuencias";
proc univariate data=orion.employees(keep=salary);
   var salary;
   histogram / outhist=OutHist grid vscale=count
               midpoints=(20000 to 41000 by 1000); 
run;

title "Polígono de frecuencias";
proc sgplot data=OutHist;
   series x=_MIDPT_ y=_COUNT_ / markers;
   yaxis grid values=(0 to 220 by 20) label="Count" offsetmin=0;
   xaxis grid values=(20000 to 41000 by 1000) label="Salary";
run;

