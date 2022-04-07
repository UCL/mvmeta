/*
Prediction interval after mvmeta
IW 8apr2020
*/
pda

myadopath mvmeta
which mvmeta, all

use FSCstage1, clear

* uv for 1st outcome using admetan
gen y= b_Ifg_2
gen s=sqrt( V_Ifg_2_Ifg_2)
admetan y s, model(dl) rfdist
di r(eff) + invt(r(k)-2,.975) * sqrt(r(se_eff)^2 + r(tausq))
di r(eff) - invt(r(k)-2,.975) * sqrt(r(se_eff)^2 + r(tausq))

* uv for 1st outcome using uv mvmeta 
mvmeta b V, v(b_Ifg_2) mm

mvmeta_pi, format(%6.2f)

exit 1

* uv for 1st outcome using mvmeta
mvmeta b V
mat Sig=e(Sigma)
*di _b[ b_Ifg_2] + invt(e(N)-2,.975) * sqrt( _se[ b_Ifg_2]^2 + Sig["b_Ifg_2"," b_Ifg_2"])
*di _b[ b_Ifg_2] - invt(e(N)-2,.975) * sqrt( _se[ b_Ifg_2]^2 + Sig["b_Ifg_2"," b_Ifg_2"])

mvmeta_pi, format(%6.4f)
