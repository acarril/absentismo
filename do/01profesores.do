*===============================================================================
* Absentismo
* 01profesores.do
*===============================================================================

* Switches
*-------------------------------------------------------------------------------

local import = 0 // fijar como 1 para importar todos los datos nuevamente

* Directorios
*-------------------------------------------------------------------------------
// Alvaro personal:
if "`c(username)'" == "alvaro" cd "/Users/Alvaro/Dropbox (Personal)/Proyectos/Absentismo 2/"
// Alvaro trabajo:
if "`c(username)'" == "Alvaro" {
	local path "D:\Users\Alvaro\Dropbox (Personal)\Proyectos\Absentismo 2/"
}
// Vale trabajo
if "`c(username)'" == "vparedeshaz" {
	local path "C:\Users\vparedeshaz\Dropbox\Absentismo 2\"
}	
// Vale casa
if "`c(username)'" == "vparedes" {
	local path "C:\Users\vparedes\Dropbox\Absentismo 2\"
}
cd "`path'"

* Crear base "profesores_raw.dta" con todas las comunas
*-------------------------------------------------------------------------------
if `import' == 1 {
	local comunas : dir "input/comunas_digitadas" files "*.xlsx"
	foreach comuna in `comunas' {
		tempfile comunadta
		local rep = `rep'+1
		import excel "input/comunas_digitadas/`comuna'", ///
			sheet("Hoja1") firstrow clear allstring
		qui save `comunadta', replace
		if `rep' == 1 {
			save output/profesores_raw.dta, replace
		}
		else {
			use output/profesores_raw.dta, clear
			qui append using `comunadta'
			qui save output/profesores_raw.dta, replace
		}
		di as text "Comuna `comuna' ok"
	}
}

*-------------------------------------------------------------------------------
* Limpiar base profesores_raw
*-------------------------------------------------------------------------------
use output/profesores_raw.dta, clear
drop J K L

* Recuperar algunos rbds
*-------------------------------------------------------------------------------
// Obtenidos de http://www.cmds.cl/index.php/educacion/educacion-media.html
replace rbd ="280"   if comuna =="Antofagasta" & inlist(observacionesdigitación,"Sin RBD A-12")
replace rbd ="283"   if comuna =="Antofagasta" & inlist(observacionesdigitación,"A-14")
replace rbd ="284"   if comuna =="Antofagasta" & inlist(observacionesdigitación,"A-15")
replace rbd ="279"   if comuna =="Antofagasta" & inlist(observacionesdigitación,"A-16")
replace rbd ="285"   if comuna =="Antofagasta" & inlist(observacionesdigitación,"A-17")
replace rbd ="286"   if comuna =="Antofagasta" & inlist(observacionesdigitación,"A-22")
replace rbd ="10968" if comuna =="Antofagasta" & inlist(observacionesdigitación,"A-26")
replace rbd ="31345" if comuna =="Antofagasta" & inlist(observacionesdigitación,"A-33")
replace rbd ="304"   if comuna =="Antofagasta" & inlist(observacionesdigitación,"B-29")

replace rbd="10666" if comuna=="Paine" & observacionesdigitación == `"SIN RBD "GREGORIO MORALES MIRANDA""'

* Nombre profesor
*-------------------------------------------------------------------------------
replace name=strtrim(name) // eliminar blanks adelante y atras
replace name = ustrtitle(name) // titlecase en unicode
encode name, gen(profesor) label(profesores)
drop name

* Comuna
*-------------------------------------------------------------------------------
replace comuna = ustrtitle(usubinstr(comuna, "_", " ",.))
encode comuna, gen(comuna2) label(comuna)
rename (comuna comuna2) (comuna2 comuna)
drop comuna2
label define comuna 6 "Chillán", modify
label define comuna 26 "Peñaflor", modify
label define comuna 34 "San Pedro De La Paz", modify
lab var comuna "Comuna"

* RBD
*-------------------------------------------------------------------------------
replace rbd = usubinstr(rbd, ".", "",.) // quitar puntos de algunos rbd
split rbd, p("-") // dividir en el digito verificador
drop rbd
rename (rbd1 rbd2) (rbd rbd_dv)
destring rbd*, replace
lab var rbd "RBD"
lab var rbd_dv "RBD digito verificador"

* Letra curso
*-------------------------------------------------------------------------------
* Generar lista de caracteres 'raros' a remover
charlist letter // identificar caracteres ASCII en la variable
	local ascii `r(ascii)'
numlist "65/90" // letras ASCII
	local numlist `r(numlist)' 32 45 // agregar espacio y "-"
local badcodes : list ascii - numlist // caracteres a eliminar

* Generar nueva variable sin caracteres 'raros'
gen letras = letter
drop letter
foreach ascii_code of local badcodes {
	replace letras = subinstr(letras, char(`ascii_code'), "", .) // quitar caracteres raros
}
replace letras = subinstr(letras, char(45), " ", .) // reemplazar "-" por espacio

* Quitar "MAD", "MEC" y "MEDIO ADULTO":
replace letras = subinstr(letras, "MAD", " ", .)
replace letras = subinstr(letras, "MEC", " ", .)
replace letras = subinstr(letras, "MEDIO ADULTO", " ", .)

* Quitar espacios
replace letras = stritrim(letras)
replace letras = ustrtrim(letras)

* SUPUESTO: imputar letra de curso "A" cuando hay RBD pero no hay letra
replace letras = "A" if !mi(rbd) & letras == ""

* Asignatura
*-------------------------------------------------------------------------------
replace subject = "mat" if strpos(lower(subject), "mat")
replace subject = "leng" if strpos(lower(subject), "leng")
drop if subject != "mat" & subject != "leng"
encode subject, gen(asignatura)
lab var asignatura "Asignatura"
drop subject

* Fecha
*-------------------------------------------------------------------------------
gen fecha = date(date, "DMY")
format fecha %td
drop date
lab var fecha "Fecha"

* Codigo y motivos
*-------------------------------------------------------------------------------
replace code = "Permiso" if strpos(code, "P")
replace code = "Licencia" if strpos(code, "L")
replace code = "Movilizacion" if strpos(code, "M")
replace code = "" if code != "Permiso" & code != "Licencia" & code != "Movilizacion"

* Discrepancias entre codigo y motivos
replace code = "Licencia" if code == "Permiso" & motivos == "L" // suponiendo que permiso por licencia es licencia
replace code = "Movilizacion" if code == "Licencia" & motivos == "M" // suponiendo que licencia por movilizacion es movilizacion

* Completar codigo si esta vacio y hay motivo que lo indique
replace code = "Permiso" if code == "" & ///
	motivos == "P" | ///
	motivos == "P (1/2)" | ///
	motivos == "P(1/2)"
	
replace code = "Licencia" if code == "" & ///
	motivos == "L"

replace code = "Movilizacion" if code == "" & ///
	motivos == "L/M" | ///
	motivos == "M" | ///
	motivos == "M/P"
	
encode code, gen(motivo) // codificar "code"
gen byte presente = (mi(motivo) & mi(motivos)) // dummy presente
gen byte ausente = (!mi(motivo) | !mi(motivos)) // dummy ausente
drop code motivos // botar strings

* Observacion
*-------------------------------------------------------------------------------
rename observacionesdigitación detalle
order detalle, last
drop observ*

* Guardar
*-------------------------------------------------------------------------------
compress
save output/profesores, replace


*-------------------------------------------------------------------------------
* Crear base de absentismo profesores colapsada por año
*-------------------------------------------------------------------------------

use output/profesores, clear

// Generar año
gen agno = year(fecha)
lab var agno "Año"

// Colapsar ausencias por año
collapse (sum) ausente , by(letras rbd agno asignatura)

// Generar id RBD + letra curso
split letras, generate(_) parse(" ")
foreach v of varlist _* {
	egen id`v' = concat(rbd `v') if `v' != "" & !mi(rbd)
	drop `v'
}

// Eliminar a profes sin rbd, asignatura, letra o año
drop if mi(rbd) | mi(asignatura) | letras=="" | mi(agno)

// Convertir a wide en asignatura
reshape wide ausente, i(rbd letras agno) j(asignatura)
rename (ausente1 ausente2) (ausencias_lect ausencias_mate)

// Guardar base colapsada
compress
save output/profesores_colapsada, replace
