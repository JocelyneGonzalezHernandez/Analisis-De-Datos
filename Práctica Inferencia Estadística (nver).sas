/* Insertamos la data referente al problema de la 
variante nueva de trigo. Los datos son rendimiento de
las parcelas sembradas /**/

data rendimientos_parcela;
   input rendimiento @@;
   datalines;
89.4  92.8  79.2  82.6  96.2 65.6  106.4  86.0  99.6  69.0  77.5  58.8  96.2  80.9  52.0
;

/* Se añade en el procedimiento univariate el ajuste de una 
distribución normal para que se elabore la prueba de bondad de 
ajuste, reocordar que la hipótesis nula (la distribución ajusta a
los datos) se rechaza cuando el p-valor es inferior a 0.05. Para ello
usar el cuadro "Test de bondad de ajuste para la distribución Normal".

En particular para el set de datos el P-valor es 0.15, por lo que no se 
rechaza el ajuste /**/

proc univariate data= rendimientos_parcela plots;
	var rendimiento;
	histogram /normal;
run;

/* Usamos el procedimiento ttest para obtener el intervalo de confianza
tanto de la media como de la varianza para datos normales (que vienen de
una distribución normal) con confianza al 95% (1-alpha) /**/

proc ttest data=rendimientos_parcela alpha=0.05;
   var rendimiento;
run;


