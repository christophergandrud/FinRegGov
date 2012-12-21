****************
* Create cumulative financial supervisor graphs
* Christopher Gandrud
* 20 May 2011
*****************

// Prevelance of Actors ///////////////////////////////////////////////
use "~/Financial_Regulation_DV.dta", clear

// Generate year Totals
		
	gen CB_MoF= 1 if reg_4state == 1
	replace CB_MoF = 0 if reg_4state > 1
	
	gen OCB = 1 if reg_4state == 2
	replace OCB = 0 if reg_4state == 1	
	replace OCB = 0 if reg_4state == 3	
	replace OCB = 0 if reg_4state == 4	

		
	gen OCBU= 1 if reg_4state == 3
	replace OCBU = 0 if reg_4state == 1	
	replace OCBU = 0 if reg_4state == 2	
	replace OCBU = 0 if reg_4state == 4	

	
	gen ocb_cb = 1 if reg_4state == 4
	replace ocb_cb = 0 if reg_4state == 1	
	replace ocb_cb = 0 if reg_4state == 2
	replace ocb_cb = 0 if reg_4state == 3

		
	egen total_CB_MoF = total(CB_MoF), by(year)
	egen total_OCB = total(OCB), by(year)
	egen total_OCBU = total(OCBU), by(year)
	egen total_ocb_cb = total(ocb_cb), by(year)


	keep if country == "Afghanistan"
	keep year total_CB_MoF total_OCB total_OCBU total_ocb_cb
	
	gen year_total = total_CB_MoF + total_OCB + total_OCBU + total_ocb_cb
	
	gen CB_MoF = total_CB_MoF/year_total*100
	gen OCB = total_OCB/year_total*100
	gen OCBU = total_OCBU/year_total*100
	gen OCB_CB = total_ocb_cb/year_total*100
	
// Line Graph

twoway line CB_MoF year || line OCB year || line OCBU year || line OCB_CB year
/*
// Prevelance of Names ///////////////////////////////////////////////
use "http://dl.dropbox.com/u/12581470/Fin_Map/Gandrud_Financial_Regulation_DV.dta", clear

// Generate year Totals

	gen Neither= 1 if sec_reg_name == 1
	replace Neither = 0 if sec_reg_name > 1
	
	gen SEC = 1 if sec_reg_name == 2
	replace SEC = 0 if sec_reg_name == 1	
	replace SEC = 0 if sec_reg_name == 3	

		
	gen FSA= 1 if sec_reg_name == 3
	replace FSA = 0 if sec_reg_name == 1	
	replace FSA = 0 if sec_reg_name == 2	
	
	egen total_Neither = total(Neither), by(year)
	egen total_SEC = total(SEC), by(year)
	egen total_FSA = total(FSA), by(year)


	keep if country == "Afghanistan"
	keep year total_Neither total_SEC total_FSA 
		
	gen year_total = total_Neither + total_SEC + total_FSA
	
	gen Neither = total_Neither/year_total*100
	gen SEC = total_SEC/year_total*100
	gen FSA = total_FSA/year_total*100
	
// Line Graph

twoway line Neither year || line SEC year || line FSA year
	



