libname orion "/export/viya/homes/p42526@correo.uia.mx/Courses/YVA1";

/* Ejemplo de tabla de frecuencias /**/

proc freq data=orion.employees;
	tables Job_title;
run;

/* Tambíen podemos obtener diversos tipos de gráficos 
con este procedimiento /**/

proc freq data=orion.employees order=freq;
	tables Job_Title /plots=freqplot;
	tables Job_Title /plots=freqplot (scale=percent);
run;

/* Si necesitamos mayor control en el gráfico de barras
podemos exportar la salida y usar sgplot que está especializado
en gráficas para 2D /**/

proc freq data=orion.employees order=freq noprint;
	tables Job_Title / out=frecuencias_empleado;
run;

/*NOTA: La salida sólo nos da la tabla de frecuencias 
absoluta y relativa, no acumulativa /**/

Title "Gráfico de barras para freciencia de Job Title";

proc sgplot data=frecuencias_empleado;
  yaxis label="Frecuencia absoluta de Job Title";
  vbar Job_title / response=count datalabel;
run;

proc sgplot data=frecuencias_empleado;
  yaxis label="Frecuencia relativa de Job Title";
  vbar Job_title / response=percent datalabel categoryorder=respdesc;
run;

/* Este procedimiento tambíen nos deja revisar el número o porcentaje de 
valores ausentes /**/

Title "Gráfico de barras para freciencia de Job Title, se incluyen nulos";

proc sgplot data=frecuencias_empleado;
  yaxis label="Frecuencia absoluta de Job Title";
  vbar Job_title / response=count datalabel missing categoryorder=respdesc;
run;

/* Si tenemos subdivisiones en una categoría mediante la combinación con
otra categoría podemos obtner la tabla de frecuencias y gráficos respectivos /**/

/* Con barras subdivididas /**/

proc freq data=employees order=freq;
	tables Job_Title*Company /plots=freqplot (twoway=stacked);
run;

/* Con barras agrupadas /**/

proc freq data=employees order=freq;
	tables Job_Title*Company /plots=freqplot (twoway=cluster);
run;


/* Finalmente, para gráficos circulares el procedimiento proc gchart no necesita 
el precálculo de otro procedimiento /**/

proc gchart data=orion.employees;
   pie Job_Title / percent=arrow;
run;

/* ¿Qué pasa si ponemos a funcionar un pie chart con datos numéricos 
tipo continuo? /**/

proc sql;
	create table order_aux as
	select order_id, sum(retailprice) format=comma10.0 as monto_ticket
	from orion.customers
	group by 1;
quit;

proc gchart data=order_aux;
   pie monto_ticket / percent=arrow;
run;

/* Se pueden discretizar la variable con este fin /**/

proc sql;
	select 
		min(monto_ticket) as min_monto_ticket,
		max(monto_ticket) as max_monto_ticket,
		max(monto_ticket)-min(monto_ticket) as rango,
		(max(monto_ticket)-min(monto_ticket))/10 as sector	
	from order_aux;
quit;

proc sql;
	create table order_aux2
	as select 
		case when monto_ticket le 1000 then "hasta 1000"
			 when monto_ticket le 2000 then "1000 a 2000"
			 when monto_ticket le 3000 then "2000 a 3000"
			 when monto_ticket le 4000 then "3000 a 4000"
			 when monto_ticket le 5000 then "4000 a 5000"
			 when monto_ticket le 6000 then "5000 a 6000"
			 when monto_ticket le 7000 then "6000 a 7000"
			 when monto_ticket le 8000 then "7000 a 8000"
			 when monto_ticket le 9000 then "8000 a 9000"
			 when monto_ticket gt 9000 then "más de 9000"
			 else "" end as monto_ticket_nom,
		*
	from order_aux;
quit;

proc gchart data=order_aux2;
   pie monto_ticket_nom / percent=arrow;
run;

/* Podemos usar la tabla de deciles pare tener una mejor segmentación /**/

proc univariate data=order_aux noprint;
	var monto_ticket;
	histogram;
	output out=order_decile_data
	pctlpts = 10 to 100 by 10
	pctlpre = D_;
run;

proc sql;
	create table order_aux2
	as select 
		case when monto_ticket le 20 then "20 -"
			 when monto_ticket le 40 then "25 a 40"
			 when monto_ticket le 60 then "40 a 60"
			 when monto_ticket le 80 then "60 a 80"
			 when monto_ticket le 100 then "80 a 100"
			 when monto_ticket le 150 then "100 a 150"
			 when monto_ticket le 200 then "150 a 200"
			 when monto_ticket le 250 then "200 a 250"
			 when monto_ticket le 500 then "250 a 500"
			 when monto_ticket gt 500 then "500 +"
			 else "" end as monto_ticket_nom,
		*
	from order_aux
	order by 1;
quit;

proc gchart data=order_aux2;
   pie monto_ticket_nom ;
run;














