***Homework 4***

clear all
set more off
capture log close

cd "H:\My Drive\Econ 640\Homework 4"
log using "Homework 4 Log", replace

*Part A*

sysuse auto
reg price weight mpg
estat hettest

/* Since the p-value is 0.0001, we would reject the null hypothesis that the
variance is homoskedastic. This implies that we have are dealing with
heteroskedasticity */

regress price weight mpg, robust

/* The standard errors of the robust regression are larger than just the regular
regression. By using robust, we relax the assumption that variance of the errors
is constant across all observations. This will lead to higher uncertainty, 
making the robsut standard errors larger */

*Part B*

sysuse nlsw88, clear
reg wage age collgrad
reg wage age collgrad, cluster(occupation)

/* The cluster-robust standard errors are a lot larger than the OLS standard
errors. This is because they allow for correlation within each cluster which
causes the variance to increase as a result of the dependency. */

*Part C*

bcuse cps91, clear
gen lnexper = ln(exper)
reg hrwage lnexper 

/* The coefficient on lnexper is 0.0459. This means that a 1% change in 
experience is associated with a change in hourly wages of 0.000459. */

reg hrwage exper

/* If we were to regress without logging experience then the coefficient would
be -0.0184. This would mean that a one unit-change in experince would be 
associated with a -0.0184 change in horuly wages. However, this implies that 
increasing experience would diminish wages. By logging experience, the 
diminishing effects of experience is accounted for */

*Part D*

bcuse bwght2, clear
logit lbw cigs mage
margins, dydx(cigs)

/* The marginal effect is about 0.0006. This means that a one-unit change in 
average cigarettes smoked during pregnancy can affect the probability that a 
baby will be born with low weight by 0.0006 

For an OLS regression, the coefficient would describe the direct change in the
dependent variable if there was a one-unit change in the predictor variable.
However, the coefficient of a logit model would describe the log probability of
an outcome. The reason why logit coefficients are less straightforward is
because the effect relies on the base probability of an event happening despite
the coefficients staying the same
*/

log close