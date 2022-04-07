/*
Simple test file for mvmeta_bscov_*.ado
IW 15nov2021
*/

pda
myadopath mvmeta

use "C:\ado\ian\mvmeta\package\berkey.dta"
mvmeta y V, id(trial) 

mat sigma0 = 2*I(3)
global MVMETA_sigma0 sigma0
global MVMETA_p 2

mvmeta_bscov_equals, varparms()
mat est = r(Sigma)
assert abs(mreldif(est, sigma0)) < 1E-7



mat parms = (2)
mvmeta_bscov_proportional, varparms(parms)

mat true = 8*I(3)
mat est = r(Sigma)
assert abs(mreldif(est, true)) < 1E-7



mat eparms = (2, 0.4)
mvmeta_bscov_exchangeable, varparms(eparms)

mat true = 2^2*(J(2,2,0.4)+0.6*I(2))
mat est = r(Sigma)
assert abs(mreldif(est, true)) < 1E-7

di "mvmeta_bscov_*.ado files have passed these limited tests"
