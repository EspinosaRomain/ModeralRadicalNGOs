clear
set more off

cd "~/Dropbox/Recherche/Expe NGOs/Final submission/ModerateRadicalNGO Code"

use "Data/partiallyTreatedData.dta", clear

//Generate treatment names
gen treatment=""
replace treatment="Baseline" if sessioncode=="2ryiwioe" | sessioncode=="h42fitls"  | sessioncode=="htvmktjy" | sessioncode=="x324wdl9" | sessioncode=="papkymvr"
replace treatment="Abol" if sessioncode=="wmd5u698" | sessioncode=="2jpxk6ja"  |  sessioncode=="mnecr1vg"  | sessioncode=="wx96ek6e" | sessioncode=="umbdxfu0"
replace treatment="Welf" if sessioncode=="2n24udje" | sessioncode=="6px1pzb2" | sessioncode=="hbip8lxi" | sessioncode=="pk1l2tef" | sessioncode=="uyrjjuah"

save "Data/dataSessions.dta", replace

//Generate treatment variables
gen baseline=cond(treatment=="Baseline",1,0)
gen welf=cond(treatment=="Welf",1,0)
gen abol=cond(treatment=="Abol",1,0)

//Generate additional variables
gen femme=cond(ID4_questionnaire1playergenre=="Féminin",1,0)
gen newsletter=ID2_petition1playerabonnement
gen donAsso=ID2_petition1playercontributi
gen petitionElevage=ID2_petition1playersignature_ 
gen petitionRepas=BM
gen age=ID4_questionnaire1playerage
encode ID4_questionnaire1playerpolit, gen(polit)
gen religieux=cond(ID4_questionnaire1playerrelig=="Oui",1,0)
gen campagne=cond(ID4_questionnaire1playerenfan=="A la campagne",1,0)
gen bienPublic=ID1_bien_public1playercontrib

//Generate interaction variables
gen inter_public_base=bienPublic*base
gen inter_public_welf=bienPublic*welf
gen inter_public_abol=bienPublic*abol

forvalues k=1(1)10{
	gen question_`k'=.
	replace question_`k'=1 if ID2_petition1playerreponse`k'=="1 (pas du tout d'accord)"
	replace question_`k'=2 if ID2_petition1playerreponse`k'=="2"
	replace question_`k'=3 if ID2_petition1playerreponse`k'=="3"
	replace question_`k'=4 if ID2_petition1playerreponse`k'=="4"
	replace question_`k'=5 if ID2_petition1playerreponse`k'=="5"
	replace question_`k'=6 if ID2_petition1playerreponse`k'=="6"
	replace question_`k'=7 if ID2_petition1playerreponse`k'=="7 (tout à fait d'accord)"
}

//Generate PMJ in Lab
egen PMJ_EnSalle=rowtotal(question_*)

//Numerical Treatment Variables 
gen treat=1 if treatment=="Baseline"
replace treat=2 if treatment=="Welf"
replace treat=3 if treatment=="Abol"

label define labtreat 1 "Baseline" 2 "Welf" 3 "Abol"
label values treat labtreat

//Save data
save "Data/WorkingFile.dta", replace
