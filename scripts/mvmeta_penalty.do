/*
Demonstrate the new penalty option
IW 15jun2020
*/

pda
use "N:\Home\meta\Julieta Galante\weird\ma_cognitive_functioning_cp", clear
misstable pattern cp_est*, freq

* this one fails: there are only 2 studies with both outcomes
cap noi mvmeta cp_est_ cp_var_, wscorr(riley) iter(200)
est store riley

* this one works
mvmeta cp_est_ cp_var_, wscorr(riley) penalty(.1)
est store rileypen01

mvmeta cp_est_ cp_var_, wscorr(riley) penalty(1)
est store rileypen1

forvalues r=0/9 {
	mvmeta cp_est_ cp_var_, wscorr(0.`r')
	est store r0`r'
}
est table _all, b se keep(cp*)



use \stata\fscstage1, clear
su
mvmeta b V
mvmeta b V, penalty(0)
mvmeta b V, penalty(1)
