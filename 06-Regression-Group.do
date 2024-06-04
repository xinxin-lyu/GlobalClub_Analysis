
global project "C:\Users\xinxi\Purdue\PublicGood_SecondOption4Rich\Experiment\"
* directory "$project\DataAnalysis"
global datafolder "$project\ProcessedData"
global outputfolder "$project\Output"


*************************************************************
import delimited "$datafolder\data_Oppor_allB.csv", clear
gen WithGlobal = 1
tempfile allB
save `allB', replace 

import delimited "$datafolder\data_noOppor_AllA.csv", clear
gen WithGlobal = 0
append using `allB'

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


// // encode some string variables 
// encode age, gen(age_g)
// gen male=gender=="Male"
// // replace male = . if gender=="Prefer Not to Say" // 2 subjects prefer not to say
// gen age_under20  = age=="Under 20"


// ? do I want to control others' contribution? 
gen share_contr = tot_contr * 10 / playerendowment
// generate others' contribution 
gen global_o = grouptotal_contribution_global - playercontribution_global
gen local_o = playertotal_contribution_local - playercontribution_local


bys sessioncode round_whole groupid_in_subsession: gen clubSize = sum(playerjoin_club)
gen join_HighE = playerjoin_club * (endowment==30)
bys sessioncode round_whole groupid_in_subsession: gen clubJoinH = sum(join_HighE)
gen share_club_joinH = clubJoinH / clubSize
replace share_club_joinH = 0  if clubSize==0





gen hetero_join = hetero * playerjoin_club
// Additional control variables
xtset subject_id round_whole

 
// round 1 join decision vs next round join decision 
gen round1_join = playerjoin_club if subsessionperiod==1
bys subject_id: gen join_nextRound = f.playerjoin_club
replace join_nextRound = round1_join if subsessionperiod==1
//hard coding, relevant to the random number realization: B1 = [6,18,17]; B2 = [8]
replace join_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 

gen round1_globalCtr = playercontribution_global if subsessionperiod==1
bys subject_id: gen globalContr_nextRound = f.playercontribution_global
replace globalContr_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 

gen round1_localCtr = playercontribution_local if subsessionperiod==1
bys subject_id: gen localContr_nextRound = f.playercontribution_local
replace localContr_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 


gen round1_totCtr = tot_contr if subsessionperiod==1
bys subject_id: gen totCtr_nextRound = f.tot_contr
replace totCtr_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
replace totCtr_nextRound = tot_contr if subsessionperiod==1

bys subject_id: gen clubSize_nextRound = f.clubSize
replace clubSize_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
// for round 1, use the same variable (WHY?)
// replace clubSize_nextRound = clubSize if subsessionround_number==1

bys subject_id: gen clubJoinH_nextRound = f.clubJoinH
replace clubJoinH_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
// for round 1, use the same variable
// replace clubJoinH_nextRound = clubJoinH if subsessionround_number==1


gen round1_share_tt = share_contr*100 if subsessionperiod==1
bys subject_id: gen share_tt_nextRound = f.share_contr*100
replace share_tt_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
replace share_tt_nextRound = round1_share_tt if subsessionperiod==1
// for round 1, use the same variable
// replace share_tt_nextRound = share_contr if subsessionround_number==1

// FIll in the round 1 data
bys subject_id super_game : replace round1_join = round1_join[_n-1] if round1_join==. & _n >1
bys subject_id super_game : replace round1_globalCtr = round1_globalCtr[_n-1] if round1_globalCtr==. & _n >1
bys subject_id super_game : replace round1_localCtr = round1_localCtr[_n-1] if round1_localCtr==. & _n >1
bys subject_id super_game : replace round1_totCtr = round1_totCtr[_n-1] if round1_totCtr==. & _n >1


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
replace tot_contr = tot_contr/100

label var round_d80 "Round Number /  80"
label var hetero "Hetero"
label var lowFC "Low entry cost"
label var hetero_lowCost "Hetero * Low entry cost"

label var super_game "Match Number"
label var round_whole "Round Number"
label var tot_contr "Own total contribution in round t / 100"
label var local_o "Other's local contribution in round t / 100 "
label var global_o "Other's global contribution in round t / 100 "
// label var age_under20 "Age under 20"
// label var male "Male"
// label var social_x "Disadvantageous inequality aversion"
// label var social_y "Advantageous inequality aversion"
label var clubSize "Global club size in round t"
label var share_club_joinH "Club share of the high-endowed in round t"

label var hetero_join "Hetero * Join"
label var playerjoin_club "Join in round t"



keep sessioncode subsessionround_number subsessionperiod subsessionsg playerlocal_community groupid_in_subsession fc treatment highFC hetero hetero_highCost  WithGlobal super_game efficiency efficiency2 socialbenefitmax playerpayoff_globalmax  super_game round_d80 round_whole  hetero hetero_with lowFC With_High_Cost
duplicates drop 

egen local_community_id = group(playerlocal_community sessioncode )

xtset local_community_id round_whole

gen efficiency_stage1 = efficiency / efficiency2

***************************Regressions********************** *****************************************

**************************************
************Efficiency ***********
*****************************************
preserve
keep if subsessionperiod<=10
local filename "$outputfolder\06-Regression-Group-Efficiency(first10).xls"

// local filename "$outputfolder\06-Regression-Group-Efficiency.xls"

local settings "onecol  nonotes   label  dec(2) pdec(3) "

local treatment_related highFC hetero hetero_highCost 

// local indep WithGlobal  hetero hetero_with //with * hetero_high
local indep WithGlobal  highFC With_High_Cost //with * highFC


local game_contr  super_game round_d80


xi: xtreg efficiency `indep' `game_contr' if hetero==1, fe  cluster(sessioncode)
estimates store fixed
xi: xtreg efficiency `indep' `game_contr' if hetero==1, re  cluster(sessioncode)
hausman fixed ., force sigmamore



xi: xtreg efficiency `indep' `game_contr' if hetero==1, re  cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'   ctitle(" efficiency HETERO")


xi: xtreg efficiency `indep' `game_contr' if hetero==0, re  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'   ctitle(" efficiency HOMO")


keep efficiency_stage1 efficiency2 `treatment_related' `game_contr' groupid_in_subsession sessioncode round_whole
duplicates drop 
egen group_id_session = group(groupid_in_subsession sessioncode )

xtset group_id_session round_whole

xi: xtreg efficiency_stage1 `treatment_related' `game_contr' , re  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'   ctitle("stage1 efficiency ")

xi: xtreg efficiency2 `treatment_related' `game_contr' , re  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'   ctitle("stage 2 efficiency ")


;




***************************Both : DID *****************************************

replace tot_contr = tot_contr *100
label var tot_contr "Own total contribution"
replace share_contr = share_contr * 100

* Considered high vs low endowment

gen High_cost = lowFC==0



*******************************************************************************
* Considered high vs low entry cost 

local indep WithGlobal  hetero hetero_with //interaction_term
// local indep2 WithGlobal_join hetero_with_join 

// local indep WithGlobal hetero hetero_high hetero_with hetero_high_with

local  game_contr2 i.super_game*i.subsessionperiod
local game_contr  super_game round_d80
// subsessionperiod : not ideal, super_game flip sign
local indiv_char age_under20 male social_x social_y 
local contr_previous tot_contr global_o local_o clubSize share_club_joinH

* Regression for global contribution 
* Separate all, high, low entry cost
local filename "$outputfolder\05-RegressionAll-RandomEF-DID.xls"
local settings "onecol  nonotes   label  dec(2) pdec(3) "
* Random effect regression
// start with all 

local contr  `game_contr' `indiv_char'

// lowFC
xi: xtreg tot_contr `indep' `contr' if lowFC==1, re
outreg2 using `filename' ,  replace `settings'   ctitle(" tot_contr Low cost")
// xi: xtreg tot_contr `indep'  `indep2' `contr' if lowFC==1, re
// outreg2 using `filename' ,  append `settings'  keep(`indep' `indep2') ctitle(" tot_contr Low cost")
xi: xtreg share_contr `indep' `contr' if lowFC==1, re
outreg2 using `filename' ,  append `settings'   ctitle("share_contr Low cost")
// xi: xtreg share_contr `indep' `indep2' `contr' if lowFC==1, re
// outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("share_contr Low cost")
xi: xtreg playerpayoff `indep' `contr' if lowFC==1 , re
outreg2 using `filename' ,  append `settings'   ctitle("payoff Low cost")
// xi: xtreg playerpayoff `indep' `indep2' `contr' if lowFC==1 , re
// outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("payoff Low cost")


// highFC
xi: xtreg tot_contr `indep' `contr' if lowFC==0, re
outreg2 using `filename' ,  append `settings'  ctitle("tot_contr High cost")
// xi: xtreg tot_contr `indep' `indep2' `contr' if lowFC==0, re
// outreg2 using `filename' ,  append `settings'  keep(`indep' `indep2') ctitle("tot_contr High cost")
xi: xtreg share_contr `indep' `contr' if lowFC==0, re
outreg2 using `filename' ,  append `settings'   ctitle("share_contr High cost")
// xi: xtreg share_contr `indep' `indep2' `contr' if lowFC==0, re
// outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("share_contr High cost")
xi: xtreg playerpayoff `indep' `contr' if lowFC==0, re
outreg2 using `filename' ,  append `settings'  ctitle("payoff High cost")
// xi: xtreg playerpayoff `indep' `indep2'  `contr' if lowFC==0, re
// outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("payoff High cost")


;



local indep WithGlobal    With_High_Cost    //interaction_term: High_cost lowFC WithGlobal_join   With_High_Cost_Join
local indep2    With_High_Cost_Join // WithGlobal_join
// local indep2 WithGlobal_join hetero_with_join 

// local indep WithGlobal hetero hetero_high hetero_with hetero_high_with

local  game_contr2 i.super_game*i.subsessionperiod
local game_contr  super_game round_d80
// subsessionperiod : not ideal, super_game flip sign
local indiv_char age_under20 male social_x social_y 
local contr_previous tot_contr global_o local_o clubSize share_club_joinH

* Regression for global contribution 
* Separate all, high, low entry cost
local filename "$outputfolder\05-RegressionAll-RandomEF-DID-payoff.xls"
local settings "onecol  nonotes   label  dec(2) pdec(3) "
* Random effect regression
// start with all 

local contr   `game_contr' `indiv_char'
// // High
// xi: xtreg tot_contr `indep' `contr' if  endowment==30, re
// outreg2 using `filename' ,  replace `settings'   ctitle(" tot_contr High")
// // xi: xtreg tot_contr `indep'  `indep2' `contr' if lowFC==1, re
// // outreg2 using `filename' ,  append `settings'  keep(`indep' `indep2') ctitle(" tot_contr Low cost")
// xi: xtreg share_contr `indep' `contr' if endowment==30, re
// outreg2 using `filename' ,  append `settings'   ctitle("share_contr High")
// // xi: xtreg share_contr `indep' `indep2' `contr' if lowFC==1, re
// // outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("share_contr Low cost")
// xi: xtreg playerpayoff `indep' `contr' if endowment==30 , re
// outreg2 using `filename' ,  append `settings'   ctitle("payoff High")
// // xi: xtreg playerpayoff `indep' `indep2' `contr' if lowFC==1 , re
// // outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("payoff Low cost")
//
//
// // Low
// xi: xtreg tot_contr `indep' `contr' if  endowment==10, re
// outreg2 using `filename' ,  append `settings'   ctitle(" tot_contr Low")
// // xi: xtreg tot_contr `indep'  `indep2' `contr' if lowFC==1, re
// // outreg2 using `filename' ,  append `settings'  keep(`indep' `indep2') ctitle(" tot_contr Low cost")
// xi: xtreg share_contr `indep' `contr' if endowment==10, re
// outreg2 using `filename' ,  append `settings'   ctitle("share_contr Low")
// // xi: xtreg share_contr `indep' `indep2' `contr' if lowFC==1, re
// // outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("share_contr Low cost")
// xi: xtreg playerpayoff `indep' `contr' if endowment==10 , re
// outreg2 using `filename' ,  append `settings'   ctitle("payoff Low")
// // xi: xtreg playerpayoff `indep' `indep2' `contr' if lowFC==1 , re
// // outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("payoff Low cost")
//
// Hetero
// xi: xtreg tot_contr `indep' `contr' if  endowment!=20, re
// outreg2 using `filename' ,  replace `settings'   ctitle(" tot_contr Hetero")
//
// xi: xtreg share_contr `indep' `contr' if endowment!=20, re
// outreg2 using `filename' ,  append `settings'   ctitle("share_contr Hetero")

// xi: xtreg playerpayoff `indep' `contr' if endowment!=20 , re
// outreg2 using `filename' ,  replace `settings'   ctitle("payoff Hetero")
//
// xi: xtreg playerpayoff `indep' `indep2' `contr' if endowment!=20 , re
// outreg2 using `filename' ,  append `settings'   ctitle("payoff Hetero | Join")

//
xi: xtreg playerpayoff `indep' `contr' if endowment==30 , re
outreg2 using `filename' ,  replace `settings'   ctitle("payoff Hetero (H)")

xi: xtreg playerpayoff `indep' `indep2' `contr' if endowment==30 , re
outreg2 using `filename' ,  append `settings'   ctitle("payoff Hetero (H)")

xi: xtreg playerpayoff `indep' `contr' if endowment==10 , re
outreg2 using `filename' ,  append `settings'   ctitle("payoff Hetero (L)")

xi: xtreg playerpayoff `indep' `indep2' `contr' if endowment==10 , re
outreg2 using `filename' ,  append `settings'   ctitle("payoff Hetero (L)")

// HOMO
// xi: xtreg tot_contr `indep' `contr' if  endowment==20, re
// outreg2 using `filename' ,  append `settings'   ctitle(" tot_contr Homo")
// // xi: xtreg tot_contr `indep'  `indep2' `contr' if lowFC==1, re
// // outreg2 using `filename' ,  append `settings'  keep(`indep' `indep2') ctitle(" tot_contr Low cost")
// xi: xtreg share_contr `indep' `contr' if endowment==20, re
// outreg2 using `filename' ,  append `settings'   ctitle("share_contr Homo")
// // xi: xtreg share_contr `indep' `indep2' `contr' if lowFC==1, re
// // outreg2 using `filename' ,  append `settings'   keep(`indep' `indep2') ctitle("share_contr Low cost")
xi: xtreg playerpayoff `indep' `contr' if endowment==20 , re
outreg2 using `filename' ,  append `settings'   ctitle("payoff Homo")
xi: xtreg playerpayoff `indep'  `indep2' `contr' if endowment==20 , re
outreg2 using `filename' ,  append `settings'  ctitle("payoff Homo | Join")


;




***************************end of Both : DID *****************************************









***************************Local Only: Contribution *****************************************
* Prob of joining the club in the first round/next round
local settings "onecol  nonotes   label  dec(2) pdec(3) "

* Regression for local contribution 
local treatment_related  hetero super_game round_d80
// hetero_high BeforeLocal
// subsessionperiod : not ideal, super_game flip sign 
local indiv_char age_under20 male social_x social_y 
// local size clubSize_nextRound clubJoinH_nextRound 
local contr_previous tot_contr local_o

* Without global club
local filename "$outputfolder\05-RegressionAll-RandomEF-local-contr-abs.xls"
* Random effect regression
xi: xtreg round1_localCtr `treatment_related' if  WithGlobal==0, re
outreg2 using `filename' ,  replace `settings'  ctitle(Local Contribution in Round 1)
// xi: xtreg round1_localCtr `treatment_related' `size' if WithGlobal==0, re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg round1_localCtr `treatment_related' `indiv_char' `size' if WithGlobal==0, re
outreg2 using `filename' ,  append `settings'  ctitle(Local Contribution in Round 1)

xi: xtreg localContr_nextRound `treatment_related'  if WithGlobal==0 , re
outreg2 using `filename' ,  append `settings'  ctitle(Local Contribution in Round t+1)
// xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `size' if WithGlobal==0 , re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `indiv_char' `size' if WithGlobal==0, re
outreg2 using `filename' ,  append `settings'  ctitle(Local Contribution in Round t+1)

local filename "$outputfolder\05-RegressionAll-RandomEF-local-contr-share.xls"
xi: xtreg round1_share_tt `treatment_related' if  WithGlobal==0, re
outreg2 using `filename' ,  replace `settings'  ctitle(Contribution Share in Round 1)
// xi: xtreg round1_localCtr `treatment_related' `size' if WithGlobal==0, re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg round1_share_tt `treatment_related' `indiv_char' `size' if WithGlobal==0, re
outreg2 using `filename' ,  append `settings'  ctitle(Contribution Share in Round 1)

xi: xtreg share_tt_nextRound `treatment_related'  if WithGlobal==0 , re
outreg2 using `filename' ,  append `settings'  ctitle(Contribution Share in Round t+1)
// xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `size' if WithGlobal==0 , re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg share_tt_nextRound  `treatment_related' `contr_previous' `indiv_char' `size' if WithGlobal==0, re
outreg2 using `filename' ,  append `settings'  ctitle(Contribution Share in Round t+1)

***************************end of Local Only: Contribution *****************************************

















