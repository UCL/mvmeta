# Summary of mvmeta in Stata12

IW 8/4/2022

## Changes made to mvmeta to improve performance in Stata12

Program issues

- pi routine: change invt(df,p) to invttail(df,1-p)

- pi routine: change mat["`yvar'","`yvar'"] to mat[rownumb(mat,"`yvar'"),colnumb(mat,"`yvar'")] 

- pbest routine: correct bug that left variable names missing in Stata12

Help file issues

- remake fsc2cigraph.gph in v12

- convert all test data sets to v12

## Changes made to cscripts to test performance in Stata12

- skip testing of mvmeta_make with -mixed- if version<13

- checks via mreldif(): Stata12 doesn't allow matrix expressions, changed

## Differences in mvmeta performance between Stata12 and Stata17

- pbest results are changed because stata 12 has different RNG

- many numerical differences in the last decimal place

## Note of programs needed to run the test scripts in full

- SSC programs: sencode, metan

- my programs: runhelpfile
