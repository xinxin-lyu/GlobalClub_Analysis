global project "C:\Users\xinxi\Purdue\PublicGood_SecondOption4Rich\Experiment\"
* directory "$project\DataAnalysis"
global datafolder "$project\ProcessedData"
global outputfolder "$project\Output"

* This file is created to compare at group level, whether people behave differently 
* between L and L/G

*************************************************************
//
// *  Use frequency counting *************
//
// import delimited "$datafolder\individual_type_allInfor.csv", clear
// egen total=rowtotal(type*)
// sum total
// sum type* min
// sum min,det
//
// * use this type (rough classification) to see whether there is a difference 
// keep participantcode type*
// tempfile indi_type_rough
// save `indi_type_rough'
//
// preserve
// import delimited "$datafolder\individual_type.csv", clear
// egen total=rowtotal(type*)
// tempfile A1
// save `A1'
// restore
//
// preserve
// import delimited "$datafolder\individual_typeA2.csv", clear
// // rename type* A2type*
// tempfile A2
// save `A2'
// restore
// // merge 1:1 participantcode using `A2'
// append using `A1'
// append using `A2'
//
// collapse type*, by(participantcode)
// egen consistent =  rmax(type*)
// tab consistent
// br if consistent<.5
// * Use all infor, only 4 totally different (self-interest + altruistic)
// // "dlwsfifn" 
// // "mtdu10l3"
// // "o8ukh025"
// // "t3sugr4n"

******Variable generated in 05-RegressionAll-v3.do***********************************************
import delimited "$datafolder\data_Oppor_allB.csv", clear
gen WithGlobal = 1
tempfile allB
save `allB', replace 

import delimited "$datafolder\individual_type_allInfor.csv", clear
keep participantcode type*
tempfile type
save `type', replace 

import delimited "$datafolder\data_noOppor_AllA.csv", clear
gen WithGlobal = 0
append using `allB'
merge m:1 participantcode using "$datafolder\individual_data"
drop _m
merge m:1 participantcode using `type'

tab WithGlobal

* Generate variables 
//super game
tab subsessionsg
tab sequence
gen super_game = subsessionsg
// ABA
replace super_game = subsessionsg+1 if sequence == "B1"
replace super_game = subsessionsg+4 if sequence == "A2"
// BAB
replace super_game = subsessionsg+3 if sequence == "A2_bab"
replace super_game = subsessionsg+4 if sequence == "B2_bab"
tab super_game

// Round
gen round_whole = subsessionround_number
// ABA
replace round_whole =  subsessionround_number + 10 if sequence == "B1"
replace round_whole =  subsessionround_number + 60 if sequence == "A2"
// BAB
replace round_whole =  subsessionround_number + 50 if sequence == "A2_bab"
replace round_whole =  subsessionround_number + 70 if sequence == "B2_bab"
encode participantcode, gen(subject_id)
xtset subject_id round_whole

// No Local Interaction 
gen no_local = 0
replace no_local = 1 if sequence=="B1_bab"

gen interaction_term = WithGlobal * no_local 
label var interaction_term "With global * No previous local only interaction "

gen lowFC = fc==20
gen hetero = treatment == "HETERO"
gen highFC = 1- lowFC

gen endowment_adj = endowment
replace endowment = 10 if endowment<=10
replace endowment = 20 if endowment>10 & endowment<=20
replace endowment = 30 if endowment>20 

gen hetero_high = hetero * (endowment==30)
gen hetero_low = hetero * (endowment==10)

gen hetero_lowCost = hetero * lowFC
gen hetero_highCost = hetero * highFC


gen With_High_Cost = WithGlobal* (lowFC==0)
gen With_High_Cost_Join = WithGlobal* (lowFC==0) *playerjoin_club


// Hetero * WithGlobal 
gen hetero_with = hetero * WithGlobal
gen hetero_high_with = hetero_high * WithGlobal
// triple interaction 
gen WithGlobal_join = WithGlobal * playerjoin_club
gen hetero_with_join = hetero_with * playerjoin_club
gen hetero_high_with_join = hetero_high_with * playerjoin_club


// encode some string variables 
encode age, gen(age_g)
gen male=gender=="Male"
// replace male = . if gender=="Prefer Not to Say" // 2 subjects prefer not to say
gen age_under20  = age=="Under 20"
gen major_SorE =  0
replace major_SorE =  1 if strpos(major, "Economics or Management" )|strpos(major, "STEM" )
tab major_SorE major

// ? do I want to control others' contribution? 
gen share_contr = tot_contr * 10 / playerendowment
// generate others' contribution 
gen global_o = grouptotal_contribution_global - playercontribution_global
gen local_o = playertotal_contribution_local - playercontribution_local


bys sessioncode round_whole groupid_in_subsession: gen clubSize = sum(playerjoin_club)
bys sessioncode round_whole playerlocal_community: gen club_LocalN = sum(playerjoin_club)
gen club_LocalMembersNotMe = club_LocalN - playerjoin_club
gen club_OtherCommunityMembers = clubSize - club_LocalN 


gen join_HighE = playerjoin_club * (endowment==30)
gen join_LowE = playerjoin_club * (endowment==10)

bys sessioncode round_whole groupid_in_subsession: gen clubJoinH = sum(join_HighE)
gen share_club_joinH = clubJoinH / clubSize
replace share_club_joinH = 0  if clubSize==0

gen clubSize_join = clubSize * playerjoin_club



* Whether the benefit from club exceeds the entry cost
gen dummy_payoff = 0 
gen benefit_club = grouptotal_contribution_global*0.6 
replace dummy_payoff=1  if benefit_club >fc
tabstat grouptotal_contribution_global if fc==20 & strpos(sequence,"B"), by(dummy_payoff)
tabstat grouptotal_contribution_global if fc==80 & strpos(sequence,"B"), by(dummy_payoff)
tabstat dummy_payoff if fc==20 & strpos(sequence,"B"), by(treatment)
tabstat dummy_payoff if fc==80 & strpos(sequence,"B"), by(treatment)

gen hetero_join = hetero * playerjoin_club
// Additional control variables
xtset subject_id round_whole

//hard coding, relevant to the random number realization: B1 = [6,18,17]; B2 = [8]

 gen round_within = subsessionround_number
 replace round_within = round_within - 10 if subsessionround_number>10 & subsessionround_number <=30
  replace round_within = round_within - 30 if subsessionround_number>30
  

// round 1 join decision vs next round join decision 
gen round1_join = playerjoin_club if subsessionperiod==1
bys subject_id: gen join_nextRound = f.playerjoin_club
// replace join_nextRound = round1_join if subsessionperiod==1
//hard coding, relevant to the random number realization: B1 = [6,18,17]; B2 = [8]
replace join_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 

gen round1_globalCtr = playercontribution_global if subsessionperiod==1
bys subject_id: gen globalContr_nextRound = f.playercontribution_global
replace globalContr_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 

gen round1_localCtr = playercontribution_local if subsessionperiod==1
bys subject_id: gen localContr_nextRound = f.playercontribution_local
replace localContr_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 

bys subject_id: gen clubSize_nextRound = f.clubSize
replace clubSize_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
// for round 1, use the same variable (WHY?)
// replace clubSize_nextRound = clubSize if subsessionround_number==1

bys subject_id: gen clubJoinH_nextRound = f.clubJoinH
replace clubJoinH_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
// for round 1, use the same variable
// replace clubJoinH_nextRound = clubJoinH if subsessionround_number==1

bys subject_id: gen club_LocalMembersNotMe_nextRound = f.club_LocalMembersNotMe
replace club_LocalMembersNotMe_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
bys subject_id: gen club_OtherCommunity_nextRound = f.club_OtherCommunityMembers
replace club_OtherCommunity_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 


gen round1_totCtr = tot_contr if subsessionperiod==1
bys subject_id: gen totCtr_nextRound = f.tot_contr
replace totCtr_nextRound = . if (subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 ) & strpos(sequence, "B1")
replace totCtr_nextRound = . if subsessionround_number==10  & strpos(sequence, "A1")
replace totCtr_nextRound = . if subsessionround_number==20  & strpos(sequence, "A2")
replace totCtr_nextRound = . if subsessionround_number==10  & strpos(sequence, "B2")

* Total contribution 
bys subject_id: gen TTC_g_lastR = l.grouptotal_contribution_global
bys subject_id: gen TTC_l_lastR = l.playertotal_contribution_local
foreach v of var TTC_g_lastR TTC_l_lastR {
	replace `v' = . if subsessionround_number==1 
	replace `v' = . if (subsessionround_number==11 | subsessionround_number==31 ) & strpos(sequence, "B1")
	replace `v' = . if subsessionround_number==11  & strpos(sequence, "A1")
	replace `v' = . if subsessionround_number==21  & strpos(sequence, "A2")
	replace `v' = . if subsessionround_number==11  & strpos(sequence, "B2")
}


gen share_totalContr = tot_contr / endowment_adj * 100
sum share_totalContr share_contr	

gen round1_totCtr_share = share_totalContr if subsessionperiod==1
bys subject_id: gen totCtr_share_nextRound = f.share_totalContr
replace totCtr_share_nextRound = . if (subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 ) & strpos(sequence, "B1")
replace totCtr_share_nextRound = . if subsessionround_number==10  & strpos(sequence, "A1")
replace totCtr_share_nextRound = . if subsessionround_number==20  & strpos(sequence, "A2")
replace totCtr_share_nextRound = . if subsessionround_number==10  & strpos(sequence, "B2")

// replace totCtr_nextRound = tot_contr if subsessionperiod==1
// To check
 br round_whole subsessionsg tot_contr totCtr_nextRound round1_totCtr subsessionround_number

gen globalCtr_share = playercontribution_global / playerendowment*1000 if playerjoin_club==1
replace globalCtr_share = 0 if playerjoin_club==0 &  WithGlobal==1


gen round1_share_tt = share_contr*100 if subsessionperiod==1
bys subject_id: gen share_tt_nextRound = f.share_contr*100
replace share_tt_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
replace share_tt_nextRound = round1_share_tt if subsessionperiod==1
// for round 1, use the same variable
// replace share_tt_nextRound = share_contr if subsessionround_number==1

* Obtain contribution history (lagged)
bys subject_id: gen totCtr_lastRound = l.tot_contr
replace totCtr_lastRound = . if subsessionperiod == 1

foreach var of varlist playercontribution_local playercontribution_global local_o {
	gen `var'_lastR = l.`var'
	replace `var'_lastR = . if subsessionperiod == 1
}

// FIll in the round 1 data (for the control variable)
bys subject_id super_game : replace round1_join = round1_join[_n-1] if round1_join==. & _n >1
bys subject_id super_game : replace round1_globalCtr = round1_globalCtr[_n-1] if round1_globalCtr==. & _n >1
bys subject_id super_game : replace round1_localCtr = round1_localCtr[_n-1] if round1_localCtr==. & _n >1
bys subject_id super_game : replace round1_totCtr = round1_totCtr[_n-1] if round1_totCtr==. & _n >1
bys subject_id super_game : replace round1_totCtr_share = round1_totCtr_share[_n-1] if round1_totCtr_share==. & _n >1


bys sessioncode  sequence subsessionround_number  groupid_in_subsession: egen join_t = sum(playerjoin_club)
sum join_t clubsize if strpos(sequence, "B1")
gen join_lastGC = playercontribution_global_lastR * playerjoin_club
bys sessioncode  sequence subsessionround_number  groupid_in_subsession: egen join_lastGC_t = sum(join_lastGC)

gen join_lastGC_t_o = join_lastGC_t - join_lastGC
sum join_lastGC_t_o if strpos(sequence, "A")

gen highFC_j = highFC * join_nextRound
replace highFC_j = highFC * playerjoin_club if subsessionperiod==1
gen hetero_j = hetero * join_nextRound
replace hetero_j = hetero * playerjoin_club if subsessionperiod==1
gen hetero_highCost_j = hetero * highFC * join_nextRound
replace hetero_highCost_j = hetero * highFC * playerjoin_club if subsessionperiod==1


gen global_share_r1  = round1_globalCtr/round1_totCtr * 100
gen global_share  = globalContr_nextRound/totCtr_nextRound * 100
replace global_share = 0 if global_share==. & totCtr_nextRound!=.

* Dress up the variable names
gen round_d80 = round_whole/80

replace local_o = local_o/100
replace global_o = global_o /100
replace tot_contr = tot_contr
gen tot_contr_o100 = tot_contr/100
gen round_o10 = subsessionperiod/10
gen local_contr_o100 = playercontribution_local/100

label var round_d80 "Round Number /  80"
label var hetero "Hetero"
label var lowFC "Low entry cost"
label var hetero_lowCost "Hetero $\times$  LowC"

label var super_game "Super game number"
label var round_whole "Round number"
label var tot_contr "Own total contribution in round t / 100"
label var local_o "Other's local contribution in round t / 100 "
label var global_o "Other's global contribution in round t / 100 "
label var local_contr_o100 "Own local contribution in round t / 100"
label var age_under20 "Age under 20"
label var male "Male"
label var social_x "Disadvantageous inequality aversion"
label var social_y "Advantageous inequality aversion"
label var clubSize "Global club size in round t"
label var share_club_joinH "Club share of the high-endowed in round t"

label var hetero_join "Hetero $\times$ Join"
label var playerjoin_club "Join in round t"
label var join_HighE  "Join * High endowment "
label var join_LowE  "Join * Low endowment "
label var clubSize_join "Club size upon joining"

label var subsessionperiod "Round number"

label var club_OtherCommunityMembers "Number of other community's members in the club"
label var club_LocalMembersNotMe "Number of local members in the club"
label var dummy_payoff "Dummy of benefit from club exceeding the entry cost"
label var round_o10 "Round number / 10"



gen L_Environment = strpos(sequence,"A")

* To ensure that this file reports all the regression results for the main text
// keep if subsessionperiod<=10 
// drop if sequence=="B2_bab" | sequence=="A2"
tab sequence
gen localTotalContr = playertotal_contribution_local / 10
gen globalTotalContr = grouptotal_contribution_global / 10

* Total includes the total local + global if join in the next round
gen LocalGlobalTotalContr = grouptotal_contribution_global/10 * join_nextRound + localTotalContr


egen group = group(participantcode)


 gen type_agg = ""
 replace type_agg = "selfish" if typeselfinterestd==1
  replace type_agg = "altruistic" if typealtruismd==1
 replace type_agg = "conditional" if type11conditionald==1 | type12conditionald==1
replace type_agg = "grim" if typegrimd==1



**********Analysis part ***********************
**1. Count how many contributed fully in L, LG

// tab share_contr if WithGlobal==0 & subsessionperiod==1 & sequence!="A2"
// tab share_contr if WithGlobal==0 & subsessionperiod==2 & sequence!="A2" & round1_totCtr_share==100  
// * Only 20 subjects
// tab  share_tt_nextRound if WithGlobal==0 & subsessionperiod==1 & sequence!="A2" & share_contr==1 
// tab  playertotal_contribution_local if WithGlobal==0 & subsessionperiod==1 & sequence!="A2" & share_contr==1 
//
//
// tab share_contr if WithGlobal==1 & subsessionround_number==1 & sequence!="B2_bab"
//
// **2. Generate a table to count join-nojoin; no join
// tab join_nextRound if playerjoin_club==0
// tab join_nextRound if playerjoin_club==1
//
//
// ** 3. Generate a linear correlation between tot_contr and group previour round total contribution,record the coefficient
// putexcel set "$outputfolder\08-Individual-Analysis", modify sheet("Linear Regression")
// putexcel A1 = "participant code"
// putexcel B1 = "L, beta"
// putexcel C1 = "L, constant"
// putexcel D1 = "LG, beta ()"
// putexcel E1 = "LG, constant ()"
// putexcel F1 = "LG, beta (local, join)"
// putexcel G1 = "LG, constant (local, join)"
// putexcel H1 = "LG, beta (global, join)"
// putexcel I1 = "LG, constant (global, join)"
// putexcel J1 = "LG, beta (local, not join)"
// putexcel K1 = "LG, constant (local,not join)"
// putexcel L1 = "endowment"
//
//
//
// su group, meanonly
// foreach i of num 1/`r(max)' {
// 	local j = `i'+1
// 	tab participantcode if group==`i'
// 	putexcel A`j'=`i'
//
// 	reg totCtr_nextRound localTotalContr if WithGlobal==0  & group==`i'
// 	matrix l = e(b)
// 	putexcel B`j' = l[1,1]
// 	putexcel C`j' = l[1,2]
//	
// 	reg totCtr_nextRound LocalGlobalTotalContr if WithGlobal==1  & group==`i'
// 	matrix lg = e(b)
// 	putexcel D`j' = lg[1,1]
// 	putexcel E`j' = lg[1,2]
//	
// 	cap reg localContr_nextRound localTotalContr if WithGlobal==1  & group==`i' & join_nextRound==1
// 	if _rc==0 {
// 	matrix lg = e(b)
// 	putexcel F`j' = lg[1,1]
// 	putexcel G`j' = lg[1,2]
// 	}
// 	cap reg globalContr_nextRound globalTotalContr if WithGlobal==1  & group==`i' & join_nextRound==1
// 	if _rc==0 {
// 	matrix lg = e(b)
// 	putexcel H`j' = lg[1,1]
// 	putexcel I`j' = lg[1,2]
// 	}
//
// 	cap reg localContr_nextRound localTotalContr if WithGlobal==1  & group==`i' & join_nextRound==0
// 	if _rc==0 {
// 	matrix lg = e(b)
// 	putexcel J`j' = lg[1,1]
// 	putexcel K`j' = lg[1,2]
// 	}
//	
// 	sum endowment if group==`i'
// 	putexcel L`i' = `r(mean)'
//  }
//  rename type_LCP type_LCP_allR
 preserve
  import excel "$outputfolder\08-Individual-Analysis", sheet("Linear Regression") firstrow clear
rename participantcode group
gen type_LCP = ""
replace type_LCP = "altruistic" if share_0>=.5 & Share_for_80>=.5
replace type_LCP = "selfish" if share_0<=.5 & Share_for_80<=.5
// replace type_LCP = "conditional_full" if share_0<=.1 & Share_for_80>=.9
replace type_LCP = "reciprocator" if share_0<=.5 &   Share_for_80>=.5 & Lbeta >0 
tab type_LCP
 tempfile typeLCP
 save `typeLCP'
 restore
 cap drop _m
 merge m:1 group using `typeLCP', force
 * Check consistency
 tab type_LCP type_agg, missing

 
// Looks like type_agg is more lienient
//   tab type_LCP type_LCP_allR, missing // perfect match!
 * Generate estimated contribution in environment LG 
gen globalC_e = Lbeta*TTC_g_lastR/10  + Lconstant
gen localC_e = Lbeta*TTC_l_lastR /10 + Lconstant
foreach v of var globalC_e localC_e {
	replace `v' = 0  if `v'<= 0 
	replace `v' = playerendowment/10 if `v' >= playerendowment/10
	
}
replace globalC_e = 0 if playerjoin_club==0

sum playercontribution_global globalC_e  playercontribution_local localC_e 


tabstat playercontribution_global globalC_e  playercontribution_local localC_e if WithGlobal==1, by(endowment ) stat(mean)
/*
// High and medium endowment global contribution average is similar

endowment |  play~bal  globa~_e  player..  localC_e
----------+----------------------------------------
       10 |  1.880682  2.579017  2.561932  3.719667
       20 |  5.300852  8.029125  1.813636  5.242988
       30 |  5.300568  8.571688  4.935227  7.332419
----------+----------------------------------------
    Total |  4.445739  6.802239  2.781108  5.384516

*/

tabstat playercontribution_global globalC_e  playercontribution_local localC_e if WithGlobal==1, by(type_LCP ) stat(mean)
/*

type_LCP	play~bal	globa~_e	player..	localC_e
				
altruistic	6.070115	8.038104	5.048276	12.92078
reciprocator	5.008696	8.156282	2.73913	4.498165
selfish	1.894737	2.484858	1.214474	2.688666
				
Total	4.445118	6.865841	2.693491	5.175271

*/
tabstat playercontribution_global globalC_e  playercontribution_local localC_e if WithGlobal==0


tabstat playercontribution_global globalC_e  playercontribution_local localC_e if WithGlobal==1, by(type_agg ) stat(mean)

twoway scatter  globalC_e playercontribution_global if WithGlobal==1


  * Explore: join ratio by endowment 
 tabstat  playerjoin_club if WithGlobal==1, by(endowment ) stat(mean sd)
 tabstat  round1_join if WithGlobal==1, by(endowment ) stat(mean sd)


  * Explore: join ratio and total contribution share difference
tabstat  playerjoin_club if WithGlobal==1, by(type_LCP ) stat(mean sd)
tabstat  round1_join if WithGlobal==1, by(type_LCP ) stat(mean sd)

tabstat  share_totalContr if WithGlobal==1, by(type_LCP) stat(mean sd)
tabstat  share_totalContr if WithGlobal==0, by(type_LCP) stat(mean sd)
//selfish people increase by 10%, altruistic people decrease by 12% (first 10)

preserve 
keep if subsessionperiod<=10
tabstat playerpayoff if WithGlobal==1, by(type_LCP) stat(mean sd)
tabstat playerpayoff if WithGlobal==0, by(type_LCP) stat(mean sd)
// payoff wise: seems that the selfish ones benefit the most from the global club environment, even true for first 10

* Now by treatment
tab type_LCP if treatment=="HOMO" 
tab type_LCP if treatment=="HETERO" 

tabstat  playerjoin_club if WithGlobal==1 &  treatment=="HOMO" , by(type_LCP ) stat(mean sd)
tabstat  round1_join if WithGlobal==1 &  treatment=="HOMO" , by(type_LCP ) stat(mean sd)


tabstat  playerjoin_club if WithGlobal==1 &  treatment=="HETERO" , by(type_LCP ) stat(mean sd)
tabstat  round1_join if WithGlobal==1 &  treatment=="HETERO" , by(type_LCP ) stat(mean sd)


// Round 1: selfish people are less likely to join (at least for HOMO); All rounds, shelfish are more likely to join in HETERO; 
tab type_LCP

tab type_LCP if treatment=="HOMO" & fc==20
tab type_LCP if treatment=="HOMO" & fc==80
tab type_LCP if treatment=="HETERO" & fc==20
tab type_LCP if treatment=="HETERO" & fc==80


tabstat  share_totalContr if WithGlobal==1 & treatment=="HOMO" & fc==20, by(type_LCP) stat(mean sd)
tabstat  share_totalContr if WithGlobal==0 & treatment=="HOMO" & fc==20, by(type_LCP) stat(mean sd)


 
su group, meanonly
foreach i of num 1/`r(max)' {
tab 

 
 
 foreach type_v of var typeselfinterestd typealtruismd type11conditionald type12conditionald {
	 sum playerjoin_club if `type_v'==1 & WithGlobal==1
	sum share_totalContr if `type_v'==1 & WithGlobal==1
	sum share_totalContr if `type_v'==1 & WithGlobal==0

 }
tab type_agg

tabstat  playerjoin_club if WithGlobal==1, by(type_agg)
tabstat  share_totalContr if WithGlobal==1, by(type_agg)
tabstat  share_totalContr if WithGlobal==0, by(type_agg)
tabstat  share_totalContr if WithGlobal==1 & treatment=="HOMO", by(type_agg)
tabstat  share_totalContr if WithGlobal==0  & treatment=="HOMO", by(type_agg)
