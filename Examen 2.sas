/*1. */
/* a) 	Genera un set de datos work.simulacion_normales que contenga las siguientes variables:
   - X= N(3,16)
   - Y= N(2,9)
   - W= X + Y.
*/

data work.simulacion_normales (drop=i); /*Se elimina la variable auxiliar*/
    do i = 1 to 1000; 
        X = rand('normal', 3, sqrt(16)); /* X= N(3, 16) */
        Y = rand('normal', 2, sqrt(9));  /* Y= N(2, 9) */
        W = X + Y;
        output;
    end;
run;

/* Validar los resultados con un análisis descriptivo */
proc means data=work.simulacion_normales mean std min max;
    var X Y W;
run;

proc univariate data=work.simulacion_normales;
    histogram X Y W / normal;
    ods select histogram;
run;

/*b) Ajustar una distribución normal para W y realizar la prueba Kolmogorov-Smirnov */
proc univariate data=work.simulacion_normales;
    var W;
    histogram W / normal;
    inset mean std / format=6.2 position=ne;
    probplot W / normal(mu=est sigma=est); /* Función de distribución ajustada */
    ods select GoodnessOfFit;
run;

/*c) Media y desviación estándar de W. 
Intervalos de confanza de 90% y 95% */
proc means data=work.simulacion_normales mean std clm alpha=0.10; /* 90% */
    var W;
    ods output Summary=conf90; /* Guardar resultados */
run;

proc means data=work.simulacion_normales mean std clm alpha=0.05; /* 95% */
    var W;
    ods output Summary=conf95; /* Guardar resultados */
run;

/* Gráfico de densidad */
proc sgplot data=work.simulacion_normales;
    density W / type=kernel;
    density W / type=normal;
run;

/*2 */
/*a) Verificación de importación de Tiempos_de_atencion */
proc print data=work.Tiempos_de_atencion(obs=100);
run;

/*b) Análisis exploratorio */
/*Aquí se calcula la media, mediana, etc. Se analiza el tiempo*/
proc means data=work.Tiempos_de_atencion mean median std min max q1 q3;
    var tiempo;
run;

/* Gráfico de distribución */
proc univariate data=work.Tiempos_de_atencion;
    var tiempo;
    histogram tiempo; 
run;

/* Boxplot */
proc sgplot data=work.Tiempos_de_atencion;
    vbox tiempo / datalabel=tiempo;
run;

/*c) Ajusta una normal y una exponencial los datos */
proc univariate data=work.Tiempos_de_atencion;
    var tiempo;
    histogram tiempo / normal; /* Ajusta a una grafica normal */
    inset mean std / position=ne;
    probplot tiempo / normal(mu=est sigma=est); 
run;

proc univariate data=work.Tiempos_de_atencion;
    var tiempo;
    histogram tiempo / exponential; /* Ajusta a una exponencial */
    inset mean / position=ne;
    probplot tiempo / exponential(scale=est);
run;

/*3. Distribución Poisson. Madrigueras*/
/* Calcular probabilidades para diferentes casos */
data probabilidades;
    landa = 2;
    /* a) P(X = 0): Probabilidad de que no haya madrigueras */
    p0 = pdf('poisson', 0, landa);

    /* b) P(X < 7) */
    pmenor7 = cdf('poisson', 6, landa);

    /* c) P(X > 5) */
    pmayor5 = 1 - cdf('poisson', 5, landa);

    /* d) Que en 2 hect no haya madrigueras */
    landa2hect = 2 * landa;
    p0_2hect = pdf('poisson', 0, landa2hect);

    output;
run;

proc print data=probabilidades noobs;
    var p0 pmenor7 pmayor5 p0_2hect;
    label p0 = "P(X = 0, 1 ha)"
          pmenor7 = "P(X < 7, 1 ha)"
          pmayor5 = "P(X > 5, 1 ha)"
          p0_2hect = "P(X = 0, 2 ha)";
run;

/*4. Coches "antiguos" */
/*a) Medias Asia vs USA */
proc sql;
    create table cars_asia_usa as
    select 'Asia' as Origin length=10, MSRP
    from sashelp.cars
    where Origin = 'Asia'
    union all
    select 'USA' as Origin length=10, MSRP
    from sashelp.cars
    where Origin = 'USA';
quit;

/* Prueba de hipótesis */
proc ttest data=cars_asia_usa h0=0 sides=2 alpha=0.05;
    class Origin;
    var MSRP;
run;

/* b) Medias entre Sedan de Europa y USA */
/* Se apila primero Europa y luego USA */
proc sql;
    create table cars_sedan_europe_usa as
    select 'Europe' as Origin length=10, MSRP
    from sashelp.cars
    where Type = 'Sedan' and Origin = 'Europe'
    union all
    select 'USA' as Origin length=10, MSRP
    from sashelp.cars
    where Type = 'Sedan' and Origin = 'USA';
quit;

/* Prueba de hipótesis */
proc ttest data=cars_sedan_europe_usa h0=0 sides=2 alpha=0.05;
    class Origin;
    var MSRP;
run;

