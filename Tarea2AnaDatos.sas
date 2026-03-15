/* ============================================================================
   INCISO 1: Asignación de biblioteca con el nombre SMN
============================================================================ */
libname SMN "/export/viya/homes/a2259859@correo.uia.mx/Courses/VISUAL";


/* ============================================================================
   INCISO 2: Revisión de estructura general de la tabla 'na_hurricanes'
============================================================================ */
proc contents data=SMN.na_hurricanes order=varnum;
run;


/* ============================================================================
   INCISO 3: Creación del dataset eventos_maya_olmeca
   - Filtrado por región (Maya u Olmeca según coordenadas)
   - Velocidad máxima de viento > 50 mph
   - Variables: región, año y mes
============================================================================ */
data eventos_maya_olmeca;
    set SMN.na_hurricanes;

    /* Región por coordenadas */
    length region $6;
    if 18 <= to_lat <= 22 then do;
        if -89 <= to_lon <= -86 then region = "Maya";
        else if -97 <= to_lon <= -94 then region = "Olmeca";
    end;

    /* Filtro final por región válida y MaxWind mayor a 50 */
    if region ne "" and MaxWind > 50;

    /* Variables de fecha */
    year  = year(date);
    month = month(date);

   scatter x=MinPressure y=MaxWind / markerattrs=(symbol=circlefilled color=blue);
   reg x=MinPressure y=MaxWind / lineattrs=(color=red thickness=2);
   xaxis label="Presión Mínima (MinPressure)";
   yaxis label="Viento Máximo (MaxWind)";
   title "Correlación entre MaxWind y MinPressure";
run;
/* ============================================================================
   INCISO 4: Análisis de correlación entre MaxWind y MinPressure
============================================================================ */
proc corr data=eventos_maya_olmeca pearson nosimple;
    var MaxWind MinPressure;
run;


/* ============================================================================
   INCISO 5: Filtrado para quedarnos solo con el valor máximo por año y huracán
============================================================================ */
proc sort data=eventos_maya_olmeca
          out=eventos_maya_olmeca_max;
    by region name year maxwind;
run;

data eventos_maya_olmeca_max;
    set eventos_maya_olmeca_max;
    by region name year;
    if last.year;   /* Deja sólo el más intenso de cada huracán-año */
run;


/* ============================================================================
   INCISO 6: Consulta SQL para obtener el huracán más fuerte por región
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
   INCISO 7: Ajuste de normalidad de MaxWind por región con histograma
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
proc sgpanel data=eventos_maya_olmeca_v;
    panelby region type / novarname columns=2;
    vbar month / stat=freq;
    colaxis label='Mes';
    rowaxis label='Conteo';
    format month monname3.;
run;


/* ============================================================================
   INCISO 9 (a): ¿Qué mes tiene más actividad? (Conteo por región, tipo y mes)
============================================================================ */
proc sql;
    select region,
           type,
           month(date) as mes,
           count(*) as conteo
    from eventos_maya_olmeca
    group by region, type, calculated mes
    order by region, type, calculated mes;
quit;


/* ============================================================================
   INCISO 9 (b): ¿Hay combinación región-tipo sin un único mes máximo?
============================================================================ */
proc sql;
    create table max_por_region_tipo as
    select region,
           type,
           month(date) as mes,
           count(*) as conteo
    from eventos_maya_olmeca
    group by region, type, calculated mes;

    /* Extraer los meses con el valor máximo de conteo por cada región-tipo */
    create table meses_maximos as
    select a.*
    from max_por_region_tipo a
    where conteo = (select max(conteo)
                    from max_por_region_tipo b
                    where a.region = b.region and a.type = b.type)
    order by region, type;
quit;
