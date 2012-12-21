////////////////////////////////
// Reproducible Tables for "Who is Watching: A Multi-state Event History Analysis of Financial Supervision Governance Diffusion"
// Author: Christopher Gandrud
// Updated 24 July 2012
// Using Stata 12
////////////////////////////////

cd "~/Desktop/tables/"

////////////////
//  Fine \& Gray Competing Risks Coefficients for Reforms from CB/MoF to CB/SR Supervision, 1988 - 2006
//////////////// 

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
    
    ///// Base Fine & Gray output for tables /////
    
    mi estimate, shr: stcrreg gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3)
        regsave using "cbmof_cbsr1.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(A1, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
            
    mi estimate, shr: stcrreg asset_diversity gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3)
        regsave using "cbmof_cbsr2.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(A2, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg crisis6 gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3)
        regsave using "cbmof_cbsr3.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(A3, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg imf_2 gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(imf_2 cbg_time_in_office)
        regsave using "cbmof_cbsr4.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(A4, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(percent_se_cbss_cbocb percent_se_eu_cbocb)
        regsave using "cbmof_cbsr5.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(A5, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg crisis6 imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 3) tvc(imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb)
        regsave using "cbmof_cbsr6.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(A6, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg crisis6 imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb percent_se_basel_cbocb percent_se_easia_cbocb, compete(reg_4state == 2 3) tvc(imf_2 percent_se_cbss_cbocb percent_se_eu_cbocb)
        regsave using "cbmof_cbsr7.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(A7, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
//// Remove 'eq1' ////

	use "cbmof_cbsr1.dta", clear
	replace var = subinstr(var, "eq1", "main", 1)
	sort var
	save, replace

 	use "cbmof_cbsr2.dta", clear
	replace var = subinstr(var, "eq1", "main", 1)
	sort var
	save, replace

	use "cbmof_cbsr3.dta", clear
	replace var = subinstr(var, "eq1", "main", 1)
	sort var	       
	save, replace
	
	use "cbmof_cbsr4.dta", clear
	sort var	       
	save, replace

	use "cbmof_cbsr5.dta", clear
	sort var	       
	save, replace
	
	use "cbmof_cbsr6.dta", clear
	sort var	       
	save, replace
	
	use "cbmof_cbsr7.dta", clear
	sort var	       
	save, replace


//// Merge data sets ///
	use "cbmof_cbsr1.dta", clear
	merge var using cbmof_cbsr2.dta cbmof_cbsr3.dta cbmof_cbsr4.dta cbmof_cbsr5.dta cbmof_cbsr6.dta cbmof_cbsr7.dta
	
	drop _merge*
	
	save cbmof_cbsr.dta, replace
	
        
    ///// Create .tex file /////
    use cbmof_cbsr.dta, clear       
        //rename variables
       
        generate order = 99 
     
        replace var = "Crisis(Log)" if var == "main:crisis6_coef"
            replace order = 1 if var == "Crisis(Log)"
            replace order = 2 if var == "main:crisis6_stderr"
            
        replace var = "IMF Stand-by" if var == "main:imf_2_coef"
            replace order = 3 if var == "IMF Stand-by"
            replace order = 4 if var == "main:imf_2_stderr"
            
        replace var = "CBSS SE (CB/SR)" if var == "main:percent_se_cbss_cbocb_coef"
            replace order = 5 if var == "CBSS SE (CB/SR)"
            replace order = 6 if var == "main:percent_se_cbss_cbocb_stderr"
            
        replace var = "EU SE (CB/SR)" if var == "main:percent_se_eu_cbocb_coef"
            replace order = 7 if var == "EU SE (CB/SR)"
            replace order = 8 if var == "main:percent_se_eu_cbocb_stderr"
            
        replace var = "Basel SE (CB/SR)" if var == "main:percent_se_basel_cbocb_coef"
            replace order = 9 if var == "Basel SE (CB/SR)"
            replace order = 10 if var == "main:percent_se_basel_cbocb_stderr"            
            
        replace var = "EA SE (CB/SR)" if var == "main:percent_se_easia_cbocb_coef"
            replace order = 11 if var == "EA SE (CB/SR)"
            replace order = 12 if var == "main:percent_se_easia_cbocb_stderr"
            
        replace var = "GDP/Capita" if var == "main:gdp_2005_nse_coef"
            replace order = 13 if var == "GDP/Capita"
            replace order = 14 if var == "main:gdp_2005_nse_stderr" 
            
        replace var = "Asset Diversity" if var == "main:asset_diversity_coef"
            replace order = 15 if var == "Asset Diversity"
            replace order = 16 if var == "main:asset_diversity_stderr"
            
        replace var = "DB Assets/GDP" if var == "main:dbagdp_coef"
            replace order = 17 if var == "DB Assets/GDP"
            replace order = 18 if var == "main:dbagdp_stderr"
            
        replace var = "Concentration" if var == "main:concentration_coef"
            replace order = 19 if var == "Concentration" 
            replace order = 20 if var == "main:concentration_stderr"
             
        replace var = "CBG Tenure" if var == "main:cbg_time_in_office_coef"
            replace order = 21 if var == "CBG Tenure"
            replace order = 22 if var == "main:cbg_time_in_office_stderr"
            
            
        // Time interaction label
        
        replace var = "{\bf{Time Interactions}}" if var == "which"
            replace order = 23 if var == "{\bf{Time Interactions}}"
            replace A1 = "" if var == "{\bf{Time Interactions}}"
            replace A2 = "" if var == "{\bf{Time Interactions}}"
            replace A3 = "" if var == "{\bf{Time Interactions}}"
            replace A4 = "" if var == "{\bf{Time Interactions}}"
            replace A5 = "" if var == "{\bf{Time Interactions}}"
            replace A6 = "" if var == "{\bf{Time Interactions}}"
            replace A7 = "" if var == "{\bf{Time Interactions}}"
            
        replace var = "IMF Stand-by (tvc)" if var == "tvc:imf_2_coef"
            replace order = 24 if var == "IMF Stand-by (tvc)" 
            replace order = 25 if var == "tvc:imf_2_stderr"
            
        replace var = "CBSS SE (CB/SR) (tvc)" if var == "tvc:percent_se_cbss_cbocb_coef"
            replace order = 26 if var == "CBSS SE (CB/SR) (tvc)" 
            replace order = 27 if var == "tvc:percent_se_cbss_cbocb_stderr"
            
        replace var = "EU SE (CB/SR) (tvc)" if var == "tvc:percent_se_eu_cbocb_coef"
            replace order = 28 if var == "EU SE (CB/SR) (tvc)" 
            replace order = 29 if var == "tvc:percent_se_eu_cbocb_stderr"   
            
        replace var = "CBG Tenure (tvc)" if var == "tvc:cbg_time_in_office_coef"
            replace order = 30 if var == "CBG Tenure (tvc)"
            replace order = 31 if var == "tvc:cbg_time_in_office_stderr" 
            
        // Model      
        
        replace var = "Countries at Risk" if var == "N_clust"
            replace order = 32 if var == "Countries at Risk"
        
        replace var = "No. of Transitions" if var == "N_fail"
            replace order = 33 if var == "No. of Transitions"
        
        replace var = "F" if var == "F_mi"
            replace order = 34 if var == "F"
        
		 drop if var == "p"
         replace var = "p" if var == "p_mi"
            replace order = 35 if var == "p"

        
        generate _stderr = regexm(var, "_stderr")
            replace var = "" if _stderr == 1
            
        replace var = subinstr(var, "(tvc)", "", 1)
            	  
        replace A1 = "$<$0.001" if A1 == "0" & var == "p"
        replace A2 = "$<$0.001" if A2 == "0" & var == "p"
        replace A3 = "$<$0.001" if A3 == "0" & var == "p"
        replace A4 = "$<$0.001" if A4 == "0" & var == "p"
        replace A5 = "$<$0.001" if A5 == "0" & var == "p"
        replace A6 = "$<$0.001" if A6 == "0" & var == "p"
        replace A7 = "$<$0.001" if A7 == "0" & var == "p"

        replace A1 = subinstr(A1, "-", "$-$", 1)
        replace A2 = subinstr(A2, "-", "$-$", 1)
        replace A3 = subinstr(A3, "-", "$-$", 1)
        replace A4 = subinstr(A4, "-", "$-$", 1)
        replace A5 = subinstr(A5, "-", "$-$", 1)
        replace A6 = subinstr(A6, "-", "$-$", 1)
        replace A7 = subinstr(A7, "-", "$-$", 1)

 	    drop if order == 99
        
   	    rename var Variable
        sort order
	        drop order _stderr
	    compress
	    	    
    texsave using "cbmof_cbsr.tex", title(Fine \& Gray Competing Risks Coefficients for Reforms from CB/MoF to CB/SR Supervision (SEC Model), others competing, 1988 - 2006) size(footnotesize) marker(cbmof_cbsr_fine_gray) footnote("Standard errors are in parentheses. {*}/{*}{*}/{*}{*}{*} at 10/5/1\% significance levels. All models were compared to similar models over the time period 1997 - 2007 to determine if the asset diversity variable produced different results. Diagnostic tests using Schoenfield-Type residuals \citep[see][]{Fine1999} and time interactions were used to test the proportional hazards assumption. Linear time-varying covariates were added when the assumption was violated \citep[][214-215]{StataCorp.2009}. Bureaucratic Quality and Democracy (UDS) were excluded due to high insignificance and high correlation with GDP/Capita.") frag nofix hlines(22, 31) replace




////////////////
// Cox Proportional Hazard Coefficients For Unifying Multiple SRs, 1988 - 2006
////////////////

use "http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public_fin_trans_data.dta", clear



    ///// Remove 1987 due to SE lag missing /////
    drop if year == 1987
    
    ///// Convert spatial effects into percents to ease interpretation        
    gen percent_se_cbss_ocbu = se_cbss_ocbu*100
    gen percent_se_eu_ocbu = se_eu_ocbu*100
    gen percent_se_basel_ocbu = se_basel_ocbu*100
    
    // mi set data
    mi stset year, id(country) failure(reg_4state == 3) enter(reg_4state == 2) exit(reg_4state == 3 4) origin(min)


    /////// Base Cox Proportional model output for tables ///////

    mi estimate, hr: stcox pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
        regsave using "sr_sru.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(B1, order(regvars r2) format(%5.3f) paren(stderr) asterisk())

    mi estimate, hr: stcox asset_diversity pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
        regsave using "sr_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(B2, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, hr: stcox crisis6 pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
        regsave using "sr_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(B3, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, hr: stcox imf_2 pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
        regsave using "sr_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(B4, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, hr: stcox  percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
        regsave using "sr_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(B5, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, hr: stcox  crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu pr_bur dbagdp concentration cbg_time_in_office, vce(robust)
        regsave using "sr_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(B6, order(regvars r2) format(%5.3f) paren(stderr) asterisk())  

    mi estimate, hr: stcox  crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu, vce(robust)
        regsave using "sr_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(B7, order(regvars r2) format(%5.3f) paren(stderr) asterisk())  
        
    ///// Create .tex file /////
    use sr_sru.dta, clear
        
        //rename variables
        generate keep = regexm(var, "_stderr")
            replace var = "" if keep == 1
            
        replace var = "Crisis(Log)" if var == "crisis6_coef"
            replace keep = 1 if var == "Crisis(Log)"
        replace var = "IMF Stand-by" if var == "imf_2_coef"
            replace keep = 1 if var == "IMF Stand-by"
        replace var = "CBSS SE (SR/U)" if var == "percent_se_cbss_ocbu_coef"
            replace keep = 1 if var == "CBSS SE (SR/U)"
        replace var = "EU SE (SR/U)" if var == "percent_se_eu_ocbu_coef"
            replace keep = 1 if var == "EU SE (SR/U)"
        replace var = "Basel SE (SR/U)" if var == "percent_se_basel_ocbu_coef"
            replace keep = 1 if var == "Basel SE (SR/U)"
        replace var = "Asset Diversity" if var == "asset_diversity_coef"
            replace keep = 1 if var == "Asset Diversity"
        replace var = "Bureaucratic Quality" if var == "pr_bur_coef"
            replace keep = 1 if var == "Bureaucratic Quality"
        replace var = "DB Assets/GDP" if var == "dbagdp_coef"
            replace keep = 1 if var == "DB Assets/GDP"
        replace var = "Concentration" if var == "concentration_coef"
            replace keep = 1 if var == "Concentration" 
        replace var = "CBG Tenure" if var == "cbg_time_in_office_coef"
            replace keep = 1 if var == "CBG Tenure"
        replace var = "Countries at Risk" if var == "N_clust"
            replace keep = 1 if var == "Countries at Risk"
        replace var = "No. of Transitions" if var == "N_fail"
            replace keep = 1 if var == "No. of Transitions"
        replace var = "F" if var == "F_mi"
            replace keep = 1 if var == "F"
        replace var = "p" if var == "p_mi"
            replace keep = 1 if var == "p"
            	  
        replace B1 = "$<$0.001" if B1 == "0.000" & var == "p"
        replace B2 = "$<$0.001" if B2 == "0.000" & var == "p"
        replace B3 = "$<$0.001" if B3 == "0.000" & var == "p"
        replace B4 = "$<$0.001" if B4 == "0.000" & var == "p"
        replace B5 = "$<$0.001" if B5 == "0.000" & var == "p"
        replace B6 = "$<$0.001" if B6 == "0.000" & var == "p"
        replace B7 = "$<$0.001" if B7 == "0.000" & var == "p"

        replace B1 = subinstr(B1, "-", "$-$", 1)
        replace B2 = subinstr(B2, "-", "$-$", 1)
        replace B3 = subinstr(B3, "-", "$-$", 1)
        replace B4 = subinstr(B4, "-", "$-$", 1)
        replace B5 = subinstr(B5, "-", "$-$", 1)
        replace B6 = subinstr(B6, "-", "$-$", 1)
        replace B7 = subinstr(B7, "-", "$-$", 1)
 
	    rename var Variable
	    drop if keep != 1
	        drop keep
	    compress
	    
    texsave using "sr_sru.tex", title(Cox Proportional Hazard Coefficients For Unifying Multiple SRs (FSA Model), 1988 - 2006) size(footnotesize) marker(sr_sru_cox_ph) footnote("Standard errors are in parentheses. {*}/{*}{*}/{*}{*}{*} at 10/5/1\% significance levels. A number of other model specifications were tested that included variables such as the number of veto players \citep[see][]{keeferstasavage2003} suggested by \cite{Gilardi2008}. Democracy (UDS) and GDP/Captia were excluded because they were highly correlated with Bureaucratic Quality (0.413 and 0.734, respectively) and had very unstable coefficients. Bureaucratic Quality was kept in this analysis because it produced the strongest and most stable results. The spatial effect for East Asia was not included because none of the East Asian countries were in the risk set apart from China in 2005-2006. Results for models with the Crisis Dummy are not shown because when included the maximum likelihood estimation failed to converge. Stata's {\tt{estat phtest}} was used to test the proportional hazard's assumption.") frag nofix hlines(20) replace
       

////////////////
//  Fine \& Gray Competing Risks Coefficients for Reforms from CB/MoF to SR/U Supervision, 1988 - 2006
////////////////

use "http://dl.dropbox.com/u/12581470/code/Replicability_code/Financial_Supervision_Governance_Replication/public_fin_trans_data.dta", clear


    ///// Remove 1987 due to SE lag missing /////
    drop if year == 1987 
    
    gen percent_se_cbss_ocbu = se_cbss_ocbu*100
    gen percent_se_eu_ocbu = se_eu_ocbu*100
    gen percent_se_basel_ocbu = se_basel_ocbu*100
    gen percent_se_easia_ocbu = se_easia_ocbu*100

    // mi set data
    mi stset year, id(country) failure(reg_4state == 3) enter(reg_4state == 1) exit(reg_4state == 2 3 4) origin(min)


    
    ///// Base Fine & Gray output for tables /////
    
    mi estimate, shr: stcrreg gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4) 
        regsave using "cbmof_sru.dta", detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) replace table(C1, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg asset_diversity gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4) 
        regsave using "cbmof_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(C2, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg crisis6 gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4) 
        regsave using "cbmof_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(C3, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg imf_2 gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4) 
        regsave using "cbmof_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(C4, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4) 
        regsave using "cbmof_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(C5, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu gdp_2005_nse dbagdp concentration cbg_time_in_office, compete(reg_4state == 2 4) 
        regsave using "cbmof_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(C6, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    mi estimate, shr: stcrreg crisis6 imf_2 percent_se_cbss_ocbu percent_se_eu_ocbu percent_se_basel_ocbu percent_se_easia_ocbu, compete(reg_4state == 2 4) 
        regsave using "cbmof_sru.dta", append detail(all) coefmat(e(b_mi)) varmat(e(V_mi)) table(C7, order(regvars r2) format(%5.3f) paren(stderr) asterisk())
        
    ///// Create .tex file /////
    use cbmof_sru.dta, clear       
        //rename variables
        generate keep = regexm(var, "_stderr")
            replace var = "" if keep == 1
            
        replace var = "Crisis(Log)" if var == "eq1:crisis6_coef"
            replace keep = 1 if var == "Crisis(Log)"
        replace var = "IMF Stand-by" if var == "eq1:imf_2_coef"
            replace keep = 1 if var == "IMF Stand-by"
        replace var = "CBSS SE (SR/U)" if var == "eq1:percent_se_cbss_ocbu_coef"
            replace keep = 1 if var == "CBSS SE (SR/U)"
        replace var = "EU SE (SR/U)" if var == "eq1:percent_se_eu_ocbu_coef"
            replace keep = 1 if var == "EU SE (SR/U)"
        replace var = "Basel SE (SR/U)" if var == "eq1:percent_se_basel_ocbu_coef"
            replace keep = 1 if var == "Basel SE (SR/U)"
        replace var = "EA SE (SR/U)" if var == "eq1:percent_se_easia_ocbu_coef"
            replace keep = 1 if var == "EA SE (SR/U)"
        replace var = "GDP/Capita" if var == "eq1:gdp_2005_nse_coef"
            replace keep = 1 if var == "GDP/Capita" 
        replace var = "Asset Diversity" if var == "eq1:asset_diversity_coef"
            replace keep = 1 if var == "Asset Diversity"
        replace var = "DB Assets/GDP" if var == "eq1:dbagdp_coef"
            replace keep = 1 if var == "DB Assets/GDP"
        replace var = "Concentration" if var == "eq1:concentration_coef"
            replace keep = 1 if var == "Concentration" 
        replace var = "CBG Tenure" if var == "eq1:cbg_time_in_office_coef"
            replace keep = 1 if var == "CBG Tenure"
        replace var = "Countries at Risk" if var == "N_clust"
            replace keep = 1 if var == "Countries at Risk"
        replace var = "No. of Transitions" if var == "N_fail"
            replace keep = 1 if var == "No. of Transitions"
        replace var = "F" if var == "F_mi"
            replace keep = 1 if var == "F"
        replace keep = 1 if var == "p_mi"
            replace var = "p" if var == "p_mi"
            	  
        replace C1 = "$<$0.001" if C1 == "0.000" & var == "p"
        replace C2 = "$<$0.001" if C2 == "0.000" & var == "p"
        replace C3 = "$<$0.001" if C3 == "0.000" & var == "p"
        replace C4 = "$<$0.001" if C4 == "0.000" & var == "p"
        replace C5 = "$<$0.001" if C5 == "0.000" & var == "p"
        replace C6 = "$<$0.001" if C6 == "0.000" & var == "p"
        replace C7 = "$<$0.001" if C7 == "0.000" & var == "p"

        replace C1 = subinstr(C1, "-", "$-$", 1)
        replace C2 = subinstr(C2, "-", "$-$", 1)
        replace C3 = subinstr(C3, "-", "$-$", 1)
        replace C4 = subinstr(C4, "-", "$-$", 1)
        replace C5 = subinstr(C5, "-", "$-$", 1)
        replace C6 = subinstr(C6, "-", "$-$", 1)
        replace C7 = subinstr(C7, "-", "$-$", 1)
 
	    rename var Variable
	    drop if keep != 1
	        drop keep
	    compress

    texsave using "cbmof_sru.tex", title(Fine \& Gray Competing Risks Coefficients for Reforms from CB/MoF to Unified SR Supervision (FSA Model) others competing, 1988 - 2006) size(footnotesize) marker(cbmof_sru_fine_gray) footnote("Standard errors are in parentheses. {*}/{*}{*}/{*}{*}{*} at 10/5/1\% significance levels. All models were compared to similar models over the time period 1997 - 2007 to determine if the asset diversity variable produced different results. Diagnostic tests using Schoenfield-Type residuals \citep[see][]{Fine1999} and time interactions \citep[][214-215]{StataCorp.2009} were used to test the proportional hazards assumption. Bureaucratic Quality and Democracy (UDS) were excluded due to high insignificance and high correlation with GDP/Capita.") frag nofix hlines(22) replace
