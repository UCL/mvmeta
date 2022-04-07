<a href ="https://www.mrcctu.ucl.ac.uk/"><img src="MRCCTU_at_UCL_Logo.png" width="50%" /></a>

# mvmeta: Stata module to perform multivariate random-effects meta-analysis

Author: Ian White

Version: 4.0 

Date: 7apr2022

This package includes the mvmeta_make command which prepares data for mvmeta.

## What's new in version 4
mvmeta_make: 
- a prefix syntax makes the command work with complex Stata commands such as mixed and mi estimate 
- the classic (former) syntax is still available
- I've made a number of minor improvements

mvmeta: 
- bscov(exch) estimates a common between-studies correlation.
- bubble option (was previously undocumented)
- I've made a number of minor bug fixes

## Installation within Stata
You should be able to install this package from SSC.

To install it from github, use one of these:
- `github install UCL/mvmeta, path(package)`
- `net from https://raw.githubusercontent.com/UCL/mvmeta/master/package/`
