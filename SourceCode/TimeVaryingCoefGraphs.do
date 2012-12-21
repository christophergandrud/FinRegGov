////////////////////////////////
// Reproducible Time-varying Coefficients for "Who is Watching: A Multi-state Event History Analysis of Financial Supervision Governance Diffusion"
// Author: --
// Updated 24 July 2012
// Using Stata 12
////////////////////////////////

cd "~/Desktop/FinDiag/CbmofCbSr"


// Load data 
use "http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public_fin_trans_data.dta", clear

    ///// Remove 1987 due to SE lag missing /////
    drop if year == 1987  
    
    ///// Convert spatial effects into percents to ease interpretation        
    gen percent_se_cbss_cbocb   = se_cbss_cbocb*100
    gen percent_se_eu_cbocb     = se_eu_cbocb*100
    gen percent_se_basel_cbocb  = se_basel_cbocb*100 
    gen percent_se_easia_cbocb  = se_easia_cbocb*100
    
    // mi set data
    mi stset year, id(country) failure(reg_4state == 4) enter(reg_4state == 1) exit(reg_4state == 2 3 4) origin(min)
    
	// Model B6
version 11
local M = 5
tempname fname

forvalues i = 1/`M' {
    preserve 
    mi extract `i', clear
    
    // Run model
	stcrreg imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb) texp(_t) 
	**** Note: various functions of time were tested including ^2, ^3, and ln.

	// Graph Subhazards
	graph twoway (function shr_imf_2 = exp([main]_b[imf_2]+x*[tvc]_b[imf_2]), range(2 15) ytitle("Sub-hazard Ratio--exp(b)") xtitle("") yline(1) xlabel(3 "1990" 10 "1997" 17 "2004") scheme(s1color) saving(`fname', replace) name(gr, replace)) 

	
	twoway (function shr_percent_se_eu_cbocb = exp([main]_b[percent_se_eu_cbocb]+x*[tvc]_b[percent_se_eu_cbocb]), range(2 15) ytitle("Sub-hazard Ratio--exp(b)") xtitle("") yline(1) xlabel(3 "1990" 10 "1997" 17 "2004") scheme(s1color) saving(`fname', replace) name(gr, replace))
	
	twoway (function shr_percent_se_cbss_cbocb = exp([main]_b[percent_se_cbss_cbocb]+x*[tvc]_b[percent_se_cbss_cbocb]), range(2 15) ytitle("Sub-hazard Ratio--exp(b)") xtitle("") yline(1) xlabel(3 "1990" 10 "1997" 17 "2004") scheme(s1color) saving(`fname', replace) name(gr, replace)) 
	
    restore	
}
