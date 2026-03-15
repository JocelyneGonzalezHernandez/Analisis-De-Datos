/*1A*/
data work.simulacion_normales (drop=i);
    /* Parámetros para la distribución normal */
    mu = 0;  /* Media */
    sigma = 1; /* Desviacion estandar */

    /* Bucle para generar los registros */
    do i = 1 to 1000;
        e = rand('normal', mu, sigma);   /* Simulando la variable e */
        y = rand('normal', mu, sigma);   /* Simulando la variable y */
        W = e + y;                       /* Suma de e y y para obtener W */
        output;
    end;
run;

/* 1b - 1 */
proc univariate data=work.simulacion_normales;
    var W;
    histogram;  /* Histograma */
run;
proc sql;
    select count(*) as total_registros
    from work.simulacion_normales;
quit;
proc univariate data=work.simulacion_normales;
    var W;
    histogram;  /* Histograma */
    output out=summary_stats mean=media median=mediana q1=q1 q3=q3;
run;

/* Crear un boxplot*/
proc sgplot data=work.simulacion_normales;
    vbox W / boxwidth=0.5;
    yaxis label="W";
    title "Boxplot de la variable W";
run;

filename reffile filesrvc folderpath='/Users/a2253695@correo.uia.mx/Primavera 2025/' filename='Tiempos_de_atencion_banco.csv';

proc import datafile= reffile
	dbms=csv
	out=work.tiempos_atencion;
	getnames=yes;
run;




/* Probabilidad de exactamente 10 solicitudes durante 2 horas */
data poisson_2h;
    lambda = 8; /* 4 solicitudes por hora durante 2 horas */
    k = 10; /* Queremos la probabilidad de 10 solicitudes */
    poisson_prob = (lambda**k * exp(-lambda)) / fact(k); /* Fórmula de Poisson */
    put poisson_prob=;
run;

/* Probabilidad de que no dejen de atender durante la pausa de 30 miN*/
data poisson_30min;
    lambda_30min = 2; /* 4 solicitudes por hora durante 30 minutos */
    k_30min = 0; /* Probabilidad de 0 solicitudes */
    poisson_prob_30min = (lambda_30min**k_30min * exp(-lambda_30min)) / fact(k_30min);
    put poisson_prob_30min=;
run;

/* Probabilidad de que por lo menos 9 linternas funcionen */
data probabilidad_linternas;
    p = 0.9; /* Probabilidad de que una linterna funcione */
    n = 10; /* Total de linternas */
    
    /* P(X = 9) */
    P9 = pdf('binomial', 9, p**2, n);
    
    /* P(X = 10) */
    P10 = pdf('binomial', 10, p**2, n);
    
    /* P(X >= 9) = P9 + P10 */
    P_mayor_igual_9 = P9 + P10;
    
    output;
run;

proc print data=probabilidad_linternas; 
run;

