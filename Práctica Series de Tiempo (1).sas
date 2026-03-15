libname orion "/export/viya/homes/p42526@correo.uia.mx/Courses/YVA1";

/* Tabla de pedidos por día /**/

proc sql;
	create table pedidos_por_dia_2016 as
	select Order_Date, count(distinct order_id) as pedidos
	from orion.customers
	where year(order_date)=2016
	group by 1;
quit;

title "Pedidos por día en diciembre 2016";
proc sgplot data=pedidos_por_dia_2016 (where=(month(order_date)=12));
  xaxis type=discrete;
  series x=Order_Date y=pedidos /datalabel;
run;
title;