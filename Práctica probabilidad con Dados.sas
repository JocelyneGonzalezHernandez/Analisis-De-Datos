/*Simulemos la salida de un dado, tirado 50 veces/**/

data dados (drop=i x);
do i= 1 to 50;
	x=rand("uniform");
	if x le 1/6 then dado1=1;
	else if x le 2/6 then dado1=2;
	else if x le 3/6 then dado1=3;
	else if x le 4/6 then dado1=4;
	else if x le 5/6 then dado1=5;
	else dado1=6;
	output;
end;
run;

/*Simulemos la salida de dos dados, y definamos a X como la 
variable aleatoria que suma las salidas de cada tirada de dados,
repetiremos el experimento 5000 veces /**/

data dados (drop= i x y);
do i= 1 to 5000;
	x=rand("uniform");
	if x le 1/6 then dado1=1;
	else if x le 2/6 then dado1=2;
	else if x le 3/6 then dado1=3;
	else if x le 4/6 then dado1=4;
	else if x le 5/6 then dado1=5;
	else dado1=6;

	y=rand("uniform");
	if y le 1/6 then dado2=1;
	else if y le 2/6 then dado2=2;
	else if y le 3/6 then dado2=3;
	else if y le 4/6 then dado2=4;
	else if y le 5/6 then dado2=5;
	else dado2=6;

	suma_dados=dado1+dado2;	
	output;
	
end;
run;

/*Revisemos las salidas del proc freq y univariate para revisar cómo,
a medida de que subimos el número de repeticiones, las frecuencias
observadas tienden a la probabilidad del evento /**/ 

proc freq data= dados;
	tables suma_dados;
run;

proc univariate data= dados;
	var suma_dados;
	histogram;
run;