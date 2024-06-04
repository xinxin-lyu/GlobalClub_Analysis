global project "C:\Users\xinxi\Purdue\PublicGood_SecondOption4Rich\Experiment\"
* directory "$project\DataAnalysis"
global datafolder "$project\ProcessedData"
global outputfolder "$project\Output"



*************************************************************
/**/
* Excel file name: SummaryStatistics.xls
* For summary of treatments

import delimited "$datafolder\data_Oppor_allB.csv", clear
gen WithGlobal = 1
tempfile allB
save `allB', replace 

import delimited "$datafolder\data_noOppor_AllA.csv", clear
gen WithGlobal = 0
append using `allB'
merge m:1 participantcode using "$datafolder\individual_data"
drop _m

gen male=gender=="Male"
gen age_under20  = age=="Under 20"

// gen payment = totalpayoff * 0.000446
// tabstat payment, by(treatment_sum) stat(mean sd) format(%9.2f)
// tab treatment fc, sum(payment) 


tab treatment fc, sum(male) 
tab treatment fc, sum(age_under20) 


// * To import data Local only
import delimited "$datafolder\data_noOppor_AllA.csv", clear

gen treatment_sum = 0
replace treatment_sum=1 if fc==20 & treatment == "HOMO"
replace treatment_sum=2 if fc==80 & treatment == "HOMO"
replace treatment_sum=3 if fc==20 & treatment == "HETERO" & endowment==10
replace treatment_sum=4 if fc==20 & treatment == "HETERO" & endowment==30
replace treatment_sum=5 if fc==80 & treatment == "HETERO" & endowment==10
replace treatment_sum=6 if fc==80 & treatment == "HETERO" & endowment==30

gen localShare = playercontribution_local / endowment *100

gen localShare_g = playertotal_contribution_local/ 800 * 100

gen treatment_4 = 0
replace treatment_4 = 1 if  fc==20 & treatment == "HOMO"
replace treatment_4 = 2 if  fc==80 & treatment == "HOMO"
replace treatment_4 = 3 if  fc==20 & treatment == "HETERO"
replace treatment_4 = 4 if  fc==80 & treatment == "HETERO"

preserve 
collapse (sd) playerpayoff, by(sessioncode sequence subsessionsg subsessionperiod groupid_in_subsession treatment_4 ) 
tabstat playerpayoff , by(treatment_4) stat(mean sd n) format(%9.2f)



// L Only 
/// Round 1
tabstat localShare if subsessionperiod==1 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat localShare if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat localShare  , by(treatment_4) stat(mean sd n) format(%9.2f)
// First exposure Only
/// Round 1
tabstat localShare if (sequence=="A1" | sequence=="A2_bab") & subsessionperiod==1, by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat localShare if (sequence=="A1" | sequence=="A2_bab") & subsessionperiod<=10, by(treatment_4) stat(mean sd n) format(%9.2f)
*check for group average, different for Hetero
// tabstat localShare_g if (sequence=="A1" | sequence=="A2_bab") & subsessionperiod<=10, by(treatment_4) stat(mean sd n) format(%9.2f)

// Payoffs 
/// Round 1
tabstat playerpayoff if subsessionperiod==1 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat playerpayoff if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat playerpayoff  , by(treatment_4) stat(mean sd n) format(%9.2f)


/// Round 1
tabstat localShare if subsessionperiod==1 , by(treatment) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat localShare if subsessionperiod<=10 , by(treatment) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat localShare  , by(treatment) stat(mean sd n) format(%9.2f)

preserve 
collapse efficiency, by(sessioncode sequence subsessionsg subsessionperiod groupid_in_subsession treatment_4 playerlocal_community)
// Efficiency 
/// Round 1
tabstat efficiency if subsessionperiod==1 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat efficiency if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat efficiency  , by(treatment_4) stat(mean sd n) format(%9.2f)




/// All rounds
tabstat localShare if sequence=="A1" | sequence=="A2_bab", by(treatment_4) stat(mean sd n) format(%9.2f)


//* By endowments
// All supergames
/// Round 1
tabstat localShare if subsessionperiod==1 , by(treatment) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat localShare if subsessionperiod<=10 , by(treatment) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat localShare  , by(treatment) stat(mean sd n) format(%9.2f)
// First exposure Only
/// Round 1
tabstat localShare if (sequence=="A1" | sequence=="A2_bab") & subsessionperiod==1, by(treatment) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat localShare if (sequence=="A1" | sequence=="A2_bab") & subsessionperiod<=10, by(treatment) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat localShare if sequence=="A1" | sequence=="A2_bab", by(treatment) stat(mean sd n) format(%9.2f)



// Panel 1
// Only look at the first 10 matches 
// keep if subsessionperiod<=10


tabstat playercontribution_local, by(treatment_sum) stat(mean sd) format(%9.2f);


tabstat localShare, by(treatment_sum) stat(mean sd) format(%9.2f)

tabstat playerpayoff, by(treatment_sum) stat(mean sd) format(%9.2f)


* To import data with global club
import delimited "$datafolder\data_Oppor_allB.csv", clear
gen treatment_sum = 0
replace treatment_sum=1 if fc==20 & treatment == "HOMO" 
replace treatment_sum=2 if fc==80 & treatment == "HOMO" 
replace treatment_sum=3 if fc==20 & treatment == "HETERO" & (endowment==10 | endowment==8)
replace treatment_sum=4 if fc==20 & treatment == "HETERO" & (endowment==30 | endowment==28)
replace treatment_sum=5 if fc==80 & treatment == "HETERO" & (endowment==10 | endowment==2)
replace treatment_sum=6 if fc==80 & treatment == "HETERO" & (endowment==30 | endowment==22)

tab treatment_sum

gen localShare = playercontribution_local / endowment *100
gen globalShare = playercontribution_global / endowment * 100
gen totalShare = tot_contr / endowment * 100

gen treatment_4 = 0
replace treatment_4 = 1 if  fc==20 & treatment == "HOMO"
replace treatment_4 = 2 if  fc==80 & treatment == "HOMO"
replace treatment_4 = 3 if  fc==20 & treatment == "HETERO"
replace treatment_4 = 4 if  fc==80 & treatment == "HETERO"

// LG 
// Only look at first 4 supergames
// drop if sequence=="B2_bab"




* Contribution share
/// Round 1 
tabstat totalShare if subsessionperiod==1, by(treatment_4) stat(mean sd n) format(%9.2f)
// Round 1-10
tabstat totalShare if subsessionperiod<=10, by(treatment_4) stat(mean sd n) format(%9.2f)

tabstat totalShare if subsessionperiod<=10, by(treatment_sum) stat(mean sd n) format(%9.2f)
// All rounds
tabstat totalShare, by(treatment_4) stat(mean sd n) format(%9.2f) 
* Join behavior
/// Round 1 
tabstat playerjoin_club if subsessionperiod==1, by(treatment_4) stat(mean sd) format(%9.2f)
// Round 1-10
tabstat playerjoin_club if subsessionperiod<=10, by(treatment_4) stat(mean sd) format(%9.2f)
// All rounds
tabstat playerjoin_club, by(treatment_4) stat(mean sd) format(%9.2f)
* Global contribution share for those who joined
/// Round 1 
tabstat globalShare if subsessionperiod==1 & playerjoin_club==1, by(treatment_4) stat(mean sd) format(%9.2f)
// Round 1-10
tabstat globalShare if subsessionperiod<=10 & playerjoin_club==1, by(treatment_4) stat(mean sd) format(%9.2f)
// All rounds
tabstat globalShare if playerjoin_club==1, by(treatment_4) stat(mean sd) format(%9.2f)

/// Round 1 
tabstat playerpayoff if subsessionperiod==1 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat playerpayoff if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)

tabstat playerpayoff if subsessionperiod<=10 , by(treatment_sum) stat(mean sd n) format(%9.2f)

/// All rounds
tabstat playerpayoff  , by(treatment_4) stat(mean sd n) format(%9.2f)

//Efficiencies
preserve 
collapse efficiency, by(sessioncode sequence subsessionsg subsessionperiod groupid_in_subsession treatment_4 playerlocal_community)

//Round 1
tabstat efficiency efficiency2 if subsessionperiod==1 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat efficiency efficiency2 if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat efficiency efficiency2  , by(treatment_4) stat(mean sd n) format(%9.2f)

// Social benefit max
/// Round 1 
tabstat socialbenefitmax if subsessionperiod==1 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat socialbenefitmax if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat socialbenefitmax  , by(treatment_4) stat(mean sd n) format(%9.2f)

// Over club size
gen reletiveBenefit = efficiency/efficiency2
gen reletiveBenefit2 = socialbenefitmax / ( (160 - fc/10*8 )* 0.6 * 8) / 10
tabstat reletiveBenefit if subsessionperiod==1 , by(clubsize) stat(mean sd n) format(%9.2f)
// For LowC, by club size
tabstat reletiveBenefit2 efficiency2 if subsessionperiod==1 & fc==20, by(clubsize) stat(mean sd n) format(%9.2f) 
tabstat reletiveBenefit2 efficiency2 if subsessionperiod<=10 & fc==20, by(clubsize) stat(mean sd n) format(%9.2f) 
tabstat reletiveBenefit2 efficiency2 if   fc==20, by(clubsize) stat(mean sd n) format(%9.2f) 
// For HighC, by club size
tabstat reletiveBenefit2 efficiency2 if subsessionperiod==1 & fc==80, by(clubsize) stat(mean sd n) format(%9.2f) 
tabstat reletiveBenefit2 efficiency2 if subsessionperiod<=10 & fc==80, by(clubsize) stat(mean sd n) format(%9.2f) 
tabstat reletiveBenefit2 efficiency2 if   fc==80, by(clubsize) stat(mean sd n) format(%9.2f) 
// Relative benefit
/// Round 1 
tabstat reletiveBenefit2 if subsessionperiod==1 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// Round 1-10
tabstat reletiveBenefit2 if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)
/// All rounds
tabstat reletiveBenefit2  , by(treatment_4) stat(mean sd n) format(%9.2f)


// For the efficiency table 
preserve 
collapse efficiency reletiveBenefit2 efficiency2 clubsize, by(sessioncode sequence subsessionsg subsessionperiod groupid_in_subsession treatment_4 )

tabstat clubsize if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)

// LG total efficiency (over maximal possible )
tabstat efficiency if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)

// Stage 1 efficiency (measure how much resources were pooled )
tabstat reletiveBenefit2 if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)
// Stage 2 efficiency (measure realized payoff / maximal social benefits conditional on stage 1 choice )
tabstat efficiency2 if subsessionperiod<=10 , by(treatment_4) stat(mean sd n) format(%9.2f)



display 80*4*0.6*2
// 384
display (160 - 2*8 )* 0.6 * 8
//691.2
display (160 - 8*8 )* 0.6 * 8
//460.8
display 384/691.2
// = .55
display 384/460.8
// = .833


tabstat efficiency efficiency2 if subsessionperiod==1 , by(clubsize) stat(mean sd n) format(%9.2f)

gen global_to_total = playercontribution_global/(playertotal_contribution_local+playercontribution_global) //wrong!
gen global_to_total2  = playercontribution_global/tot_contr
replace global_to_total2=0 if tot_contr==0
tabstat globalShare if fc==20 , by(clubsize) stat(mean sd n) format(%9.2f)
tabstat global_to_total2 if fc==20 & treatment=="HOMO" & subsessionperiod<=10 & playerjoin_club==1, by(clubsize) stat(mean sd n) format(%9.2f)
tabstat global_to_total2 if fc==20 & treatment=="HETERO" & subsessionperiod<=10 & playerjoin_club==1, by(clubsize) stat(mean sd n) format(%9.2f)
tabstat global_to_total2 if fc==80 & treatment=="HOMO" & subsessionperiod<=10 & playerjoin_club==1, by(clubsize) stat(mean sd n) format(%9.2f)
tabstat global_to_total2 if fc==80 & treatment=="HETERO" & subsessionperiod<=10 & playerjoin_club==1, by(clubsize) stat(mean sd n) format(%9.2f)

preserve 
collapse (sd) playerpayoff, by(sessioncode sequence subsessionsg subsessionperiod groupid_in_subsession treatment_4 ) 
tabstat playerpayoff , by(treatment_4) stat(mean sd n) format(%9.2f)



// Panel 2
// Only look at the first 10 matches 
// keep if subsessionperiod<=10
tabstat playerjoin_club, by(treatment_sum) stat(mean sd) format(%9.2f)
;
tabstat playerpayoff, by(treatment_sum) stat(mean sd) format(%9.2f)


// Who joined
tabstat tot_contr if playerjoin_club==1, by(treatment_sum) stat(mean sd) format(%9.2f)
tabstat localShare if playerjoin_club==1, by(treatment_sum) stat(mean sd) format(%9.2f)
tabstat globalShare if playerjoin_club==1, by(treatment_sum) stat(mean sd) format(%9.2f)
tabstat playerpayoff if playerjoin_club==1, by(treatment_sum) stat(mean sd) format(%9.2f)

// Who didn't join
tabstat tot_contr if playerjoin_club==0, by(treatment_sum) stat(mean sd) format(%9.2f)
tabstat localShare if playerjoin_club==0, by(treatment_sum) stat(mean sd) format(%9.2f)
tabstat globalShare if playerjoin_club==0, by(treatment_sum) stat(mean sd) format(%9.2f)
tabstat playerpayoff if playerjoin_club==0, by(treatment_sum) stat(mean sd) format(%9.2f)
;
*/


/*******************************************************************************/
// Order effect
/*******************************************************************************/

* To import data Local only

// First: compare round 1 contribution 
import delimited "$datafolder\data_noOppor_AllA.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 L")
putexcel A1 = "R1 L"
keep if sequence!="A2" & subsessionround_number==1
tab sequence	

* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_noOppor_AllA.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR L")
putexcel A1 = "AllR L"
keep if sequence!="A2" 
collapse playercontribution_local, by(sequence participantcode treatment groupfc)

tab sequence	

* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

***********************************************************************************
* To import data Local/Global only
* Compare local contribution 
// First: compare round 1 contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 LG local contribution")
putexcel A1 = "R1 L/G"
keep if sequence!="B2_bab" & subsessionround_number==1
tab sequence	

* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG local contribution")
putexcel A1 = "AllR L/G"
keep if sequence!="B2_bab" 
collapse playercontribution_local, by(sequence participantcode treatment groupfc)

tab sequence	

* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

* Compare willingness to join the club 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 LG join ratio")
putexcel A1 = "R1 L/G "
keep if subsessionround_number==1
keep if sequence!="B2_bab" 


* All treatments
local lineNumber = 2
tabstat playerjoin_club , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)

//
// ksmirnov playerjoin_club, by(sequence) exact
// putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
// putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)
//
//
// ranksum playerjoin_club, by(sequence)
// putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
// putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)

tab playerjoin_club sequence, all exact
putexcel D`lineNumber'  = "Pearson chi2(1) p-value"
putexcel D`lineNumberPlus1'  = `r(p)', nformat(number_d2)
putexcel E`lineNumber'  = "Fisher's exact"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)




local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
// 	ksmirnov playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
// 	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
//
// 	ranksum playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence)
// 	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
		
	tab playerjoin_club sequence if treatment=="`endow'" & groupfc==`cost', all exact
	putexcel D`lineNumberTreatment'  = `r(p)', nformat(number_d2)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG join ratio")
putexcel A1 = "AllR L/G"
keep if sequence!="B2_bab" 
collapse  playerjoin_club, by(sequence participantcode treatment groupfc)

tab sequence	

* All treatments
local lineNumber = 2
tabstat playerjoin_club , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playerjoin_club, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playerjoin_club, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)



// tab playerjoin_club sequence, all exact
// putexcel D`lineNumber'  = "Pearson chi2(1) p-value"
// putexcel D`lineNumberPlus1'  = `r(p)', nformat(number_d2)
// putexcel E`lineNumber'  = "Fisher's exact"
// putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

// 	tab playerjoin_club sequence if treatment=="`endow'" & groupfc==`cost', all exact
// 	putexcel D`lineNumberTreatment'  = `r(p)', nformat(number_d2)
// 	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}




* Compare total contribution 
// First: compare round 1 contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 LG total contribution")
putexcel A1 = "R1 L/G"
keep if sequence!="B2_bab" & subsessionround_number==1
tab sequence	

* All treatments
local lineNumber = 2
tabstat  tot_contr , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov  tot_contr, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum  tot_contr, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG total contribution")
putexcel A1 = "AllR L/G"
keep if sequence!="B2_bab" 
collapse  tot_contr, by(sequence participantcode treatment groupfc)

tab sequence	

* All treatments
local lineNumber = 2
tabstat  tot_contr , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov  tot_contr, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum  tot_contr, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

*******************************************************************************
**************** Add the last sequence to see whether it balances out a bit
*******************************************************************************
* To import data Local only

// First: compare round 1 contribution 
import delimited "$datafolder\data_noOppor_AllA.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 L2")
putexcel A1 = "R1 L Seq2"
keep if subsessionround_number==1
tab sequence	
* Add the last supergame in
replace sequence = "A1" if sequence=="A2"
collapse  playercontribution_local, by(sequence participantcode treatment groupfc)
tab sequence	


* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_noOppor_AllA.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR L2")
putexcel A1 = "AllR L Seq2"
replace sequence = "A1" if sequence=="A2"
collapse playercontribution_local, by(sequence participantcode treatment groupfc)
tab sequence	

* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}


***********************************************************************************
* To import data Local/Global only

* Compare local contribution 
// First: compare round 1 contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 LG2 local contribution")
putexcel A1 = "R1 L/G 2Seq"
keep if subsessionround_number==1
replace sequence = "B1_bab" if sequence=="B2_bab"
tab sequence	
collapse playercontribution_local, by(sequence participantcode treatment groupfc)
tab sequence	


* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG2 local contribution")
putexcel A1 = "AllR L/G Seq2"
replace sequence = "B1_bab" if sequence=="B2_bab"
tab sequence	
collapse playercontribution_local, by(sequence participantcode treatment groupfc)

tab sequence	

* All treatments
local lineNumber = 2
tabstat playercontribution_local , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playercontribution_local, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playercontribution_local, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playercontribution_local if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}


* Compare willingness to join the club 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 LG2 join ratio")
putexcel A1 = "R1 L/G 2Seq"
keep if subsessionround_number==1
replace sequence = "B1_bab" if sequence=="B2_bab"
tab sequence	
collapse playerjoin_club, by(sequence participantcode treatment groupfc)
tab sequence	


* All treatments
local lineNumber = 2
tabstat playerjoin_club , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


// ksmirnov playerjoin_club, by(sequence) exact
// putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
// putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)
//
//
// ranksum playerjoin_club, by(sequence)
// putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
// putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


tab playerjoin_club sequence, all exact
putexcel D`lineNumber'  = "Pearson chi2(1) p-value"
putexcel D`lineNumberPlus1'  = `r(p)', nformat(number_d2)
putexcel E`lineNumber'  = "Fisher's exact"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
// 	ksmirnov playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
// 	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
//
// 	ranksum playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence)
// 	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	tab playerjoin_club sequence if treatment=="`endow'" & groupfc==`cost', all exact
	putexcel D`lineNumberTreatment'  = `r(p)', nformat(number_d2)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG2 join ratio")
putexcel A1 = "AllR L/G Seq2"
replace sequence = "B1_bab" if sequence=="B2_bab"
tab sequence	
collapse playerjoin_club, by(sequence participantcode treatment groupfc)

tab sequence	

* All treatments
local lineNumber = 2
tabstat playerjoin_club , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov playerjoin_club, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum playerjoin_club, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)

	
// tab playerjoin_club sequence, all exact
// putexcel D`lineNumber'  = "Pearson chi2(1) p-value"
// putexcel D`lineNumberPlus1'  = `r(p)', nformat(number_d2)
// putexcel E`lineNumber'  = "Fisher's exact"
// putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)

local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

// 	tab playerjoin_club sequence if treatment=="`endow'" & groupfc==`cost', all exact
// 	putexcel D`lineNumberTreatment'  = `r(p)', nformat(number_d2)
// 	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}




* Compare total contribution 
// First: compare round 1 contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("R1 LG2 total contribution")
putexcel A1 = "R1 L/G Seq2"
keep if  subsessionround_number==1
replace sequence = "B1_bab" if sequence=="B2_bab"
tab sequence	
collapse tot_contr, by(sequence participantcode treatment groupfc)

tab sequence	

* All treatments
local lineNumber = 2
tabstat  tot_contr , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov  tot_contr, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum  tot_contr, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

// Second: compare all round average contribution 
import delimited "$datafolder\data_Oppor_allB.csv", clear
putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG2 total contribution")
putexcel A1 = "AllR L/G Seq2"
replace sequence = "B1_bab" if sequence=="B2_bab"
collapse  tot_contr, by(sequence participantcode treatment groupfc)
tab sequence	

* All treatments
local lineNumber = 2
tabstat  tot_contr , by(sequence) stat(mean sd) format(%9.2f) save

putexcel B`lineNumber' = "`r(name1)'" 
putexcel C`lineNumber' = "`r(name2)'" 
// Record mean, sd
local lineNumberPlus1 = `lineNumber' + 1
putexcel A`lineNumberPlus1' = "All"
putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


ksmirnov  tot_contr, by(sequence) exact
putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


ranksum  tot_contr, by(sequence)
putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


local lineNumberTreatment = `lineNumberPlus1' + 2

* Each treatment
foreach endow in "HETERO" "HOMO"{
    foreach cost in 20 80 {
    display "`endow', `cost'"

	putexcel A`lineNumberTreatment' = "`endow', `cost'"
	tabstat  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
	putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
	
	ksmirnov  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
	putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

	ranksum  tot_contr if treatment=="`endow'" & groupfc==`cost', by(sequence)
	putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
	local lineNumberTreatment = `lineNumberTreatment' + 2

	}
}

*******************************************************************************
*** Present each super game's average
*******************************************************************************
// compare all round average LOCAL contribution shares
import delimited "$datafolder\data_Oppor_allB.csv", clear
gen tot_contr_shares = playercontribution_local / endowment * 100
drop if sequence=="B2_bab" // remove the 5th supergame in LG
forvalues sg = 1/3 {
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG`sg' total c shares")
	putexcel A1 = "AllR LG`sg'"

	preserve 
	keep if subsessionsg==`sg'
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  tot_contr_shares, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  tot_contr_shares , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


	ksmirnov  tot_contr_shares, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	ranksum  tot_contr_shares, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
		ksmirnov  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

		ranksum  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore
}

*** Supergame 5
import delimited "$datafolder\data_Oppor_allB.csv", clear
gen tot_contr_shares = playercontribution_local / endowment * 100
keep if sequence=="B2_bab" // remove the 5th supergame in LG
local sg = 5
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG`sg' total c shares")
	putexcel A1 = "AllR LG`sg'"

	preserve 
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  tot_contr_shares, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  tot_contr_shares , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


// 	ksmirnov  tot_contr_shares, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = 0, nformat(number_d2)


// 	ranksum  tot_contr_shares, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  =0, nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
// 		ksmirnov  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = 0, nformat(number_d2)

// 		ranksum  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = 0, nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore
	
	
****************************************************
*************** For L 
***************************************************
// compare all round average LOCAL contribution shares
import delimited "$datafolder\data_noOppor_AllA.csv", clear
gen tot_contr_shares = tot_contr / endowment * 100
drop if sequence=="A2" // remove the 5th supergame in L
local sg =1
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR L`sg' total c shares")
	putexcel A1 = "AllR L`sg'"

	preserve 
	keep if subsessionsg==`sg'
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  tot_contr_shares, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  tot_contr_shares , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


	ksmirnov  tot_contr_shares, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	ranksum  tot_contr_shares, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
		ksmirnov  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

		ranksum  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore


*** Supergame 5
import delimited "$datafolder\data_noOppor_AllA.csv", clear
gen tot_contr_shares = tot_contr / endowment * 100
keep if sequence=="A2" // keep the 5th supergame in L
local sg = 5
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR L`sg' total c shares")
	putexcel A1 = "AllR L`sg'"

	preserve 
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  tot_contr_shares, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  tot_contr_shares , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


// 	ksmirnov  tot_contr_shares, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = 0, nformat(number_d2)


// 	ranksum  tot_contr_shares, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  =0, nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
// 		ksmirnov  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = 0, nformat(number_d2)

// 		ranksum  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = 0, nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore
	
********************** compare all round average join**********************	

import delimited "$datafolder\data_Oppor_allB.csv", clear
drop if sequence=="B2_bab" // remove the 5th supergame in LG
forvalues sg = 1/3 {
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG`sg' join")
	putexcel A1 = "AllR LG`sg'"

	preserve 
	keep if subsessionsg==`sg'
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  playerjoin_club, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  playerjoin_club , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


	ksmirnov  playerjoin_club, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	ranksum  playerjoin_club, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
		ksmirnov  playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

		ranksum  playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore
}

*** Supergame 5
import delimited "$datafolder\data_Oppor_allB.csv", clear
keep if sequence=="B2_bab" // remove the 5th supergame in LG
local sg = 5
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR LG`sg' join")
	putexcel A1 = "AllR LG`sg'"

	preserve 
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  playerjoin_club, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  playerjoin_club , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


// 	ksmirnov  tot_contr_shares, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = 0, nformat(number_d2)


// 	ranksum  tot_contr_shares, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  =0, nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  playerjoin_club if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
// 		ksmirnov  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = 0, nformat(number_d2)

// 		ranksum  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = 0, nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore
	
	
****************************************************
*************** For L 
***************************************************
// compare all round average LOCAL contribution shares
import delimited "$datafolder\data_noOppor_AllA.csv", clear
gen tot_contr_shares = tot_contr / endowment * 100
drop if sequence=="A2" // remove the 5th supergame in L
local sg =1
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR L`sg' total c shares")
	putexcel A1 = "AllR L`sg'"

	preserve 
	keep if subsessionsg==`sg'
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  tot_contr_shares, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  tot_contr_shares , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


	ksmirnov  tot_contr_shares, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	ranksum  tot_contr_shares, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  = `r(p_exact)', nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
		ksmirnov  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)

		ranksum  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = `r(p_exact)', nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore


*** Supergame 5
import delimited "$datafolder\data_noOppor_AllA.csv", clear
gen tot_contr_shares = tot_contr / endowment * 100
keep if sequence=="A2" // keep the 5th supergame in L
local sg = 5
	putexcel set "$outputfolder\04-SummaryStatistics-order", modify sheet("AllR L`sg' total c shares")
	putexcel A1 = "AllR L`sg'"

	preserve 
	// replace sequence = "B1_bab" if sequence=="B2_bab"
	collapse  tot_contr_shares, by(sequence participantcode treatment groupfc)
	tab sequence	

	* All treatments
	local lineNumber = 2
	tabstat  tot_contr_shares , by(sequence) stat(mean sd) format(%9.2f) save

	putexcel B`lineNumber' = "`r(name1)'" 
	putexcel C`lineNumber' = "`r(name2)'" 
	// Record mean, sd
	local lineNumberPlus1 = `lineNumber' + 1
	putexcel A`lineNumberPlus1' = "All"
	putexcel B`lineNumberPlus1' = matrix(r(Stat1)),   nformat(number_d2) 
	putexcel C`lineNumberPlus1' = matrix(r(Stat2)), nformat(number_d2)


// 	ksmirnov  tot_contr_shares, by(sequence) exact
	putexcel D`lineNumber'  = "Kolmogorov–Smirnov equality-of-distributions test exact p-value"
	putexcel D`lineNumberPlus1'  = 0, nformat(number_d2)


// 	ranksum  tot_contr_shares, by(sequence)
	putexcel E`lineNumber'  = "Two-sample Wilcoxon rank-sum (Mann-Whitney) test p-value"
	putexcel E`lineNumberPlus1'  =0, nformat(number_d2)


	local lineNumberTreatment = `lineNumberPlus1' + 2

	* Each treatment
	foreach endow in "HETERO" "HOMO"{
		foreach cost in 20 80 {
		display "`endow', `cost'"

		putexcel A`lineNumberTreatment' = "`endow', `cost'"
		tabstat  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) stat(mean sd) format(%9.2f) save
		putexcel B`lineNumberTreatment' = matrix(r(Stat1)),   nformat(number_d2) 
		putexcel C`lineNumberTreatment' = matrix(r(Stat2)), nformat(number_d2)
		
// 		ksmirnov  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence) exact
		putexcel D`lineNumberTreatment'  = 0, nformat(number_d2)

// 		ranksum  tot_contr_shares if treatment=="`endow'" & groupfc==`cost', by(sequence)
		putexcel E`lineNumberTreatment'  = 0, nformat(number_d2)
		local lineNumberTreatment = `lineNumberTreatment' + 2

		}
	}
	restore

