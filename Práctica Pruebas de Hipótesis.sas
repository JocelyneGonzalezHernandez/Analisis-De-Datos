/* Ejemplo slide 24, Prueba de hipótesis para la media de una población normal
con varianza poblacional sigma cuadrada desconocida /**/

/* Insertamos la data referente al ejercicio del productor de 
carne para hamburguesas /**/

data hormonas_hamburguesa;
   input concentracion @@;
   datalines;
18 22 21 19 18 17 19 20 22 20
;

/* En el procedimiento ttest especificamos 
1. Hipótesis nula: (media igual a 19) h0=19
2. Elección alpha=0.05: alpha=0.05
	NOTA 1: Pueden probar con distintas alphas para ver los resultados
3. Estadístico de prueba es elegido por el procedimiento de forma automática
4. Opción de Región Crítica (RC): (unilateral derecha) sides=U (significa upper)
	NOTA 2: Si queremos una RC bilateral podemos no poner parámetro o 
	  especificar sides=2. Si queremos una RC unilateral izquiarda especificar
	  sides=L (significa lower).
   Sin embargo SAS no otorga los valores le la frontera de la RC
5. Buscar el Valor t=1.11, como en la presentación si se saben los valores límites 
de la RC. Sin embargo es más fácil usar el criterio de Pr>t, que es mayor a alpha (0.05)
CONCLUSION: No se rechaza la hipótesis nula
/**/

proc ttest data=hormonas_hamburguesa h0=19 sides=U plots(showh0) alpha=0.05;
   var concentracion;
run;


/* OJO: En el slide 27 se hacen algunas observaciones mencionando que 
se debía subir el número de muestras para tal vez tener una menor probabilidad 
de error tipo 2. ESTO NO VENDRÁ EN EL EXAMEN, PERO EN SAS SE RESUELVE CON:/**/

proc power; 
  onesamplemeans test=t 
  nullmean = 19 /* media de la hipótesis nula /**/ 
  mean  = 19.5 /* media de la hipótesis alternativa (cualquier valor superior 
	a 19 hubiera servido según los datos del problema)/**/
  stddev = 1.7 /* desviación estándar (se toma la muestral) /**/
  power = .9 /* es 1-beta, ver slide 12 /**/
  ntotal = . /* lo que se desea estimar, es decir en este caso es la N /**/
  sides = U; /* tipo de prueba a hacer 2|L|U/**/
run;
 
/* Respuesta N=101, entonces el inspector tiene que usar 101 muestras para 
poder apreciar una diferencia en la media entre 19 y 19.5, si se escoge algo
más cercano a 19.0 en la alternativa se incrementa N /**/


/* Ejemplo slide 32. Prueba de hipótesis para las medias de dos poblaciones 
	normales con varianzas poblacionales desconocidas e iguales /**/

/* Insertamos la data referente al ejercicio de los caballos con 
y sin parásitos /**/

data caballos_sin_tratamiento;
   input rendimiento @@;
   datalines;
   28 32 28 26 31 24 32 23 33 29 29 34 34 25 33 25 34 30 31 37
;

data caballos_con_tratamiento;
   input rendimiento @@;
   datalines;
   38 28 34 28 33 32 34 28 35 31 33 35
;

/* NOTA: Es importante apilar los datos desde este punto poniendo primero al 
set de datos 2 (sin tratamiento) y luego al set de datos 1 (con tratamiento) 
ya que SAS simpre usa mu1-mu2 (mu primer grupo ingresado - mu segundo grupo 
ingresado), al contrario de los slides, donde las regiones se contruyen con mu2-mu1 /**/

proc sql;
	create table caballos as 
	select "sin tratamiento" length=15 as grupo, rendimiento
	from caballos_sin_tratamiento
	union all
	select "con tratamiento" length=15 as grupo, rendimiento
	from caballos_con_tratamiento	;

	drop table caballos_sin_tratamiento, caballos_con_tratamiento;
quit;

/* En el procedimiento ttest especificamos 
1. Hipótesis nula: (mu1-mu2=0) h0=0
2. Elección alpha=0.05: alpha=0.05
	NOTA 1: Pueden probar con distintas alphas para ver los resultados
3. Estadístico de prueba es elegido por el procedimiento de forma automática
4. Opción de Región Crítica (RC): (unilateral derecha) sides=U (significa upper)
	NOTA 2: Si queremos una RC bilateral podemos no poner parámetro o 
	  especificar sides=2. Si queremos una RC unilateral izquiarda especificar
	  sides=L (significa lower).
   Sin embargo SAS no otorga los valores le la frontera de la RC
5. Buscar el Valor t=-1.90, como en la presentación si se saben los valores límites 
de la RC. Sin embargo es más fácil usar el criterio de Pr<t, que es menor a alpha (0.05)
CONCLUSION: Se rechaza la hipótesis nula y se acepta la alternativa 
(como fue izquierda mu segundo grupo mayor a mu primer grupo)

Este mismo código hace la prueba de igualdad de varianzas en el último cuadro
/**/

proc ttest data=caballos h0=0 sides=L order=data plots(showh0) alpha=0.05;
	class grupo; /* se usa la variable grupo para distinguir entre las poblaciones */
	var rendimiento; /* variable de la que se comparan las medias */
run;

