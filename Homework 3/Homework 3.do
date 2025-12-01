***Homework 3***

clear all
set more off
capture log close

cd "H:\My Drive\Econ 640\Homework 3"
log using "Homework 3", replace

********************************************************************************
*Data Generating Process*
set seed 123

*Set panel dimensions
local G = 50       // Number of clusters (states)
local T = 10       // Time periods

*Creating the Panel
set obs `G'
gen clusters = _n
expand `T'
bys clusters: gen time = _n
sort clusters time

*Cluster Heteroskedasticity
gen sigma = runiform(0.5,2)
bys clusters: replace sigma = sigma[1]

*Generate x_it and epsilon_it
gen x_it = rnormal()
gen eps_it = rnormal()

*Generate u_it with Heteroskedasticity
gen u_it = .
bys clusters: replace u_it = 0 if time == 1 	//u_i0 = 0
bys clusters: replace u_it = 0.5 * u_it[_n-1] + sigma*eps_it if time > 1

*Generate y_it
gen y_it = x_it + u_it

********************************************************************************

*Part A: Point Estimation*

* 1. Estimation of beta
reg y_it x_it 	//The estimation of beta is approx. 0.9925

* 2. Estimation of beta using clusters
reg y_it x_it, vce(cluster clusters)

* 3. Estimation of GLS and FGLS
xtset clusters time
xtgls y_it x_it, p(h) c(a)

/* 
The estimation of beta-hat is the same when estimating it by OLS and OLS 
clusters and it is very close to the true beta. However, the SE is smaller when 
estimating by OLS clusters. On the other hand, when estimating beta-hat by GLS,
the estimation further away from the true beta than the other two methods. But,
the SE is considerably smaller than the SEs of the other two methods
*/

*Part B: Monte Carlo*
capture program drop montecarlo
program define montecarlo, rclass //recreating the DGP in a program
	clear
	args regression
	set obs 50
	gen clusters = _n
	expand 10
	bys clusters: gen time = _n
	sort clusters time
	gen sigma = runiform(0.5,2)
	bys clusters: replace sigma = sigma[1]
	gen x_it = rnormal()
	gen eps_it = rnormal()
	gen u_it = .
	bys clusters: replace u_it = 0 if time == 1
	bys clusters: replace u_it = 0.5 * u_it[_n-1] + sigma*eps_it if time > 1
	gen y_it = x_it + u_it
	xtset clusters time
	`regression'
	return scalar b_x = _b[x_it]
	return scalar se_x = _se[x_it]
end

* 1. OLS
set seed 123
simulate b_x = r(b_x), reps(1000): montecarlo "reg y_it x_it"

hist b_x, title("Estimation of β OLS") xtitle("β OLS") ///
	xlabel(0.8(0.2)1.2) ylabel(0(2)8)
graph save "Estimation of β OLS.gph", replace

* 2. Robust OLS
set seed 123
simulate b_x = r(b_x) se_x = r(se_x), reps(1000): ///
	montecarlo "reg y_it x_it, vce(cluster clusters)"

hist b_x, title("Estimation of β Cluster OLS") xtitle("β COLS") ///
	xlabel(0.8(0.2)1.2) ylabel(0(2)8)
graph save "Estimation of β COLS.gph", replace

hist se_x, title("Distribution of clustered SEs for β") ///
    xtitle("SE(β)") xlabel(0(0.01)0.1)
graph save "Clustered SEs β.gph", replace

* 3. GLS/FGLS
set seed 123
simulate b_x = r(b_x), reps(1000): montecarlo "xtgls y_it x_it, p(h) c(a)"

hist b_x, title("Estimation of GLS") xtitle("β GLS") ///
	xlabel(0.8(0.1)1.2) ylabel(0(2)10)
graph save "Estimation of β GLS.gph", replace

********************************************************************************

log close
























