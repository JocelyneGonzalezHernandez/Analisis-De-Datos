/* Pregunta 1.a: Importar datos */
/* Código generado (IMPORT) */
/* Archivo de origen: University_Dataset_2014.csv */

/*1.B  Análisis exploratorio de las variables Athlete Sprint MileMinDur*/

proc means data=work.uni n nmiss mean std min max;
  var Athlete Sprint MileMinDur;
run;

/*1.C Crea un dataset rendimiento_atletico */
data rendimiento_atletico;
   set WORK.uni;
   where not missing(Sprint) and not missing(MileMinDur) and not missing(Height) and not missing(Weight);
   IMC = 703 * Weight / (Height ** 2);
   if IMC < 18.5 then Estado_IMC = "Bajo peso";
   else if IMC < 25 then Estado_IMC = "Normal";
   else if IMC < 30 then Estado_IMC = "Sobrepeso";
   else Estado_IMC = "Obesidad";
run;

/*1.e: Análisis de correlación */
proc corr data=rendimiento_atletico;
  var IMC Sprint MileMinDur;
run;
proc sgscatter data=rendimiento_atletico;
  matrix IMC Sprint MileMinDur / diagonal=(histogram) markerattrs=(symbol=circlefilled);
  title "Matriz de dispersión: IMC, Sprint y MileMinDur";
run;

/*1.f PERSONAS CON IMC MAYOR O IGUAL A 40*/
data imc_mayor_40;
   set rendimiento_atletico;
   where IMC >= 40;
run;

/*2-b*/

proc freq data=work.uni;
   where not missing(Writing);
   tables Gender;
run;

/*2. c*/
data calificaciones;
  set work.uni;
  if Writing ne .;
run;

proc sort data=calificaciones;
  by Gender;
run;

proc univariate data=calificaciones normal;
  by Gender;
  var Writing;
  histogram Writing / normal;
run;

/*2.d*/
proc ttest data=calificaciones;
  class Gender;
  var Writing;
run;


