
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
bys subject_id super_game : replace round1_totCtr_share = round1_totCtr_share[_n-1] if round1_totCtr_share==. & _n >1


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

label var round_d80 "Round Number /  80"
label var hetero "Hetero"
label var lowFC "Low entry cost"
label var hetero_lowCost "Hetero * Low entry cost"

label var super_game "Match number"
label var round_whole "Round number"
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
label var join_HighE  "Join * High endowment "
label var join_LowE  "Join * Low endowment "
label var clubSize_join "Club size upon joining"

label var subsessionperiod "Round number"

label var club_OtherCommunityMembers "Number of other community's members in the club"
label var club_LocalMembersNotMe "Number of local members in the club"
label var dummy_payoff "Dummy of benefit from club exceeding the entry cost"
label var round_o10 "Round number / 10"



gen L_Environment = strpos(sequence,"A")


;	
tab sequence if L_Environment==1
hist tot_contr if L_Environment==1, discrete saving(L,replace) ylabel(0(.1).3) title("L") 
hist tot_contr if L_Environment==0, discrete saving(LG,replace)  ylabel(0(.1).3) title("LG")
gr combine L.gph LG.gph

//# L vs LG
hist share_totalContr if L_Environment==1, fraction discrete saving(L,replace) ylabel(0(.1).3) title("L") 
hist share_totalContr if L_Environment==0, fraction discrete saving(LG,replace)  ylabel(0(.1).3) title("LG")
gr combine L.gph LG.gph

// # LowC HOMO
hist share_totalContr if L_Environment==1 & lowFC==1 &  hetero==0, fraction discrete saving(L,replace) ylabel(0(.1).3) title("L") 
hist share_totalContr if L_Environment==0 & lowFC==1 &  hetero==0, fraction discrete saving(LG,replace)  ylabel(0(.1).3) title("LG")
gr combine L.gph LG.gph


// # LowC HETERO
hist share_totalContr if L_Environment==1 & lowFC==1 &  hetero==1,fraction discrete saving(L,replace) ylabel(0(.1).3) title("L") 
hist share_totalContr if L_Environment==0 & lowFC==1 &  hetero==1, fraction discrete saving(LG,replace)  ylabel(0(.1).3) title("LG")
gr combine L.gph LG.gph

// # HighC HOMO
hist share_totalContr if L_Environment==1 & lowFC==0 &  hetero==0, fraction discrete saving(L,replace) ylabel(0(.1).5) title("L") 
hist share_totalContr if L_Environment==0 & lowFC==0 &  hetero==0, fraction discrete saving(LG,replace)  ylabel(0(.1).5) title("LG")
gr combine L.gph LG.gph


// # HighC HETERO
hist share_totalContr if L_Environment==1 & lowFC==0 &  hetero==1,fraction discrete saving(L,replace) ylabel(0(.1).5) title("L") 
hist share_totalContr if L_Environment==0 & lowFC==0 &  hetero==1, fraction discrete saving(LG,replace)  ylabel(0(.1).5) title("LG")
gr combine L.gph LG.gph

//Only LG, global contribution 
hist playercontribution_global if playerjoin_club==1 & lowFC==1 &  hetero==0, fraction discrete saving(LHomo,replace) ylabel(0(.1).3) title("LowC HOMO ") 
hist playercontribution_global if playerjoin_club==1 & lowFC==0 &  hetero==0, fraction discrete saving(HHomo,replace)  ylabel(0(.1).3) title("HighC HOMO")
hist playercontribution_global if playerjoin_club==1 & lowFC==1 &  hetero==1, fraction discrete saving(LHetero,replace) ylabel(0(.1).3) title("LowC Hetero ") 
hist playercontribution_global if playerjoin_club==1 & lowFC==0 &  hetero==1, fraction discrete saving(HHetero,replace)  ylabel(0(.1).3) title("HighC Hetero")

gr combine LHomo.gph HHomo.gph LHetero.gph HHetero.gph


***************************Regressions *****************************************

***************************Local + Global: Contribution %  *****************************************
************** Independent variable: Join 
************** Purpose: DID, does joining club increase contribution % for everyone? How robust it is?
local settings "onecol  nonotes   label  dec(2) pdec(3) "


local independentVar playerjoin_club

local independentVar_interact join_HighE join_LowE

local game_contr  super_game subsessionperiod
local groupControls  clubSize clubSize_join `game_contr'
local indiv_char age_under20 male major_SorE social_x social_y 

local filename "$outputfolder\05-RegressionAll-v2-Join-to-Contr-Shares.xls"



xi: xtreg share_totalContr `independentVar'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")



preserve 
keep if subsessionperiod<=10
local settings "onecol  nonotes   label  dec(2) pdec(3) "


local independentVar playerjoin_club

local independentVar_interact join_HighE join_LowE

local game_contr  super_game subsessionperiod
local groupControls  clubSize clubSize_join `game_contr'
local indiv_char age_under20 male major_SorE social_x social_y 

local filename "$outputfolder\05-RegressionAll-v2-Join-to-Contr-Shares-R(first10).xls"



xi: xtreg share_totalContr `independentVar'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg share_totalContr `independentVar'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg share_totalContr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")
restore 

;


***************************Local + Global: Contribution % *****************************************


***************************Local + Global: Contribution *****************************************
************** Independent variable: Join 
************** Purpose: DID, does joining club increase contribution % for everyone? How robust it is?
local settings "onecol  nonotes   label  dec(2) pdec(3) "


local independentVar playerjoin_club

local independentVar_interact join_HighE join_LowE

local game_contr  endowment_adj super_game subsessionperiod
local groupControls  clubSize clubSize_join `game_contr'
local indiv_char age_under20 male major_SorE social_x social_y 

local filename "$outputfolder\05-RegressionAll-v2-Join-to-Contr.xls"



xi: xtreg  tot_contr `independentVar'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")



preserve 
keep if subsessionperiod<=10
local independentVar playerjoin_club

local independentVar_interact join_HighE join_LowE

local game_contr  endowment_adj super_game subsessionperiod
local groupControls  clubSize clubSize_join `game_contr'
local indiv_char age_under20 male major_SorE social_x social_y 

local filename "$outputfolder\05-RegressionAll-v2-Join-to-Contr-R(first10).xls"



xi: xtreg  tot_contr `independentVar'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg  tot_contr `independentVar'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg  tot_contr `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

restore


***************************Local + Global: Contribution % *****************************************







***************************Local + Global: Payoff  *****************************************
************** Independent variable: Join 
************** Purpose: DID, does joining club increase payoff for everyone? How robust it is?

local settings "onecol  nonotes   label  dec(2) pdec(3) "

local independentVar playerjoin_club

local independentVar_interact join_HighE join_LowE

local game_contr  super_game round_o10 endowment_adj
local groupControls  clubSize clubSize_join `game_contr'
local indiv_char age_under20 male major_SorE social_x social_y 

local filename "$outputfolder\05-RegressionAll-v2-Join-to-Payoff.xls"

xi: xtreg playerpayoff `independentVar'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")


preserve 

keep if subsessionperiod<=10

local settings "onecol  nonotes   label  dec(2) pdec(3) "

local independentVar playerjoin_club

local independentVar_interact join_HighE join_LowE

local game_contr  super_game subsessionperiod
local groupControls  clubSize clubSize_join `game_contr'
local indiv_char age_under20 male major_SorE social_x social_y 

local filename "$outputfolder\05-RegressionAll-v2-Join-to-Payoff-R(first10).xls"



xi: xtreg playerpayoff `independentVar'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls'  if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==1  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Low Cost")

xi: xtreg playerpayoff `independentVar'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls'  if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")

xi: xtreg playerpayoff `independentVar' `independentVar_interact' `groupControls' `indiv_char' if  lowFC==0  , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("High Cost")
restore

;


***************************Local + Global: Payoff *****************************************


***************************Global Only: Join behavior  *****************************************
************** Independent variable: HighC  Hetero
************** R1, AllR
* Prob of joining the club 
local settings "onecol  nonotes   label  dec(3) pdec(3) "

local independentVar highFC hetero
local independentVar2 highFC hetero hetero_highCost

*IF by costs: 
local endowment_diff hetero_high hetero_low


local game_contr  super_game round_o10
local indiv_char age_under20 male major_SorE social_x social_y 
// type*
local factors  club_LocalMembersNotMe club_OtherCommunityMembers dummy_payoff

local contr_previous round1_join tot_contr_o100 global_o local_o  share_club_joinH `factors'
//clubJoinH clubSize


local filename "$outputfolder\05-RegressionAll-v2-RandomEF-Join-Main.xls"
* Random effect regression
xi: xtreg round1_join `independentVar2' if  WithGlobal==1 & subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  

xi: xtreg round1_join `independentVar2' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

xi: xtreg join_nextRound `independentVar2'  if  WithGlobal==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

xi: xtreg join_nextRound `independentVar2' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  


***** Probit returns quite different results. Not sure which should be reported

local filename "$outputfolder\05-RegressionAll-v2-Probit-Join-Main.xls"
* Random effect regression
// xi: prob round1_join `independentVar' if  WithGlobal==1 & subsessionperiod==1 , cluster(sessioncode)
// outreg2 using `filename' ,  replace `settings'  
xi: prob round1_join `independentVar2' if  WithGlobal==1 & subsessionperiod==1 , cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  

xi: prob round1_join `independentVar2' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 ,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

// xi: prob join_nextRound `independentVar'  if  WithGlobal==1,  cluster(sessioncode)
// outreg2 using `filename' ,  append `settings'  
xi: prob join_nextRound `independentVar2'  if  WithGlobal==1,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

xi: prob join_nextRound `independentVar2' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

preserve
keep if subsessionperiod<=10

local settings "onecol  nonotes   label  dec(3) pdec(3) "

local independentVar highFC hetero
local independentVar2 highFC hetero hetero_highCost

*IF by costs: 
local endowment_diff hetero_high hetero_low


local game_contr  super_game round_o10
local indiv_char age_under20 male major_SorE social_x social_y 
// type*
local factors  club_LocalMembersNotMe club_OtherCommunityMembers dummy_payoff

local contr_previous round1_join tot_contr_o100 global_o local_o  share_club_joinH `factors'
//clubJoinH clubSize


local filename "$outputfolder\05-RegressionAll-v2-RandomEF-Join-Main-R(first10).xls"
* Random effect regression
**** Low Cost
xi: xtreg round1_join `independentVar2' if  WithGlobal==1 & subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  
xi: xtreg round1_join `independentVar2' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

xi: xtreg join_nextRound `independentVar2'  if  WithGlobal==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

xi: xtreg join_nextRound `independentVar2' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  


***** Probit returns quite different results. Not sure which should be reported

local filename "$outputfolder\05-RegressionAll-v2-Probit-Join-Main-R(first10).xls"
* Random effect regression
**** Low Cost
xi: prob round1_join `independentVar2' if  WithGlobal==1 & subsessionperiod==1 , cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  
 

xi: prob round1_join `independentVar2' `game_contr' `indiv_char' if  WithGlobal==1 & subsessionperiod==1 ,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

xi: prob join_nextRound `independentVar2'  if  WithGlobal==1,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  
xi: prob join_nextRound `independentVar2' `game_contr' `contr_previous' `indiv_char' if  WithGlobal==1,  cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  

************** Independent variable (by cost): Hetero_high and Hetero_low both reduces the prob of joining, high more likely to quit than low (probit) 	

* Prob of joining the club 
local settings "onecol  nonotes   label  dec(3) pdec(3) "

local independentVar highFC hetero
local independentVar2 highFC hetero hetero_highCost

*IF by costs: 
local endowment_diff hetero_high hetero_low


local game_contr  super_game round_o10
local indiv_char age_under20 male major_SorE social_x social_y 
// type*
local factors  club_LocalMembersNotMe club_OtherCommunityMembers

local contr_previous round1_join tot_contr_o100 global_o local_o  share_club_joinH `factors'
//clubJoinH clubSize


local filename "$outputfolder\05-RegressionAll-v2-RandomEF-Join.xls"
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

***** Probit returns quite different results. Not sure which should be reported

local filename "$outputfolder\05-RegressionAll-v2-Probit-Join-ByCost.xls"
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



preserve 
keep if subsessionperiod<=10

* Prob of joining the club 
local settings "onecol  nonotes   label  dec(3) pdec(3) "

local independentVar highFC hetero
local independentVar2 highFC hetero hetero_highCost

*IF by costs: 
local endowment_diff hetero_high hetero_low


local game_contr  super_game round_o10
local indiv_char age_under20 male major_SorE social_x social_y 
// type*
local factors  club_LocalMembersNotMe club_OtherCommunityMembers dummy_payoff

local contr_previous round1_join tot_contr_o100 global_o local_o  share_club_joinH `factors'
//clubJoinH clubSize


local filename "$outputfolder\05-RegressionAll-v2-RandomEF-Join-R(first10).xls"
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

***** Probit returns quite different results. Not sure which should be reported

local filename "$outputfolder\05-RegressionAll-v2-Probit-Join-ByCost-R(first10).xls"
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


restore


*************************** Global: Contribution %  *****************************************
************** Independent variable: treatment variables 
************** Purpose: establish a comparison of contribution pattern 
*********** Use contribution share, it is not directly compariable because high FC makes the contribution share larger 
local settings "onecol  nonotes   label  dec(3) pdec(3) "


local treatment_related highFC hetero hetero_highCost 

local game_contr  super_game round_o10 
local indiv_char age_under20 male major_SorE social_x social_y 
// type*
local factors  club_LocalMembersNotMe club_OtherCommunityMembers dummy_payoff

local contr_previous round1_join tot_contr global_o local_o  share_club_joinH `factors'
//clubJoinH clubSize


local filename "$outputfolder\05-RegressionAll-v2-Main-Treatment-Contr-Shares-LG.xls"

// xi: xtreg round1_totCtr_share `treatment_related'  if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
// outreg2 using `filename' ,  replace `settings'  ctitle("Contribution share in round 1")
//
// xi: xtreg round1_totCtr_share `treatment_related' `game_contr' `indiv_char' if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
// outreg2 using `filename' ,  append `settings'  ctitle("Contribution share in round 1")
//
// xi: xtreg totCtr_share_nextRound `treatment_related'  if  WithGlobal==1, re cluster(sessioncode)
// outreg2 using `filename' ,  append `settings'  ctitle("Contribution share in round t+1")
//
// xi: xtreg totCtr_share_nextRound `treatment_related' `game_contr' `contr_previous' `indiv_char'  if  WithGlobal==1, re cluster(sessioncode)
// outreg2 using `filename' ,  append `settings'  ctitle("Contribution share in round t+1")


xi: xtreg round1_totCtr `treatment_related'   if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Contribution in round 1")

xi: xtreg round1_totCtr `treatment_related' `game_contr' endowment_adj `indiv_char' if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round 1")

xi: xtreg totCtr_nextRound `treatment_related'   if  WithGlobal==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")

xi: xtreg totCtr_nextRound `treatment_related' `game_contr' endowment_adj `contr_previous' `indiv_char'  if  WithGlobal==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")


preserve 
keep if subsessionperiod<=10


local filename "$outputfolder\05-RegressionAll-v2-Main-Treatment-Contr-Shares-LG-R(first10).xls"

xi: xtreg round1_totCtr `treatment_related'   if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Contribution in round 1")

xi: xtreg round1_totCtr `treatment_related' `game_contr' endowment_adj `indiv_char' if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round 1")

xi: xtreg totCtr_nextRound `treatment_related'  if  WithGlobal==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")

xi: xtreg totCtr_nextRound `treatment_related' `game_contr' endowment_adj `contr_previous' `indiv_char'  if  WithGlobal==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")

restore

***************************end of  Global: Contribution %  *****************************************

***************************Local Only: Contribution %  *****************************************

************** Independent variable: treatment variables 
************** Purpose: establish a comparison of contribution pattern 
*********** Use contribution share, it is not directly compariable because high FC makes the contribution share larger 
local settings "onecol  nonotes   label  dec(3) pdec(3) "


local treatment_related highFC hetero hetero_highCost 

local game_contr  super_game round_o10 
local indiv_char age_under20 male major_SorE social_x social_y 
// type*
local contr_previous    local_o  
// tot_contr

local filename "$outputfolder\05-RegressionAll-v2-Main-Treatment-Contr-Shares-L.xls"

xi: xtreg round1_totCtr  hetero  if  WithGlobal==0 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Contribution in round 1")

xi: xtreg round1_totCtr `treatment_related'  if  WithGlobal==0 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round 1")

xi: xtreg round1_totCtr `treatment_related' `game_contr' endowment_adj `indiv_char' if  WithGlobal==0 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round 1")

xi: xtreg totCtr_nextRound hetero  if  WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")

xi: xtreg totCtr_nextRound `treatment_related'  if  WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")


xi: xtreg totCtr_nextRound `treatment_related' `game_contr' endowment_adj `contr_previous' `indiv_char'  if  WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")


preserve 
keep if subsessionperiod<=10


local filename "$outputfolder\05-RegressionAll-v2-Main-Treatment-Contr-Shares-L-R(first10).xls"

xi: xtreg round1_totCtr `treatment_related'  if  WithGlobal==0 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Contribution in round 1")

xi: xtreg round1_totCtr `treatment_related' `game_contr' endowment_adj `indiv_char' if  WithGlobal==0 &  subsessionperiod==1 , re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round 1")

xi: xtreg totCtr_nextRound `treatment_related'  if  WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")

xi: xtreg totCtr_nextRound `treatment_related' `game_contr' endowment_adj `contr_previous' `indiv_char'  if  WithGlobal==0, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Contribution in round t+1")


restore

***************************end of Local Only: Contribution %  *****************************************



*************************** Global: Global Contribution Tradeoff   *****************************************
************** Independent variable: treatment variables 
************** Purpose: test hypotheses
*********** Use contribution
local settings "onecol  nonotes   label  dec(3) pdec(3) "


local treatment_related highFC hetero hetero_highCost 

local game_contr  super_game round_o10 
local indiv_char age_under20 male major_SorE social_x social_y 
// type*
local factors  club_LocalMembersNotMe club_OtherCommunityMembers dummy_payoff
local factors_nextroundS1 club_LocalMembersNotMe_nextRound club_OtherCommunity_nextRound dummy_payoff

// local contr_previous round1_join tot_contr global_o local_o  share_club_joinH `factors'
//clubJoinH clubSize
local contr_previous tot_contr global_o local_o  share_club_joinH `factors_nextroundS1'


// This is for all (including those who didn't join)
// local filename "$outputfolder\05-RegressionAll-v2-Treatment-Global-Contr-LG.xls"
//
// xi: xtreg round1_globalCtr `treatment_related'  endowment_adj if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
// outreg2 using `filename' ,  replace `settings'  ctitle("Global contribution in round 1")
//
// xi: xtreg round1_globalCtr `treatment_related' `game_contr' endowment_adj `indiv_char' if  WithGlobal==1 &  subsessionperiod==1 , re cluster(sessioncode)
// outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round 1")
//
// xi: xtreg globalContr_nextRound `treatment_related'  endowment_adj if  WithGlobal==1, re cluster(sessioncode)
// outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")
//
// xi: xtreg globalContr_nextRound `treatment_related' `game_contr' endowment_adj `contr_previous' `indiv_char'  if  WithGlobal==1, re cluster(sessioncode)
// outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")
//

local filename "$outputfolder\05-RegressionAll-v2-Treatment-Global-Contr-LG.xls"

xi: xtreg round1_globalCtr `treatment_related'  endowment_adj if  WithGlobal==1 &  subsessionperiod==1 & playerjoin_club==1, re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Global contribution in round 1")

xi: xtreg round1_globalCtr `treatment_related' `game_contr' endowment_adj `indiv_char' if  WithGlobal==1 &  subsessionperiod==1 & playerjoin_club==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round 1")

xi: xtreg globalContr_nextRound `treatment_related'  endowment_adj if  WithGlobal==1 & join_nextRound==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")

xi: xtreg globalContr_nextRound `treatment_related' `game_contr' endowment_adj `factors_nextroundS1' `indiv_char'  if  WithGlobal==1 & join_nextRound==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")

xi: xtreg globalContr_nextRound `treatment_related' `game_contr' endowment_adj `contr_previous' `indiv_char'  if  WithGlobal==1 & join_nextRound==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")



preserve 
keep if subsessionperiod<=10


local filename "$outputfolder\05-RegressionAll-v2-Treatment-Global-Contr-LG-R(first10).xls"

xi: xtreg round1_globalCtr `treatment_related'  endowment_adj if  WithGlobal==1 &  subsessionperiod==1 & playerjoin_club==1, re cluster(sessioncode)
outreg2 using `filename' ,  replace `settings'  ctitle("Global contribution in round 1")

xi: xtreg round1_globalCtr `treatment_related' `game_contr' endowment_adj `indiv_char' if  WithGlobal==1 &  subsessionperiod==1 & playerjoin_club==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round 1")

xi: xtreg globalContr_nextRound `treatment_related'  endowment_adj if  WithGlobal==1 & join_nextRound==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")

xi: xtreg globalContr_nextRound `treatment_related' `game_contr' endowment_adj `factors_nextroundS1' `indiv_char'  if  WithGlobal==1 & join_nextRound==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")

xi: xtreg globalContr_nextRound `treatment_related' `game_contr' endowment_adj `contr_previous' `indiv_char'  if  WithGlobal==1 & join_nextRound==1, re cluster(sessioncode)
outreg2 using `filename' ,  append `settings'  ctitle("Global contribution in round t+1")



restore

preserve
collapse playerjoin_club  if  WithGlobal==1 & subsessionperiod>1	, by(participantcode)
* TO check: 1 person never joined after period 1
sum, det
tab playerjoin_club

preserve
collapse playerjoin_club  if  WithGlobal==1 & subsessionperiod==1	, by(participantcode)
tab playerjoin_club

preserve
collapse playerjoin_club  if  WithGlobal==1 	, by(participantcode)
tab playerjoin_club

***************************end of  Global: Contribution %  ****************************************



***************************Both : DID *****************************************

local indep WithGlobal  hetero hetero_with //interaction_term
// local indep2 WithGlobal_join hetero_with_join 

// local indep WithGlobal hetero hetero_high hetero_with hetero_high_with

local  game_contr2 i.super_game*i.subsessionperiod
// local contr_previous tot_contr global_o local_o clubSize share_club_joinH

local game_contr   super_game subsessionperiod
// endowment_adj
local indiv_char age_under20 male major_SorE social_x social_y 
// type*



* Regression for global contribution 
* Separate all, high, low entry cost
local filename "$outputfolder\05-RegressionAll-v2-RandomEF-DID.xls"
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



preserve 
keep if subsessionperiod<=10

local indep WithGlobal  hetero hetero_with //interaction_term

local  game_contr2 i.super_game*i.subsessionperiod
local game_contr  endowment_adj super_game round_o10
local indiv_char age_under20 male major_SorE social_x social_y 

* Regression for global contribution 
* Separate all, high, low entry cost
local filename "$outputfolder\05-RegressionAll-v2-RandomEF-DID-R(first10).xls"
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

restore



***************************************
*********Hausman test to justify the use of RE model*************
*******************	********************
* Only appropriate for within-subject test 


local indep WithGlobal    hetero_with //interaction_term
// hetero hetero_with
local  game_contr2 i.super_game*i.subsessionperiod
local game_contr   super_game round_o10
local group_char 
local indiv_char age_under20 male major_SorE social_x social_y 

* Regression for global contribution 
* Separate all, high, low entry cost
* Random effect regression
// start with all 

local contr  `game_contr' 

xi: xtreg share_totalContr  `indep' `contr'  if lowFC==1, fe
estimates store fixed
xi: xtreg share_totalContr `indep' `contr'   if lowFC==1, re
hausman fixed ., force sigmamore


;





