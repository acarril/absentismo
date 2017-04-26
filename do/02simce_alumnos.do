*===============================================================================
* Absentismo
* 02simce_alumnos.do
*===============================================================================

* Directorios
*-------------------------------------------------------------------------------
// Alvaro personal:
if "`c(username)'" == "alvaro" cd "/Users/Alvaro/Dropbox (Personal)/Proyectos/Absentismo 2/"
// Alvaro trabajo:
if "`c(username)'" == "Alvaro" cd "D:\Users\Alvaro\Dropbox (Personal)\Proyectos\Absentismo 2/"
// Vale trabajo
if "`c(username)'" == "vparedeshaz" cd "C:\Users\vparedeshaz\Dropbox\Absentismo 2\"
// Vale casa
if "`c(username)'" == "vparedes" cd "C:\Users\vparedes\Dropbox\Absentismo 2\"


* Base alumnos
*-------------------------------------------------------------------------------

// Unir SIMCE 2012-2014
use "input/simce2m2012/Archivos DTA (Stata)/simce2m2012_alu_publica_final.dta", clear
append using "input/simce2m2013/Archivos DTA (Stata)/simce2m2013_alu_publica_final.dta"
append using "input/simce2m2014/simce2m2014_alu.dta"

// Generar id RBD + letra curso
egen id = concat(rbd letra_curso) if letra_curso != "" & !mi(rbd)

// Consolidar variables de distinto nombre en el 2014
foreach cat in ptje eem noptje {
	foreach asig in lect mate {
		replace `cat'_`asig' = `cat'_`asig'2m_alu if agno != 2014
	}
}
drop *2m_alu
save output/alumnos_raw, replace


* Pegar SIMCE alumnos con base colapsada de absentismo de profesores
*-------------------------------------------------------------------------------
use output/profesores_colapsada, clear

gen aux = ustrlen(usubinstr(letras," ","",.))
qui summ aux
qui drop aux
forvalues i = 1/`r(max)' {
	use output/profesores_colapsada, clear
	collapse (sum) ausencias_* , by(agno id_`i')
	save output/profesores_colapsada_`i', replace
	
	if `i' == 1 use output/alumnos_raw, clear
	else use output/alumnos, clear
	gen id_`i' = id
	merge m:1 agno id_`i' using output/profesores_colapsada_`i', ///
		gen(_merge`i') update
	rm output/profesores_colapsada_`i'.dta
	drop id_`i'
	save output/alumnos, replace
}
rm output/alumnos_raw.dta // eliminar base auxiliar

* Codificar letra curso
*-------------------------------------------------------------------------------
/*
rename letra_curso letra_curso_str
encode letra_curso_str, gen(letra_curso)
drop letra_curso_str
*/
order letra_curso, after(dvrbd)
lab var letra_curso "Letra curso"

* Etiquetar valores noptje_*
*-------------------------------------------------------------------------------
lab var noptje_lect "Observación no puntaje SIMCE lectura"
lab var noptje_mate "Observación no puntaje SIMCE matemáticas"
lab var noptje_nat "Observación no puntaje SIMCE ciencias"
label define noptje ///
	0 "Con puntaje" ///
	1 "Sin puntaje por inasistencia" ///
	2 "Sin puntaje por prueba nula" ///
	3 "Sin puntaje por estudiante retirado" ///
	4 "Sin puntaje por perdida de material" ///
	5 "Sin puntaje por no rinde la prueba [sic]" ///
	6 "Sin puntaje por estudiante eximido (Ed. física)" ///
	7 "Sin puntaje por ser estudiante integrado" ///
	8 "Prueba en blanco"
label values noptje_* noptje

* Limpiar, etiquetar
*-------------------------------------------------------------------------------
drop *_bbdd grado id // variables innecesarias
drop eem_* eda_* // vars de variablilidad y estandar de aprendizaje (categorica)
lab var agno "Año"
lab var mrun "Identificador único MINEDUC (longitudinal)"
lab var idalumno "Identificador único SIMCE (transversal)"
lab var gen_alu "Género alumno"
lab var dvrbd "Dígito verificador RBD"
lab var cod_curso "Código curso (cuestionario docente)"
lab var ausencias_lect "Inasistencias profesor lectura"
lab var ausencias_mate "Inasistencias profesor matemáticas"
lab var ptje_lect "Puntaje SIMCE lectura"
lab var ptje_mate "Puntaje SIMCE matemáticas"
lab var ptje_nat "Puntaje SIMCE ciencias"


* Solamente mantener observaciones con ausencias
*-------------------------------------------------------------------------------

// Eliminar a los que solo están en la base SIMCE
* drop if mi(ausencias_lect) & mi(ausencias_mate) // equivalente a la de abajo
*drop if _merge1==1 & _merge2==1 & _merge3==1 & _merge4==1 & _merge5==1 & ///
*	_merge6==1 & _merge7==1

// Eliminar a los que solo están en nuestra base (hay que chequear por qué ocurre esto):
*drop if _merge1==2 | _merge2==2 & _merge3==2 | _merge4==2 | _merge5==2 | ///
*	_merge6==2 | _merge7==2

drop _merge*

drop if mi(idalumno)

save output/alumnos, replace
