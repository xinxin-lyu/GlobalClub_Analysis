
global project "C:\Users\xinxi\Purdue\PublicGood_SecondOption4Rich\Experiment\"
* directory "$project\DataAnalysis"
global datafolder "$project\ProcessedData"
global outputfolder "$project\Output"


*************************************************************
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

// FIll in the round 1 data (for the control variable)
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
replace tot_contr = tot_contr
gen tot_contr_o100 = tot_contr/100

label var round_d80 "Round Number /  80"
label var hetero "Hetero"
label var lowFC "Low entry cost"
label var hetero_lowCost "Hetero * Low entry cost"

label var super_game "Match Number"
label var round_whole "Round Number"
label var tot_contr "Own total contribution in round t / 100"
label var local_o "Other's local contribution in round t / 100 "
label var global_o "Other's global contribution in round t / 100 "
label var age_under20 "Age under 20"
label var male "Male"
label var social_x "Disadvantageous inequality aversion"
label var social_y "Advantageous inequality aversion"
label var clubSize "Global club size in round t"
label var share_club_joinH "Club share of the high-endowed in round t"

label var hetero_join "Hetero * Join"
label var playerjoin_club "Join in round t"

;
***************************Regressions *****************************************

***************************Local + Global: Contribution *****************************************


* Prob of joining the club 
local settings "onecol  nonotes   label  dec(2) pdec(3) "

// local treatment_related lowFC hetero hetero_lowCost 
local treatment_related highFC hetero hetero_highCost 
// local treatment_related join_nextRound highFC highFC_j hetero hetero_highCost  hetero_j hetero_highCost_j

//  playerjoin_club hetero_join
local game_contr  super_game round_d80
//hetero_high BeforeLocal * for now, not consider the order effect or more detailed behaviors
//BAB not better
// subsessionperiod : not ideal, super_game flip sign
local indiv_char age_under20 male social_x social_y 
local contr_previous  round1_totCtr tot_contr global_o local_o clubSize share_club_joinH
//clubJoinH

* Dress up some dependent variables
replace tot_contr = tot_contr * 100
label var tot_contr "Own total contribution in round t"


local filename "$outputfolder\05-RegressionAll-RandomEF-Both-contr-abs-rlt-global.xls"

* Random effect regression (2 attempt)
// local treatment_related   highFC highFC_j hetero  hetero_j hetero_highCost   hetero_highCost_j
local treatment_related highFC hetero hetero_highCost 

xi: xtreg totCtr_nextRound `treatment_related'  if  WithGlobal==1  , re
outreg2 using `filename' ,  replace `settings'  ctitle("Total Contribution ")

xi: xtreg  totCtr_nextRound   `treatment_related' `game_contr'  `contr_previous'  `indiv_char'  if  WithGlobal==1  , re
outreg2 using `filename' ,  append `settings'  ctitle("Total Contribution ")



xi: xtreg share_tt_nextRound  `treatment_related'  if  WithGlobal==1   , re
outreg2 using `filename' ,  append `settings'  ctitle("Contribution / Endowment")

xi: xtreg  share_tt_nextRound  `treatment_related' `game_contr' `contr_previous'  `indiv_char' if  WithGlobal==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Contribution / Endowment")


xi: xtreg global_share  `treatment_related'  if  WithGlobal==1   , re
outreg2 using `filename' ,  append `settings'  ctitle("Global Contribution %")

xi: xtreg  global_share  `treatment_related' `game_contr' `contr_previous'  `indiv_char' if  WithGlobal==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Global Contribution %")

;










* Random effect regression (1 attempt)

local treatment_related highFC hetero hetero_highCost 


xi: xtreg round1_totCtr `treatment_related'  if  WithGlobal==1  , re
outreg2 using `filename' ,  replace `settings'  ctitle("Round 1 Contribution ")

xi: xtreg round1_totCtr `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1  , re
outreg2 using `filename' ,  append `settings'  ctitle("Round 1 Contribution ")


// xi: xtreg  totCtr_nextRound `treatment_related' if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  ctitle("Contribution ")


xi: xtreg  totCtr_nextRound `treatment_related' if  WithGlobal==1  , re
outreg2 using `filename' ,  append `settings'  ctitle("Contribution ")

xi: xtreg  totCtr_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1  , re
outreg2 using `filename' ,  append `settings'  ctitle("Contribution ")


xi: xtreg round1_totCtr `treatment_related'  if  WithGlobal==1 & playerjoin_club==1  , re
outreg2 using `filename' ,  append `settings'  ctitle("Round 1 Contribution | join ")


xi: xtreg round1_totCtr `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 & playerjoin_club==1  , re
outreg2 using `filename' ,  append `settings'  ctitle("Round 1 Contribution | join ")

xi: xtreg  totCtr_nextRound `treatment_related'  if  WithGlobal==1 & join_nextRound==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Contribution | join")

xi: xtreg  totCtr_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 & join_nextRound==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Contribution | join")

// xi: xtreg round1_share_tt `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  ctitle("Round 1 Contribution  ")
//
// xi: xtreg  share_tt_nextRound `treatment_related'  if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  ctitle("Contribution Shares ")
//
//
// xi: xtreg  share_tt_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  ctitle("Contribution Shares ")


xi: xtreg round1_globalCtr `treatment_related'  if  WithGlobal==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Round 1 Global Contribution ")

// xi: xtreg  globalContr_nextRound `treatment_related'  if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  ctitle("Global Contribution ")


xi: xtreg  globalContr_nextRound `treatment_related' if  WithGlobal==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Global Contribution ")


xi: xtreg round1_globalCtr `treatment_related' if  WithGlobal==1 & playerjoin_club==1, re
outreg2 using `filename' ,  append `settings'  ctitle("Round 1 Global Contribution | join")

// xi: xtreg  globalContr_nextRound `treatment_related'  if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  ctitle("Global Contribution ")


xi: xtreg  globalContr_nextRound `treatment_related'  if  WithGlobal==1  & join_nextRound ==1, re
outreg2 using `filename' ,  append `settings'  ctitle("Global Contribution | join ")


;
* Random effect regression (2 attempt)
local treatment_related  highFC hetero hetero_highCost highFC_j hetero_j hetero_highCost_j

xi: xtreg round1_totCtr playerjoin_club `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1  , re
outreg2 using `filename' ,  replace `settings'  ctitle("Round 1 Contribution ")

xi: xtreg  totCtr_nextRound  join_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1  , re
outreg2 using `filename' ,  append `settings'  ctitle("Contribution ")


xi: xtreg round1_globalCtr playerjoin_club `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Round 1 Global Contribution ")

xi: xtreg  globalContr_nextRound join_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 , re
outreg2 using `filename' ,  append `settings'  ctitle("Global Contribution ")
;


local filename "$outputfolder\05-RegressionAll-RandomEF-Both-contr-share-conditional-on-join.xls"
* Random effect regression
// xi: xtreg round1_share_tt `treatment_related' if  WithGlobal==1 & lowFC==1, re
// outreg2 using `filename' ,  replace `settings'  
xi: xtreg round1_share_tt `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 & playerjoin_club==1 , re
outreg2 using `filename' ,  replace `settings'  ctitle("Round 1| Join")

// xi: xtreg share_tt_nextRound `treatment_related' `game_contr' `contr_previous' if  WithGlobal==1 & lowFC==1, re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg share_tt_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 & join_nextRound==1 , re
outreg2 using `filename' ,  append `settings'   ctitle("Round t+1| Join")

// xi: xtreg round1_share_tt `treatment_related' if  WithGlobal==1 & lowFC==0, re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg round1_share_tt `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 & playerjoin_club==0 , re
outreg2 using `filename' ,  append `settings'  ctitle("Round 1| Not Join")

// xi: xtreg share_tt_nextRound `treatment_related' `game_contr'  if  WithGlobal==1 & lowFC==0, re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg share_tt_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 & join_nextRound==0 , re
outreg2 using `filename' ,  append `settings'  ctitle("Round t+1| Not Join")
;


*******BAD: contribution shares interact with join behavior, of course join -> higher share of contribution **********
// * Prob of joining the club 
// local settings "onecol  nonotes   label  dec(2) pdec(3) "
//
// local treatment_related  hetero  playerjoin_club hetero_join
// local game_contr  super_game round_d80
// //hetero_high BeforeLocal * for now, not consider the order effect or more detailed behaviors
// //BAB not better
// // subsessionperiod : not ideal, super_game flip sign
// local indiv_char age_under20 male social_x social_y 
// local contr_previous tot_contr global_o local_o clubSize share_club_joinH
// //clubJoinH
//
// * Dress up some dependent variables
// replace tot_contr = tot_contr * 100
// label var tot_contr "Own total contribution in round t"
//
//
//
// local filename "$outputfolder\05-RegressionAll-RandomEF-Both-contr-share.xls"
// * Random effect regression
// // xi: xtreg round1_share_tt `treatment_related' if  WithGlobal==1 & lowFC==1, re
// // outreg2 using `filename' ,  replace `settings'  
// xi: xtreg round1_share_tt `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 & lowFC==1 , re
// outreg2 using `filename' ,  replace `settings'  
//
// // xi: xtreg share_tt_nextRound `treatment_related' `game_contr' `contr_previous' if  WithGlobal==1 & lowFC==1, re
// // outreg2 using `filename' ,  append `settings'  
// xi: xtreg share_tt_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 & lowFC==1 , re
// outreg2 using `filename' ,  append `settings'  
//
// // xi: xtreg round1_share_tt `treatment_related' if  WithGlobal==1 & lowFC==0, re
// // outreg2 using `filename' ,  append `settings'  
// xi: xtreg round1_share_tt `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 & lowFC==0 , re
// outreg2 using `filename' ,  append `settings'  
//
// // xi: xtreg share_tt_nextRound `treatment_related' `game_contr'  if  WithGlobal==1 & lowFC==0, re
// // outreg2 using `filename' ,  append `settings'  
// xi: xtreg share_tt_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 & lowFC==0 , re
// outreg2 using `filename' ,  append `settings'  
*******end of BAD: contribution shares interact with join behavior, of course join -> higher share of contribution **********


***************************end of Local + Global: Join *****************************************


***************************Local + Global: Join (adding type, by high/low) *****************************************

* Prob of joining the club 
local settings "onecol  nonotes   label  dec(2) pdec(3) "

local endowment_diff hetero_high hetero_low


local game_contr  super_game round_d80
//hetero_high BeforeLocal * for now, not consider the order effect or more detailed behaviors
//BAB not better
// subsessionperiod : not ideal, super_game flip sign
local indiv_char age_under20 male social_x social_y type*
local contr_previous round1_join tot_contr_o100 global_o local_o clubSize share_club_joinH
//clubJoinH

local filename "$outputfolder\05-RegressionAll-RandomEF-Join-ByCost.xls"
* Random effect regression
**** Low Cost
xi: xtreg round1_join `endowment_diff' if  WithGlobal==1 & subsessionperiod==1 &  lowFC==1, re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  
xi: xtreg round1_join `endowment_diff' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 & lowFC==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

// social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
xi: xtreg join_nextRound `endowment_diff'  if  WithGlobal==1 &  lowFC==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: xtreg join_nextRound `endowment_diff' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 &  lowFC==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  


xi: xtreg round1_join `endowment_diff' if  WithGlobal==1 & subsessionperiod==1 &  lowFC==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: xtreg round1_join `endowment_diff' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 & lowFC==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

// social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
xi: xtreg join_nextRound `endowment_diff'  if  WithGlobal==1 &  lowFC==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: xtreg join_nextRound `endowment_diff' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 &  lowFC==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  


* Probit returns quite different results. Not sure which should be reported
local settings "onecol  nonotes   label  dec(2) pdec(3) "

local endowment_diff hetero_high hetero_low


local game_contr  super_game round_d80
//hetero_high BeforeLocal * for now, not consider the order effect or more detailed behaviors
//BAB not better
// subsessionperiod : not ideal, super_game flip sign
local indiv_char age_under20 male social_x social_y type*
local contr_previous round1_join tot_contr_o100 global_o local_o clubSize share_club_joinH


br round1_join `endowment_diff' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 & lowFC==1

local filename "$outputfolder\05-RegressionAll-Probit-Join-ByCost.xls"
* Random effect regression
**** Low Cost
xi: prob round1_join `endowment_diff' if  WithGlobal==1 & subsessionperiod==1 &  lowFC==1, cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  
xi: prob round1_join `endowment_diff' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 & lowFC==1,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

// social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
xi: prob join_nextRound `endowment_diff'  if  WithGlobal==1 &  lowFC==1,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: prob join_nextRound `endowment_diff' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 &  lowFC==1,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  


xi: prob round1_join `endowment_diff' if  WithGlobal==1 & subsessionperiod==1 &  lowFC==0,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: prob round1_join `endowment_diff' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 & lowFC==0, cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

// social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
xi: prob join_nextRound `endowment_diff'  if  WithGlobal==1 &  lowFC==0,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: prob join_nextRound `endowment_diff' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1 &  lowFC==0,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  





// local filename "$outputfolder\05-RegressionAll-Prob.xls"
//
// * Prob regression
// xi: prob round1_join `treatment_related' if  WithGlobal==1, cluster(subject_id)
// outreg2 using `filename' ,  replace `settings'  
// xi: prob round1_join `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1, cluster(subject_id)
// outreg2 using `filename' ,  append `settings'  
// //In round 1, only fixed cost seems to increase the prob of joining the club 
//
//
// // social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
// xi: prob join_nextRound `treatment_related' `game_contr' `contr_previous' if  WithGlobal==1 , cluster(subject_id)
// outreg2 using `filename' ,  append `settings'  
// xi: prob join_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1, cluster(subject_id)
// outreg2 using `filename' ,  append `settings'  
//
// ;

***************************end of Local + Global: Join (adding type, by high/low) *****************************************


***************************Local + Global: Join *****************************************

* Prob of joining the club 
local settings "onecol  nonotes   label  dec(2) pdec(3) "

// local treatment_related lowFC hetero hetero_lowCost 
local treatment_related highFC hetero hetero_highCost 


local game_contr  super_game round_d80
//hetero_high BeforeLocal * for now, not consider the order effect or more detailed behaviors
//BAB not better
// subsessionperiod : not ideal, super_game flip sign
local indiv_char age_under20 male social_x social_y 
local contr_previous round1_join tot_contr_o100 global_o local_o clubSize share_club_joinH
//clubJoinH

local filename "$outputfolder\05-RegressionAll-RandomEF-Both-Join.xls"
* Random effect regression
xi: xtreg round1_join `treatment_related' if  WithGlobal==1 & subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  
xi: xtreg round1_join `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
//In round 1, only fixed cost seems to increase the prob of joining the club 

// xi: xtreg playerjoin_club `treatment_related'  if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  
// xi: xtreg playerjoin_club `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1, re 
// outreg2 using `filename' ,  append `settings'  

// social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
xi: xtreg join_nextRound `treatment_related'  if  WithGlobal==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: xtreg join_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

// local treatment_related i.highFC*i.endowment
//
// xi: xtreg join_nextRound `treatment_related'  if  WithGlobal==1 , re
// outreg2 using `filename' ,  append `settings'  
// xi: xtreg join_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1, re
// outreg2 using `filename' ,  append `settings'  
;

* Probit returns quite different results. Not sure which should be reported
// local filename "$outputfolder\05-RegressionAll-Prob.xls"
//
// * Prob regression
// xi: prob round1_join `treatment_related' if  WithGlobal==1, cluster(subject_id)
// outreg2 using `filename' ,  replace `settings'  
// xi: prob round1_join `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1, cluster(subject_id)
// outreg2 using `filename' ,  append `settings'  
// //In round 1, only fixed cost seems to increase the prob of joining the club 
//
//
// // social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
// xi: prob join_nextRound `treatment_related' `game_contr' `contr_previous' if  WithGlobal==1 , cluster(subject_id)
// outreg2 using `filename' ,  append `settings'  
// xi: prob join_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1, cluster(subject_id)
// outreg2 using `filename' ,  append `settings'  
//
// ;

***************************end of Local + Global: Join *****************************************





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
local treatment_related  hetero super_game round_within
// hetero_high BeforeLocal
// subsessionperiod : not ideal, super_game flip sign 
local indiv_char age_under20 male social_x social_y 
// local size clubSize_nextRound clubJoinH_nextRound 
local contr_previous tot_contr local_o

* Without global club
local filename "$outputfolder\05-RegressionAll-RandomEF-local-contr-abs.xls"
* Random effect regression
xi: xtreg round1_localCtr `treatment_related' if  WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle(Local Contribution in Round 1)
// xi: xtreg round1_localCtr `treatment_related' `size' if WithGlobal==0, re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg round1_localCtr `treatment_related' `indiv_char' `size' if WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle(Local Contribution in Round 1)

xi: xtreg localContr_nextRound `treatment_related'  if WithGlobal==0 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle(Local Contribution in Round t+1)
// xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `size' if WithGlobal==0 , re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `indiv_char' `size' if WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle(Local Contribution in Round t+1)

local filename "$outputfolder\05-RegressionAll-RandomEF-local-contr-share.xls"
xi: xtreg round1_share_tt `treatment_related' if  WithGlobal==0, re  cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle(Contribution Share in Round 1)
// xi: xtreg round1_localCtr `treatment_related' `size' if WithGlobal==0, re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg round1_share_tt `treatment_related' `indiv_char' `size' if WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle(Contribution Share in Round 1)

xi: xtreg share_tt_nextRound `treatment_related'  if WithGlobal==0 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle(Contribution Share in Round t+1)
// xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `size' if WithGlobal==0 , re
// outreg2 using `filename' ,  append `settings'  
xi: xtreg share_tt_nextRound  `treatment_related' `contr_previous' `indiv_char' `size' if WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle(Contribution Share in Round t+1)

***************************end of Local Only: Contribution *****************************************

















