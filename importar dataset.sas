filename reffile filesrvc folderpath='/Users/p42526@correo.uia.mx/My Folder/Primavera 2025/Datos'  filename='clientes.csv';

proc import datafile= reffile
	dbms=csv
	out=work.clientes_1;
	getnames=yes;
run;