/*************PROYECTO FINAL*************/



/****************************************
1.- Set de datos a usar: sashelp.cars
*****************************************/
data tabla_cars;
   set sashelp.cars;
run;





/****************************************
2. Analisis explortorio
*****************************************/
proc contents data=tabla_cars;
run;
/*15 variables*/
/*1. Make        Marca del automóvil          */ 
/*2. Model       Modelo específico            */ 
/*7. Invoice     Precio de factura            */ 
/*8. EngineSize  Tamaño del motor (L)         */ 
/*9. Cylinders   Número de cilindros          */ 
/*10. Horsepower Potencia del motor (HP)      */ 
/*11. MPG_City   Rendimiento en ciudad        */ 
/*12. MPG_Highway Rendimiento en carretera    */ 
/*13. Weight     Peso del automóvil (LBS)     */ 
/*14. Wheelbase  Distancia entre ejes (IN)    */ 
/*15. Length     Longitud del automóvil (IN)  */ 

/*Analisis general de variables numericas*/
proc means data=tabla_cars n mean median std min max maxdec=2;
    var MSRP Invoice EngineSize Cylinders Horsepower MPG_City MPG_Highway Weight Wheelbase Length;
run;

/*Analisis general de variables categoricas*/
proc freq data=tabla_cars;
    tables Make Type Origin DriveTrain;
run;





/****************************************
3. Preparación de datos
*****************************************/
%let seed = 12345; /*Fijamos una semila*/
/*Separacion de datos 90% entrenamiento y 10% prueba*/
proc surveyselect data=tabla_cars
    out=tabla_cars_muestras
    samprate=0.9         /* 90% para entrenamiento */
    seed=&seed
    outall;              /* Mantiene un flag para identificar las muestras */
run;

/* Separar las muestras en dos datasets: Entrenamiento y Prueba */
data train test;
    set tabla_cars_muestras;
    if selected = 1 then output train;  /* 90% para entrenamiento */
    else output test;                   /* 10% para prueba */
run;





/****************************************
4. Modelos basicos
*****************************************/
/*FORWARD*/
proc reg data=train plots(unpack label)=(diagnostics cooksd residuals);
   id model;
   model Invoice = Cylinders EngineSize Horsepower Length MPG_City
                   MPG_Highway Weight Wheelbase
                   / selection=forward details=summary;
   store out=work.mod_base_forward;
run;

/*IMPRIMIR PESOS*/
proc reg data=train plots=none;
   id model;
   model Invoice = Cylinders EngineSize Horsepower Length MPG_City
                   MPG_Highway Weight Wheelbase
                   / selection=forward  details=summary
                     stb;              
run;
quit;

/*Usa las 8 variables:
#1 Horsepower 
#2 Wheelbase
#3 Cylinders
#4 EngineSize
#5 Weight
#6 MPG_Highway
#7 MPG_City
#8 Length
Apartir de #6 el C(p) y el R^2 se estanca y las variables #7 y #8
No muestran una mejora considerable
C(P) = 9.0000
R^2  = 0.7565*/


/*STEPWISE*/
proc reg data=train plots(unpack label)=(diagnostics cooksd residuals);
   id model;
   model Invoice = Cylinders EngineSize Horsepower Length MPG_City
                   MPG_Highway Weight Wheelbase
                   / selection=stepwise details=summary;
   store out=work.mod_base_stepwise;
run;
/*IMPRIMIR PESOS*/
proc reg data=train plots=none;
   id model;
   model Invoice = Cylinders EngineSize Horsepower Length MPG_City
                   MPG_Highway Weight Wheelbase
                   / selection=stepwise details=summary
                     stb;              
run;
quit;
/*Usa las 6 variables:
#1 Horsepower 
#2 Wheelbase
#3 Cylinders
#4 EngineSize
#5 Weight
#6 MPG_Highway
Usando menos variables da un modelo similar que con forward
C(P) = 9.0617
R^2  = 0.7538*/


/*BACKWARD*/
proc reg data=train plots(unpack label)=(diagnostics cooksd residuals);
   id model;
   model Invoice = Cylinders EngineSize Horsepower Length MPG_City
                   MPG_Highway Weight Wheelbase
                   / selection=backward;
   store out=work.mod_base_backward;
run;

/*IMPRIMIR PESOS*/
proc reg data=train plots=none;
   id model;
   model Invoice = Cylinders EngineSize Horsepower Length MPG_City
                   MPG_Highway Weight Wheelbase
                   / selection=backward  details=summary
                     stb;              
run;
quit;

/*
C(P) = 9.0000
R^2  = 0.7565*/






/****************************************
2. Segundo analisis explortorio
*****************************************/
/*Descubrimiento: la variable Invoice se ajusta a una lognormal
Pvalor > 0.15*/
proc univariate data=train; 
	var Invoice; 	
	histogram /lognormal; 
run;

/*Creamos un nuevo data set con variables transformadas*/
/*Tras varias iteraciones, solo transformaremos 2 variables*/
data train_t;
   set train;
   lnInvoice = log(Invoice);
   lnWeight = log(Weight);
run;

/*Antes y despues del WEIGHT con LnInvoice*/
proc sgscatter data=train_t;
   compare y = lnInvoice
           x = (Weight lnWeight)
           / reg   /* línea de regresión */
             loess /* curva suavizada */
             grid;
   title "Antes y después de la transformación";
run;
/*Antes y despues del WEIGHT con Invoice*/
proc sgscatter data=train_t;
   compare y = Invoice
           x = (Weight lnWeight)
           / reg   /* línea de regresión */
             loess /* curva suavizada */
             grid;
   title "Antes y después de la transformación";
run;


/*Entrenamos un nuevo modelo con las transformaciones*/
proc reg data=train_t plots(unpack label)=(diagnostics cooksd residuals);
   id model;
   model lnInvoice = Cylinders EngineSize Horsepower lnWeight MPG_Highway Wheelbase
                     / selection=stepwise;
   store out=work.mod_log;
run;
/*IMPRIMIR PESOS*/
proc reg data=train_t plots=none;
   id model;
   model lnInvoice = Cylinders EngineSize Horsepower lnWeight MPG_Highway Wheelbase
                     / selection=stepwise details=summary
                     stb;              
run;
quit;
/*Usa las 6 variables:
#1 Horsepower 
#2 lnWeight 
#3 Wheelbase 
#4 MPG_Highway
#5 EngineSize
#6 Cylinders
Usando solo 6 variables y transformando 2 de ellas, obtenemos:
C(P) = 7.0000
R^2  = 0.8008*/






/****************************************
5. Detección de outlayers
*****************************************/
/*
Antes del segundo analisis exploratorio los outlayers peligrosos
para el modelo STEPWISE basico, eran 5:
- SL55 AMG 2dr
- CL600 2dr
- SL600 convertible 2dr
- LX 470
- GTO 2dr
*/


/*
Despues de las tranformaciones y de obtener el nuevo modelo
los outlayers son:
- Phaenton W12 4dr
/*Se tomó la desicion de no excluir ningun outlayer*/
*/

/*Código para ver los outlayers*/
proc sql;
   select *
   from tabla_cars
   where (Model like "%SL55%") 
	or (Model like "%CL600%") 
	or (Model like "%SL600%")
	or (Model like "%LX 470")
	or (Model like "%GTO%");
quit;





/****************************************
6. Evaluación de los modelos
*****************************************/
/*MODELOS:
work.mod_base_forward		C(P) = 9.0000	R^2  = 0.7565
work.mod_base_stepwise		C(P) = 9.0617	R^2  = 0.7538
work.mod_log 				C(P) = 7.0000	R^2  = 0.8008*/

data test_t;
   set test;
   lnInvoice = log(Invoice);
   lnWeight  = log(Weight);
   drop Weight;       
run;

proc reg data=train_t;
   id model;
   model lnInvoice = Cylinders EngineSize Horsepower lnWeight MPG_Highway Wheelbase
                     / selection=stepwise;
   store out=work.mod_log;          /* guarda NUEVO modelo */
run;


/****** 1.1 Forward ******/
proc plm restore=work.mod_base_forward;
   score data=test out=out_fwd
         predicted=pred_fwd residual=res_fwd;
run;

/****** 1.2 Stepwise ******/
proc plm restore=work.mod_base_stepwise;
   score data=test out=out_step
         predicted=pred_step residual=res_step;
run;

/****** 1.3 Backward ******/
proc plm restore=work.mod_base_backward;
   score data=test out=out_bwd
         predicted=pred_bwd residual=res_bwd;
run;

/****** 1.4 Modelo log (predice lnInvoice) ******/
proc plm restore=work.mod_log;
   score data=test_t out=out_logs
         predicted=lnPred;        
run;

/* Regresar a escala original y recalcular residual */
data out_log;
   set out_logs;
   pred_log = exp(lnPred);
   res_log  = Invoice - pred_log;
run;





data out_fwd;   set out_fwd   (rename=(pred_fwd=predicted res_fwd=residual));  model="Forward";  run;
data out_step;  set out_step  (rename=(pred_step=predicted res_step=residual)); model="Stepwise"; run;
data out_bwd;   set out_bwd   (rename=(pred_bwd=predicted res_bwd=residual));  model="Backward";  run;
data out_log;   set out_log   (rename=(pred_log=predicted res_log=residual));   model="Log";      run;

data union_all;
   set out_fwd out_bwd out_step out_log;
run;



proc sgpanel data=union_all;
   panelby model / columns=3 rows=1 novarname;

   /* 1. Observados (rojo) */
   scatter x=Invoice y=Invoice /
           markerattrs=(color=red symbol=circlefilled size=7)
           name='obs' legendlabel='Observado';

   /* 2. Predichos (azul) */
   scatter x=Invoice y=predicted /
           markerattrs=(color=cx4682B4 symbol=circlefilled size=5)
           transparency=0.25
           name='pred' legendlabel='Predicho';

   /* Línea identidad */
   lineparm x=0 y=0 slope=1 / lineattrs=(color=gray);

   colaxis label='Observado (Invoice $)';
   rowaxis label='Predicho ($)';
   keylegend 'obs' 'pred' / position=bottom across=2;
   title "Observed (rojo) vs. Predicted (azul) — Forward | Log | Stepwise";
run;




proc univariate data=union_all normal plots;
   where model = "Forward" and residual < 30000; /* <-- Cambia a Stepwise o Log */
   var residual;
   histogram residual / normal;
run;

proc univariate data=union_all normal plots;
   where model = "Backward" and residual < 30000; /* <-- Cambia a Stepwise o Log */
   var residual;
   histogram residual / normal;
run;

proc univariate data=union_all normal plots;
   where model = "Stepwise" and residual < 30000;               /* <-- Cambia a Stepwise o Log */
   var residual;
   histogram residual / normal;
run;
proc univariate data=union_all normal plots;
   where model = "Log" and residual < 30000;               /* <-- Cambia a Stepwise o Log */
   var residual;
   histogram residual / normal;
run;