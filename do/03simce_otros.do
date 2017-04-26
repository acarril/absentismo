*===============================================================================
* Absentismo
* 03simce_otros.do
*===============================================================================

* Directorios
*-------------------------------------------------------------------------------
// Alvaro personal:
if "`c(username)'" == "alvaro" {
	cd "/Users/Alvaro/Dropbox (Personal)/Proyectos/Absentismo 2/"
}
// Alvaro trabajo:
if "`c(username)'" == "Alvaro" {
	cd "D:\Users\Alvaro\Dropbox (Personal)\Proyectos\Absentismo 2/"
}
// Vale trabajo
if "`c(username)'" == "vparedeshaz" {
	cd "C:\Users\vparedeshaz\Dropbox\Absentismo 2\"
}	
// Vale casa
if "`c(username)'" == "vparedes" {
	cd "C:\Users\vparedes\Dropbox\Absentismo 2\"
}

* Cuestionario alumnos
*-------------------------------------------------------------------------------

// Unir 2012-2014
use "input/simce2m2012/Archivos DTA (Stata)/simce2m2012_cest_publica_final.dta", clear
append using "input/simce2m2013/Archivos DTA (Stata)/simce2m2013_cest_publica_final.dta"
append using "input/simce2m2014/simce2m2014_cest.dta"

// Unir con base alumnos
tempfile cest
save `cest', replace
use output/alumnos, clear
merge 1:1 agno idalumno using `cest', gen(_merge_cest) keepus(cest*)
save output/base_absentismo, replace


* Cuestionario padres
*-------------------------------------------------------------------------------

// Unir 2012-2014
use "input/simce2m2012/Archivos DTA (Stata)/simce2m2012_cpad_publica_final.dta", clear
append using "input/simce2m2013/Archivos DTA (Stata)/simce2m2013_cpad_publica_final.dta"
append using "input/simce2m2014/simce2m2014_cpad.dta"

// Unir con base alumnos
tempfile cpad
save `cpad', replace
use output/base_absentismo, clear
merge 1:1 agno idalumno using `cpad', gen(_merge_cpad) keepus(cpad*)
save output/base_absentismo, replace


* Cuestionario profes
*-------------------------------------------------------------------------------

// Separar cuestionario profes lectura y matematicas en año 2013
use "input/simce2m2013/Archivos DTA (Stata)/simce2m2013_cprof_publica_final.dta", clear

// Unir 2012-2014
use "input/simce2m2012/Archivos DTA (Stata)/simce2m2012_cprof_lect_publica_final.dta", clear
append using "input/simce2m2013/Archivos DTA (Stata)/simce2m2013_cprof_publica_final.dta"
append using "input/simce2m2014/simce2m2014_cprof_lect.dta"

// Unir con base alumnos
tempfile cprof_lect
save `cprof_lect', replace
use output/base_absentismo, clear
merge 1:1 agno idalumno using `cprof_lect', gen(_merge_cprof_lect) keepus(cprof_lect*)
save output/base_absentismo, replace
