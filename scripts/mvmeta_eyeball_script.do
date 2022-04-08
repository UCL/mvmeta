// mvmeta eyeball script: have to check graphs by eye
// IW 7/4/2022

prog drop _all

* check bubble
use "C:\ado\ian\mvmeta\scripts\MYCN.dta"
mvmeta y S, var(y4 y3 y2 y1) wscorr(.3) fixed bubble(var(y2 y4) missval(-2) name(b1,replace))
mvmeta y S, var(y1 y2 y3 y4) wscorr(.3) fixed bubble(var(y2 y4) missval(-2) name(b2,replace))
mvmeta y S, var(y4 y3 y2 y1) wscorr(.3) fixed bubble(var(y4 y2) missval(-2) name(b3,replace))
* check b1 and b2 are identical, and (harder) b3 is their transpose

* check PIs are unaffected by ordering
mvmeta y S, var(y4 y3 y2 y1) wscorr(.3) mm pi
mvmeta y S, var(y1 y2 y3 y4) wscorr(.3) mm pi
