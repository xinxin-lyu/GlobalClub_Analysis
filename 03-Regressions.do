
global project "C:\Users\xinxi\Purdue\PublicGood_SecondOption4Rich\Experiment\"
* directory "$project\DataAnalysis"
global datafolder "$project\ProcessedData"
global outputfolder "$project\Output"


*************************************************************
import delimited "$datafolder\individual_data.csv", clear
rename participant participantcode
save "$datafolder\individual_data", replace

import delimited "$datafolder\data_Oppor_allB.csv", clear
merge m:1 participantcode using "$datafolder\individual_data"
drop _m

* Identify data id 
isid sessioncode sequence  subsessionround_number subsessionperiod participantcode
// groupid_in_subsession playerid_in_group = participantcode

* Generate variables 
gen round_whole = subsessionround_number
replace round_whole =  subsessionround_number + 50 if sequence == "B2_bab"
encode participantcode, gen(subject_id)
xtset subject_id round_whole

gen super_game = subsessionsg
replace super_game = subsessionsg+3 if sequence == "B2_bab"

gen lowFC = fc==20
gen hetero = treatment == "HETERO"

gen endowment_adj = endowment
replace endowment = 10 if endowment<=10
replace endowment = 20 if endowment>10 & endowment<=20
replace endowment = 30 if endowment>20 

// encode some string variables 
encode age, gen(age_g)
gen male=gender=="Male"
replace male = . if gender=="Prefer Not to Say" // 2 subjects prefer not to say
tab male gender


// generate others' contribution 
gen global_o = grouptotal_contribution_global - playercontribution_global
gen local_o = playertotal_contribution_local - playercontribution_local
// global club size
// bys sessioncode subsessionsg subsessionperiod groupid_in_subsession: gen count_temp = _n  // in bab, could have duplicates

bys sessioncode round_whole groupid_in_subsession: gen clubSize = sum(playerjoin_club)
gen join_HighE = playerjoin_club * (endowment==30)
bys sessioncode round_whole groupid_in_subsession: gen clubJoinH = sum(join_HighE)

xtset subject_id round_whole
// round 1 join decision vs next round join decision 
gen round1_join = playerjoin_club if subsessionperiod==1
bys subject_id: gen join_nextRound = f.playerjoin_club
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
// for round 1, use the same variable
replace clubSize_nextRound = clubSize if subsessionround_number==1

bys subject_id: gen clubJoinH_nextRound = f.clubJoinH
replace clubJoinH_nextRound = . if subsessionround_number==10 | subsessionround_number==30 | subsessionround_number==50 
// for round 1, use the same variable
replace clubJoinH_nextRound = clubJoinH if subsessionround_number==1



// generate variables for regression 
gen hetero_high = hetero * (endowment==30)
tab treatment hetero_high

gen hetero_lowCost = hetero * lowFC

// order effect
gen BeforeLocal = 0
replace BeforeLocal=1 if sequence=="B1_bab"

gen BAB =  sequence!="B1"

* Tabstat some basic infor between subjects joining and not joining the club 
* 1st: tabstat subjects characteristics
local indiv_char age_g male social_x social_y endowment
tabstat `indiv_char' , by(playerjoin_club)
tabstat `indiv_char' , by(round1_join)
tabstat `indiv_char' , by(join_nextRound)


* 2nd: tabstat contributions in the previous round 
local contributionInd_p tot_contr playercontribution_local playercontribution_global playerpayoff
local contributionGrp_p global_o local_o

tabstat `contributionInd_p' `contributionGrp_p', by(join_nextRound)

* 3rd: by endowment, see who is more likely to join the club: 
tabstat playerjoin_club round1_join, by(endowment)
tabstat playerjoin_club round1_join if round_whole<=50, by(endowment)
// e=20 84% join in the first round of each match; e=10 or 30, no significant diff in the proportion of joinning 
tabstat playerjoin_club round1_join if lowFC==1, by(endowment)
tabstat playerjoin_club round1_join if lowFC==0, by(endowment)

* 4th: 
sum social_x, det
gen social_x_5 = social_x<=5 
label var social_x_5 "Prefer advantageous inequaity"
gen social_y_5 = social_y<=5 
label var social_y_5 "Prefer disadvantageous inequaity"
tabstat playerjoin_club round1_join if round_whole<=50, by(social_x_5) stat(mean n)
tabstat playerjoin_club round1_join if round_whole<=50, by(social_y_5) stat(mean n)




*classify subjects into different types 
// collapse tot_contr playercontribution_local playercontribution_global endowment, by(subject_id)
// sum tot_contr, det
// sum playercontribution_global, det
// sum playercontribution_local, det



* Prob of joining the club in the first round/next round
local settings "onecol  nonotes   label  dec(2) pdec(3) "


local treatment_related lowFC hetero hetero_lowCost BeforeLocal  super_game round_whole
// hetero_high 
// subsessionperiod : not ideal, super_game flip sign 
local indiv_char age_g male social_x social_y 
local size clubSize_nextRound clubJoinH_nextRound 
local contr_previous tot_contr global_o local_o clubSize clubJoinH

* Regression for global contribution 
local filename "$outputfolder\03-Regressions-RandomEF-globalContr-Conditional.xls"
* Random effect regression
xi: xtreg round1_globalCtr `treatment_related' if playerjoin_club==1, re
outreg2 using `filename' ,  replace `settings'  
xi: xtreg round1_globalCtr `treatment_related' `size' if playerjoin_club==1, re
outreg2 using `filename' ,  append `settings'  
xi: xtreg round1_globalCtr `treatment_related' `indiv_char' `size' if playerjoin_club==1, re
outreg2 using `filename' ,  append `settings'  

xi: xtreg globalContr_nextRound `treatment_related'  if playerjoin_club==1 , re
outreg2 using `filename' ,  append `settings'  
xi: xtreg globalContr_nextRound `treatment_related' `contr_previous' `size' if playerjoin_club==1 , re
outreg2 using `filename' ,  append `settings'  
xi: xtreg globalContr_nextRound `treatment_related' `contr_previous' `indiv_char' `size' if playerjoin_club==1, re
outreg2 using `filename' ,  append `settings'  


* Regression for global contribution 
local filename "$outputfolder\03-Regressions-Tobit-globalContr.xls"
* Random effect regression
xi: xttobit round1_globalCtr `treatment_related' , ll(0)
outreg2 using `filename' ,  replace `settings'  
xi: xttobit round1_globalCtr `treatment_related' `size' , ll(0)
outreg2 using `filename' ,  append `settings'  
xi: xttobit round1_globalCtr `treatment_related' `indiv_char' `size', ll(0)
outreg2 using `filename' ,  append `settings'  


xi: xttobit globalContr_nextRound `treatment_related'  , ll(0)
outreg2 using `filename' ,  append `settings'  
xi: xttobit globalContr_nextRound `treatment_related' `contr_previous' `size' , ll(0)
outreg2 using `filename' ,  append `settings'  
xi: xttobit globalContr_nextRound `treatment_related' `contr_previous' `indiv_char' `size', ll(0)
outreg2 using `filename' ,  append `settings'  



* Regression for global contribution 
local filename "$outputfolder\03-Regressions-RandomEF-localContr.xls"
* Random effect regression
xi: xtreg round1_localCtr `treatment_related' `size' , re
outreg2 using `filename' ,  replace `settings'  
xi: xtreg round1_localCtr `treatment_related' `indiv_char' `size', re
outreg2 using `filename' ,  append `settings'  

xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `size' , re
outreg2 using `filename' ,  append `settings'  
xi: xtreg localContr_nextRound `treatment_related' `contr_previous' `indiv_char' `size', re
outreg2 using `filename' ,  append `settings'  
;





* Prob of joining the club 
local settings "onecol  nonotes   label  dec(2) pdec(3) "

local treatment_related lowFC hetero hetero_lowCost BeforeLocal super_game round_whole
//hetero_high
//BAB not better
// subsessionperiod : not ideal, super_game flip sign
local indiv_char age_g male social_x social_y 
local contr_previous tot_contr global_o local_o clubSize clubJoinH


local filename "$outputfolder\03-Regressions-RandomEF.xls"
* Random effect regression
xi: xtreg round1_join `treatment_related' , re
outreg2 using `filename' ,  replace `settings'  
xi: xtreg round1_join `treatment_related' `indiv_char', re
outreg2 using `filename' ,  append `settings'  
//In round 1, only fixed cost seems to increase the prob of joining the club 

xi: xtreg playerjoin_club `treatment_related' , re
outreg2 using `filename' ,  append `settings'  
xi: xtreg playerjoin_club `treatment_related' `indiv_char', re
outreg2 using `filename' ,  append `settings'  

// social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join
xi: xtreg join_nextRound `treatment_related' `contr_previous' , re
outreg2 using `filename' ,  append `settings'  
xi: xtreg join_nextRound `treatment_related' `contr_previous' `indiv_char', re
outreg2 using `filename' ,  append `settings'  
;

local filename "$outputfolder\03-Regressions-Prob.xls"

* Prob regression
xi: prob round1_join `treatment_related' , cluster(subject_id)
outreg2 using `filename' ,  replace `settings'  
xi: prob round1_join `treatment_related' `indiv_char', cluster(subject_id)
outreg2 using `filename' ,  append `settings'  
//In round 1, only fixed cost seems to increase the prob of joining the club 

xi: prob playerjoin_club `treatment_related' , cluster(subject_id)
outreg2 using `filename' ,  append `settings'  
xi: prob playerjoin_club `treatment_related' `indiv_char', cluster(subject_id)
outreg2 using `filename' ,  append `settings'  

// social_x positively correlated, inequality aversion matters, more inequality aversion, more likely to join


xi: prob join_nextRound `treatment_related' `contr_previous' , cluster(subject_id)
outreg2 using `filename' ,  append `settings'  
xi: prob join_nextRound `treatment_related' `contr_previous' `indiv_char', cluster(subject_id)
outreg2 using `filename' ,  append `settings'  




xi: prob playerjoin_club lowFC hetero,  cluster(sessioncode) 

xi: xtreg playerjoin_club lowFC hetero,  vce(cluster sessioncode) re

xi: xtreg playerjoin_club lowFC hetero,  vce(cluster sessioncode) re
