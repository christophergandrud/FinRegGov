***************
* Predicted hazard and cumulative hazards "Who is Watching?"
* Author: Christopher Gandrud
* Updated 24 July 2012
***************

////////////////
// Cox Proportional Hazard Coefficients For Unifying Multiple SRs, 1988 - 2006
////////////////

cd "~/Desktop/FinDiag/MsrSr"

use "http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public_fin_trans_data.dta", clear



    ///// Remove 1987 due to SE lag missing /////
    drop if year == 1987
    
    ///// Convert spatial effects into percents to ease interpretation        
    gen percent_se_cbss_ocbu = se_cbss_ocbu*100
    gen percent_se_eu_ocbu = se_eu_ocbu*100
    gen percent_se_basel_ocbu = se_basel_ocbu*100
    
    mi stset year, id(country) failure(reg_4state == 3) enter(reg_4state == 2) exit(reg_4state == 3 4) origin(min)
    

local M = 5
tempname fname
forvalues i = 1/`M' {
    preserve
        mi extract `i', clear
            stcox  crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
    
    	stcurve, hazard at1(crisis6 = -1.79) at2(crisis6 = -0.74) at3(crisis6 = -0.46) at4(crisis6 = -0.1) at5(crisis6 = 0) outfile(`fname', replace) name(gr, replace)
    	
        use `fname', clear
        des
        rename _t _t`i'
        rename haz2 haza_`i'
		rename haz3 hazb_`i'
		rename haz4 hazc_`i'
		rename haz5 hazd_`i'
		rename haz6 haze_`i'
		

		if (`i' > 1) {

		merge 1:1 _n using crisiscurv

        assert _merge==3

        drop _merge
        }
        save crisiscurv, replace
        restore
}

use crisiscurv, clear

by _t1, sort: keep if _n==1

local haza haza_1
local hazb hazb_1
local hazc hazc_1
local hazd hazd_1
local haze haze_1



forvalues i=2/`M' {
        assert _t`i'==_t1

        local haza `haza' haza_`i'
		local hazb `hazb' hazb_`i'
		local hazc `hazc' hazc_`i'
		local hazd `hazd' hazd_`i'
		local haze `haz3' haze_`i'
}

egen meana = rowmean(`haza')
egen meanb = rowmean(`hazb')
egen meanc = rowmean(`hazc')
egen meand = rowmean(`hazd')
egen meane = rowmean(`haze')

				   
twoway line meana meanb meanc meand meane _t1, sort c(J) note(Averaged over imputed data) xtitle("Year") ytitle("Smoothed Hazard") scheme(s1color) legend(label(1 "1st Crisis Year") label(2 "2nd Year") label(3 "3rd Year") label(4 "Mean Value") label(5 "No Crisis") ) xlabel(3 "1990" 10 "1997" 17 "2004")




////////////////
//  Fine \& Gray Competing Risks Coefficients for Reforms from CB/MoF to SR/U Supervision, 1988 - 2006
////////////////

***** Crisis *****

cd "~/Desktop/FinDiag/CbMofSR"


use "http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public_fin_trans_data.dta", clear


    ///// Remove 1987 due to SE lag missing /////
    drop if year == 1987 
    
    gen percent_se_cbss_ocbu = se_cbss_ocbu*100
    gen percent_se_eu_ocbu = se_eu_ocbu*100
    gen percent_se_basel_ocbu = se_basel_ocbu*100
    gen percent_se_easia_ocbu = se_easia_ocbu*100

    // mi set data
    mi stset year, id(country) failure(reg_4state == 3) enter(reg_4state == 1) exit(reg_4state == 2 3 4) origin(min)

/////// Crisis ////////////////////////////////////////////////////////////////////////////
****** From Garbage Can Model (C6)

version 11
local M = 5
tempname fname


forvalues i = 1/`M' {
    preserve
        mi extract `i', clear
		stcrreg crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4)

    
    	stcurve, cif at1(crisis6 = -1.79) at2(crisis6 = -0.74) at3(crisis6 = -0.46) at4(crisis6 = -0.1) at5(crisis6 = 0)  outfile(`fname', replace) name(gr, replace)
    	
        use `fname', clear
        des
        rename _t _t`i'
        rename ci2 cia_`i'
		rename ci3 cib_`i'
		rename ci4 cic_`i'
		rename ci5 cid_`i'
		rename ci6 cie_`i'

		if (`i' > 1) {
		    merge 1:1 _n using crisiscurv
            assert _merge==3
            drop _merge
               
            }
        save crisiscurv, replace
        restore
}

use crisiscurv, clear
by _t1, sort: keep if _n==1
local cifa cia_1
local cifb cib_1
local cifc cic_1
local cifd cid_1
local cife cie_1


forvalues i=2/`M' {
        assert _t`i'==_t1
        local cifa `cifa' cia_`i'
		local cifb `cifb' cib_`i'
		local cifc `cifc' cic_`i'
		local cifd `cifd' cid_`i'
		local cife `cife' cie_`i'

}
egen meana = rowmean(`cifa')
egen meanb = rowmean(`cifb') 
egen meanc = rowmean(`cifc') 
egen meand = rowmean(`cifd') 
egen meane = rowmean(`cife') 
 
				   
twoway line meana meanb meanc meand meane _t1, sort c(J) xtitle("Year") ytitle("Predicted Proportion") scheme(s1color) legend(label(1 "1st Crisis Year") label(2 "2nd Year") label(3 "3rd Year") label(4 "Mean Value") label(5 "No Crisis") ) xlabel(3 "1990" 10 "1997" 17 "2004") ylabel(0 "0" .2 ".2" .4 ".4" .6 ".6" .8 ".8" 1 "1")
**********************************


***** CBSS *****

cd "~/Desktop/FinDiag/CbMofSR"


use "http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public_fin_trans_data.dta", clear


    ///// Remove 1987 due to SE lag missing /////
    drop if year == 1987 
    
    gen percent_se_cbss_ocbu = se_cbss_ocbu*100
    gen percent_se_eu_ocbu = se_eu_ocbu*100
    gen percent_se_basel_ocbu = se_basel_ocbu*100
    gen percent_se_easia_ocbu = se_easia_ocbu*100

    // mi set data
    mi stset year, id(country) failure(reg_4state == 3) enter(reg_4state == 1) exit(reg_4state == 2 3 4) origin(min)

/////// CBSS /////////////////////////////////////////////////////////////////////////////////
****** From Garbage Can Model (C6)
local M = 5
tempname fname


forvalues i = 1/`M' {
    preserve
        mi extract `i', clear
        stcrreg crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4)
    
    	stcurve, cif at1(percent_se_cbss_ocbu = 0) at2(percent_se_cbss_ocbu = 22) at3(percent_se_cbss_ocbu = 78) at4(percent_se_cbss_ocbu = 89) outfile(`fname', replace) name(gr, replace)
    	
        use `fname', clear
        des
        rename _t _t`i'
        rename ci2 cia_`i'
		rename ci3 cib_`i'
		rename ci4 cic_`i'
		rename ci5 cid_`i'

		if (`i' > 1) {
		    merge 1:1 _n using crisiscurv
            assert _merge==3
            drop _merge
               
            }
        save crisiscurv, replace
        restore
}

use crisiscurv, clear
by _t1, sort: keep if _n==1
local cifa cia_1
local cifb cib_1
local cifc cic_1
local cifd cid_1

forvalues i=2/`M' {
        assert _t`i'==_t1
        local cifa `cifa' cia_`i'
		local cifb `cifb' cib_`i'
		local cifc `cifc' cic_`i'
		local cifd `cifd' cid_`i'

}
egen meana = rowmean(`cifa')
egen meanb = rowmean(`cifb') 
egen meanc = rowmean(`cifc') 
egen meand = rowmean(`cifd') 

				   
twoway line meana meanb meanc meand _t1, sort c(J) xtitle("") ytitle("") note(Averaged over imputed data) scheme(s1color) legend(label(1 "0") label(2 "22") label(3 "78") label(4 "89")) xlabel(3 "1990" 10 "1997" 17 "2004") ylabel(0 "0" .2 ".2" .4 ".4" .6 ".6" .8 ".8" 1 "1")
*************************************

**** Graphs were individually saved and cleaned up

*** Combine Graphs

graph combine "/Users/christophergandrud/Dropbox/Fin_trans/Figures/FgCrisis.gph" "/Users/christophergandrud/Dropbox/Fin_trans/Figures/FgCBSS.gph", cols(2)
    
