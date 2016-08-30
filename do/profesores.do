* Absentismo

* Switches
*-------------------------------------------------------------------------------

local import = 0 // fijar como 1 para importar todos los datos nuevamente

* Directorios raiz
*-------------------------------------------------------------------------------
// Alvaro personal:
if "`c(username)'" == "alvaro" {
	local path "/Users/Alvaro/Dropbox (Personal)/Proyectos/Absentismo 2/"
}
// Alvaro trabajo:
if "`c(username)'" == "alvaro.carril" {
	local path "C:/Users/alvaro.carril/Dropbox (Personal)/Proyectos/Absentismo 2/"
}
// Vale trabajo
if "`c(username)'" == "vparedeshaz" {
	local path "C:\Users\vparedeshaz\Dropbox\Absentismo 2\"
}	

cd "`path'"

* Crear base "profesores.dta" con todas las comunas
*-------------------------------------------------------------------------------
if `import' == 1 {
	local comunas : dir "data/comunas_digitadas" files "*.xlsx"
	foreach comuna in `comunas' {
		tempfile comunadta
		local rep = `rep'+1
		import excel "data/comunas_digitadas/`comuna'", ///
			sheet("Hoja1") firstrow clear allstring
		qui save `comunadta', replace
		if `rep' == 1 {
			save data/profesores.dta, replace
		}
		else {
			use data/profesores.dta, clear
			qui append using `comunadta'
			qui save data/profesores.dta, replace
		}
		di "`comuna' lista"
	}
}

*-------------------------------------------------------------------------------
* Limpiar base profesores
*-------------------------------------------------------------------------------
use data/profesores.dta, clear

drop J K L

* Comunas
*-------------------------------------------------------------------------------
replace comuna = proper(subinstr(comuna, "_", " ",.))
encode comuna, gen(comuna2) label(comuna)
rename (comuna comuna2) (comuna2 comuna)
drop comuna2
label define comuna 6 "Chillán", modify
label define comuna 26 "Peñaflor", modify
label define comuna 34 "San Pedro De La Paz", modify

* Fechas
*-------------------------------------------------------------------------------
gen date2 = date(date, "DMY")
format date2 %td
rename (date date2) (date2 date)
drop date2
gen year = year(date)
gen month = month(date)

* Asignatura
*-------------------------------------------------------------------------------
replace subject = "mat" if strpos(lower(subject), "mat")
replace subject = "leng" if strpos(lower(subject), "leng")
drop if subject != "mat" & subject != "leng"

* RBD
*-------------------------------------------------------------------------------
split rbd, p("-")
drop rbd
rename (rbd1 rbd2) (rbd rbd_dv)
destring rbd*, replace



