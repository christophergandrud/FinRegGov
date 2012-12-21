***************
* Test Proportional Hazards Assumption for "Who is Watching?"
* Author: Christopher Gandrud
* Updated 22 July 2012
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
    
///// Run estat phtest on Model A6 /////
forvalues i = 0/5 {
    preserve 
    mi extract `i', clear
    stcox  crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
	
	estat phtest, detail

	restore
}

///// Examine Schoenfield-Type residuals for Model A6 /////
forvalues i = 0/5 {
    preserve 
    mi extract `i', clear
	stcox  crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
	
    predict sch*, sch
    lowess sch1 _t, bw(0.8) mean saving(controls`i'1, replace)
    lowess sch2 _t, bw(0.8) mean saving(controls`i'2, replace)
    lowess sch3 _t, bw(0.8) mean saving(controls`i'3, replace)   
    lowess sch4 _t, bw(0.8) mean saving(controls`i'4, replace)
    lowess sch5 _t, bw(0.8) mean saving(controls`i'5, replace)
    lowess sch6 _t, bw(0.8) mean saving(controls`i'6, replace)
    lowess sch7 _t, bw(0.8) mean saving(controls`i'7, replace)
    lowess sch8 _t, bw(0.8) mean saving(controls`i'8, replace)
    lowess sch9 _t, bw(0.8) mean saving(controls`i'9, replace)            
    restore
}

///// Run estat phtest on Model A7 /////
forvalues i = 0/5 {
    preserve 
    mi extract `i', clear
    stcox  crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu, vce(robust)
	
	estat phtest, detail

	restore
}

////////////////
//  Fine \& Gray Competing Risks Coefficients for Reforms from CB/MoF to CB/SR Supervision, 1988 - 2006
//////////////// 

cd "~/Desktop/FinDiag/CbmofCbSr"

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
    
///// Examine Schoenfield-Type residuals for Model B6 /////
forvalues i = 0/5 {
    preserve 
    mi extract `i', clear
	stcrreg crisis_base imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3)
    predict sch*, sch
    lowess sch1 _t, bw(0.8) mean saving(controls`i'1, replace)
    lowess sch2 _t, bw(0.8) mean saving(controls`i'2, replace)
    lowess sch3 _t, bw(0.8) mean saving(controls`i'3, replace)   
    lowess sch4 _t, bw(0.8) mean saving(controls`i'4, replace)
    lowess sch5 _t, bw(0.8) mean saving(controls`i'5, replace)
    lowess sch6 _t, bw(0.8) mean saving(controls`i'6, replace)
    lowess sch7 _t, bw(0.8) mean saving(controls`i'7, replace)
    lowess sch8 _t, bw(0.8) mean saving(controls`i'8, replace)
    lowess sch9 _t, bw(0.8) mean saving(controls`i'9, replace)            
    lowess sch10 _t, bw(0.8) mean saving(controls`i'10, replace)    
    restore
}

//// Test time-varying coefficients ////

//// Full model ////

    mi estimate, shr: stcrreg crisis6 imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(crisis6 imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office)
    

/// Subsets

    mi estimate, shr: stcrreg crisis_base imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(imf_2)
    
    mi estimate, shr: stcrreg crisis_base imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(percent_se_eu_cbocb)


    mi estimate, shr: stcrreg crisis_base imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(percent_se_cbss_cbocb)    
    
    mi estimate, shr: stcrreg crisis6 imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(imf_2 percent_se_eu_cbocb percent_se_cbss_cbocb)    
    
// Graph time-varying coefficient across time
forvalues i = 0/5 {
    preserve 
    mi extract `i', clear
	stcrreg crisis_base imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(imf_2 percent_se_eu_cbocb percent_se_cbss_cbocb)  

	twoway (function shr_imf_2 = exp([main]_b[imf_2]+x*[tvc]_b[imf_2]), range(2 15) ytitle("Sub-hazard Ratio--exp(b)") xtitle("") yline(1))
	
	twoway (function shr_percent_se_eu_cbocb = exp([main]_b[percent_se_eu_cbocb]+x*[tvc]_b[percent_se_eu_cbocb]), range(2 15) ytitle("Sub-hazard Ratio--exp(b)") xtitle("") yline(1))
	
	twoway (function shr_percent_se_cbss_cbocb = exp([main]_b[percent_se_cbss_cbocb]+x*[tvc]_b[percent_se_cbss_cbocb]), range(2 15) ytitle("Sub-hazard Ratio--exp(b)") xtitle("") yline(1))
	
    restore	
}


////////////////
//  Fine \& Gray Competing Risks Coefficients for Reforms from CB/MoF to SR/U Supervision, 1988 - 2006
////////////////

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
        
///// Examine Schoenfield-Type residuals for Model C6 /////
forvalues i = 0/5 {
    preserve 
    mi extract `i', clear
	stcrreg crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4)
    predict sch*, sch
    lowess sch1 _t, bw(0.8) mean saving(controls`i'1, replace)
    lowess sch2 _t, bw(0.8) mean saving(controls`i'2, replace)
    lowess sch3 _t, bw(0.8) mean saving(controls`i'3, replace)   
    lowess sch4 _t, bw(0.8) mean saving(controls`i'4, replace)
    lowess sch5 _t, bw(0.8) mean saving(controls`i'5, replace)
    lowess sch6 _t, bw(0.8) mean saving(controls`i'6, replace)
    lowess sch7 _t, bw(0.8) mean saving(controls`i'7, replace)
    lowess sch8 _t, bw(0.8) mean saving(controls`i'8, replace)
    lowess sch9 _t, bw(0.8) mean saving(controls`i'9, replace)            
    lowess sch10 _t, bw(0.8) mean saving(controls`i'10, replace)    
    restore
}

//// Test time-varying coefficients ////

//// Full model ////

    mi estimate, shr: stcrreg crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4) tvc(crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu gdp_2005_nse dbagdp concentration cbg_time_in_office)
    


