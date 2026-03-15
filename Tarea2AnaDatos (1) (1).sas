ods graphics on;
/* ============================================================================
   INCISO 1: Asignación de biblioteca con el nombre SMN
============================================================================ */
libname SMN "/export/viya/homes/a2253695@correo.uia.mx/Courses/VISUAL";



/* ============================================================================
   INCISO 2: Revisión de estructura general de la tabla 'na_hurricanes'
				y nombres de las columnas
============================================================================ */
proc contents data=SMN.na_hurricanes order=varnum;
run;

/* ============================================================================
   Creación del dataset "eventos_maya_olmeca"
   - Filtrado por región (Maya u Olmeca según coordenadas)
   - Velocidad máxima de viento > 50 mph
   - Variables: región, año y mes
	(esperamos ver 157 registros)
============================================================================ */
data eventos_maya_olmeca;
	/* Traemos el dataset completo*/
    set SMN.na_hurricanes; 

    /* FILTRO por coordenadas */
	/*Creamos columna "region" */
    length region $6;	 
	/*Filtramos la latitud (Misma para ambas zonas*/ 
    if 18 <= to_lat <= 22 then do;
		/*Filtramos por longitud (diferente para ambas)*/
        if -89 <= to_lon <= -86 then region = "Maya";
        else if -97 <= to_lon <= -94 then region = "Olmeca";
    end;

    /* FILTRO por MaxWind */
    if region ne "" and MaxWind > 50;

    /* Variables de fecha */
    year  = year(date);
    month = month(date);
run;



/* ============================================================================
   INCISO 3: Análisis de correlación entre MaxWind y MinPressure
============================================================================ */
proc corr data=eventos_maya_olmeca pearson nosimple;
    var MaxWind MinPressure;
run;

/*Ploteamos la correlación*/
proc sgplot data=eventos_maya_olmeca;
    title "Correlación entre MaxWind y MinPressure";

    /* Puntos */
    scatter x=MinPressure y=MaxWind /
            markerattrs=(symbol=circlefilled size=8 color=cx3daeff);

    /* Recta de regresión */
    reg     x=MinPressure y=MaxWind /
            degree=1    /* lineal */
            lineattrs=(color=red thickness=2);

    xaxis label="Presión mínima (MinPressure)";
    yaxis label="Viento máximo (MaxWind)";
run;



/* ============================================================================
   INCISO 4: Filtrado para quedarnos solo con el valor máximo por año y huracán
============================================================================ */
proc sort data=eventos_maya_olmeca /*Ordenamiento de - a +*/
          out=eventos_maya_olmeca_max; /*DataSet de salida*/
    by region name year maxwind;
/*
1. Se agrupa primero por región (Maya / Olmeca).
2. Dentro de cada región, agrupa por nombre de huracán (name).
3. Dentro del huracán, por año.
4. Finalmente ordena por MaxWind creciente.
*/
run;

data eventos_maya_olmeca_max;
    set eventos_maya_olmeca_max;
    by region name year;
    if last.year;   /* Deja sólo el más intenso de cada huracán-año */
run;
/*Plot para visualización de los años*/
proc sgplot data=eventos_maya_olmeca_max;
    title "Distribución de velocidades máximas por región";
    vbox MaxWind / category=region
                  fillattrs=(color=cx2c7cff) /* cambia colores si quieres */
                  lineattrs=(thickness=2);
    yaxis label='Viento máximo (mph)';
run;



/* ============================================================================
   INCISO 5: Consulta SQL para obtener el huracán más fuerte por región
============================================================================ */
proc sql;
    select region,
           name,
           year,
           MaxWind label="MaxWind (mph)"
    from   eventos_maya_olmeca_max a
    where  MaxWind = (select max(MaxWind)
                      from eventos_maya_olmeca_max b
                      where b.region = a.region)
    order  by region;
quit;



/* ============================================================================
   INCISO 6: Ajuste de normalidad de MaxWind por región con histograma
============================================================================ */
proc univariate data=eventos_maya_olmeca_max normal;
    by region;
    var MaxWind;
    histogram / normal;
run;



/* ============================================================================
   INCISO 7: Prueba de hipótesis de igualdad de medias de MaxWind por región
============================================================================ */
proc ttest data=eventos_maya_olmeca_max
           alpha=0.05 plots=none;
    class region;
    var   MaxWind;
run;



/* ============================================================================
   INCISO 8: Creación de vista ordenada por región, tipo y mes
   (Para su uso posterior en gráfica de barras)
============================================================================ */
proc sql;
    create view eventos_maya_olmeca_v as
    select *
    from   eventos_maya_olmeca
    order  by region, type, month;
quit;


/* ============================================================================
   INCISO 9: Gráfico de barras por mes, región y tipo (a partir de la vista)
============================================================================ */
proc freq data=eventos_maya_olmeca_v;
    tables region*type*month / plots=freqplot(twoway=stacked scale=percent);
run;