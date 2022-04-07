/*
mvmeta_vs_metamvregress.do
IW 18/11/2021
Comparison of mvmeta with "official" meta mvregress
mvmeta appears more robust to reordering variables
*/

use telomerase2, clear

mvmeta y S study, bscov(uns) nounc var(y1 y2)
mat mvmeta12 = e(Sigma)

mvmeta y S study, bscov(uns) nounc var(y2 y1)
mat mvmeta21 = e(Sigma)

meta mvregress y1 y2 = study, wcovvar(S11 S12 S22) random(,cov(uns))
estat recovariance
mat meta12 = r(cov)

meta mvregress y2 y1 = study, wcovvar(S22 S12 S11) random(,cov(uns))
estat recovariance
mat meta21 = r(cov)

foreach method in mvmeta meta {
	local res12 = sqrt(`method'12[1,1])
	local res21 = sqrt(`method'21[2,2])
	di as text "`method' discrepancy: " as result `res12' " vs " `res21' ", diff = " `res12' - `res21'
}
