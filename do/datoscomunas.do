* Datos Absentismo

clear all
set more off
global os "VP"


if "$os"=="VP" {
global bases "C:\Users\vparedeshaz\Dropbox\Absentismo 2\Data\comunas_digitadas\"
global productos "C:\Users\vparedeshaz\Dropbox\Absentismo 2\Data\comunas_dta\"
	}
else if "$os"=="TC" {
global bases "poner aca el directorio de las bases de insumo"
global productos "poner aca el directorio de las bases de producto"
	}


foreach x in "Antofagasta" "Cabrero" "Calera_Tango" "Castro." "Cerro_Navia" "Chillan" "Cochrane" "Colina" "Concepcion." "Contulmo." "Coronel" "Gorbea" "La_Granja" "La_Serena" "LaCisterna" "Linares" "Lo_Espejo" "LosAndes" "Macul" "Maipu" "Osorno" "Ovalle." "Paine" "Panguipulli" "Parral" "Peñaflor" "Puerto_Montt" "Rengo" "RioBueno" "San_Bernardo" "San_Felipe" "San_Joaquin" "SanCarlos" "SanPedroDeLaPaz" "Santa_Cruz" "Tal_Tal" "Tome" "Vitacura"{
import excel "$bases\`x'.xlsx", sheet("Hoja1") firstrow clear
tostring name comuna rbd subject date letter code motivos observaciones, replace
rename observaciones observaciones
save "$productos\`x'.dta", replace 
}  

foreach x in "Antofagasta" "Cabrero" "Calera_Tango" "Castro." "Cerro_Navia" "Chillan" "Cochrane" "Colina" "Concepcion." "Contulmo." "Coronel" "Gorbea" "La_Granja" "La_Serena" "LaCisterna" "Linares" "Lo_Espejo" "LosAndes" "Macul" "Maipu" "Osorno" "Ovalle." "Paine" "Panguipulli" "Parral" "Peñaflor" "Puerto_Montt" "Rengo" "RioBueno" "San_Bernardo" "San_Felipe" "San_Joaquin" "SanCarlos" "SanPedroDeLaPaz" "Santa_Cruz" "Tal_Tal" "Tome" {
append using "$productos\`x'.dta"
}
