libname orion "/export/viya/homes/p42526@correo.uia.mx/Courses/YVA1";

/* Se crea un catálogo de clientes /**/

proc sql;
	create table customer_catalog
	as select distinct customer_id, customer_type
	from orion.customers
	order by customer_type;
quit;

Title "Cantidad de clientes";

proc sql;
	select count(distinct customer_id) format=comma10.0 as clientes
	from customer_catalog;
quit;

/*Muestra aleatoria simple/**/

proc surveyselect data=customer_catalog n=3500 out=SampleRep; 
run;

/*Muestreo estratificado no porporcional /**/

proc surveyselect data=customer_catalog n=500 out=SampleRep_strata;
	strata customer_type;
run;

/*Muestreo alatorio estratificado proporcional /**/

proc surveyselect data=customer_catalog n=3500 out=SampleRep_strata2;
	strata customer_type / alloc=prop;
run;

/* Dados que la muestra es grande, alrededor del 5% del número de 
clientes, vemos que los estratos se reparten de forma similar en 
el muestreo aleatorio simple y en el estratificado proporcional /**/

proc sql;
	create table customer_aux as
	select 'aleatorio' as muestra, customer_type, count(*) as clientes
	from SampleRep
	group by 1,2
	union all
	select 'estratificado' as muestra, customer_type, count(*) as clientes
	from SampleRep_strata
	group by 1,2
	union all
	select 'estratificado p' as muestra, customer_type, count(*) as clientes
	from SampleRep_strata2
	group by 1,2;
quit;

proc sgplot data=customer_aux;
  yaxis label="clientes por estrato";
  vbar customer_type / response= clientes datalabel 
  group=muestra groupdisplay=cluster; 
run;

