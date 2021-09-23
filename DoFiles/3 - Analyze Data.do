clear
set more off

cd "~/Dropbox/Recherche/Expe NGOs/Final submission/ModerateRadicalNGO Code"


//Import Data
use "Data/WorkingFile.dta"


//Online questionnaire: Animal-based consumption -- Table 3
pca alim_oeufs alim_poisson alim_blanche alim_rouge alim_laitiers
predict ABC_online 
pwcorr ABC_online alim_blanche alim_rouge alim_poisson alim_oeufs alim_laitiers, sig

//ABC by diet
tab regime
su ABC_online if regime==1
su ABC_online if regime==2
su ABC_online if regime==3
su ABC_online if regime==4

//Compare means for ABC
ttest ABC_online, by(treat_quest)
ranksum ABC_online, by(treat_quest)

//Online questionnaire : Pro-meat justification: Section 5.1.2
egen PMJ_online=rowtotal(conso_souffrance conso_intellect conso_elevesPour conso_dieu conso_sante conso_genes conso_normal conso_aimeTrop conso_necessaireSante conso_environnement)
replace PMJ_online=PMJ_online/70
su PMJ_online
alpha conso_souffrance_EnLigne conso_intellect_EnLigne conso_elevesPour_EnLigne conso_dieu_EnLigne conso_sante_EnLigne conso_genes_EnLigne conso_normal_EnLigne conso_aimeTrop_EnLigne conso_necessaireSante_EnLigne conso_environnement_EnLigne

//PMJ with PCA instead of sum -- Table OA1
pca conso_souffrance_EnLigne conso_intellect_EnLigne conso_elevesPour_EnLigne conso_dieu_EnLigne conso_sante_EnLigne conso_genes_EnLigne conso_normal_EnLigne conso_aimeTrop_EnLigne conso_necessaireSante_EnLigne conso_environnement_EnLigne
predict PMJ_online_PCA
pwcorr PMJ_online PMJ_online_PCA, sig

//Test difference in PMJ Online before the experiment across treatments
ttest PMJ_online, by(treat_quest)
ranksum PMJ_online, by(treat_quest)

//Figure  2
twoway (lfitci ABC_online PMJ_online) (scatter ABC_online PMJ_online), xtitle("Online pro-meat justifications (PMJ)") ytitle("Animal-based consumption (ABC)")/*
	*/ graphregion(color(white)) bgcolor(white) legend(off) text(-4 60  "Rho=0.565", size(small)) text(-4.3 60  "p<0.001", size(small))/*
	*/ xlab(0(0.1)1) ylab(-6(2)4)
graph export "ProMeatJustandDiet.eps", as(eps) preview(off) replace

//Correlations btw PMJ and ABC
pwcorr PMJ_online ABC_online, sig

//Test change in PM
ttest PMJ_online, by(treat_quest)
ranksum PMJ_online, by(treat_quest)

//Regressions of ABC on PMJ (In the original version)
reg PMJ_online ABC_online 
capture gen lnPMJ_online=ln(PMJ_online)
su ABC_online
capture gen lnABC_online=ln(ABC_online-`r(min)'+0.01)
reg lnPMJ_online lnABC_online

//Regressions of ABC on PMJ (In the revision)
reg ABC_online PMJ_online  
reg lnABC_online lnPMJ_online

//Generate variables  -- Table OA2
//Leftism 
pca opinion_*
predict leftism
pwcorr PMJ_online ABC_online leftism, sig

//Trust -- Table OA4
pca conf_*
predict generalTrust nonGovTrust
pwcorr PMJ_online ABC_online generalTrust nonGovTrust, sig

//Political activism -- Table OA3
pca bin_*
predict politicalActivism nonpartisanActivism
pwcorr PMJ_online ABC_online politicalActivism nonpartisanActivism, sig
gen missingActivism=cond(politicalActivism==.,1,0)
gen politicalActivism_miss0=cond(politicalActivism==.,0,politicalActivism)
gen nonpartisanActivism_miss0=cond(nonpartisanActivism==.,0,nonpartisanActivism)

save "Data/WorkingFile_WithVariables.dta", replace

//In-lab PMJ
egen PMJ_inLab=rowtotal(question_*)
replace PMJ_inLab=PMJ_inLab/70

//Change in pro-meat justifications
gen diff_proMeat=PMJ_inLab-PMJ_online
ttest diff_proMeat=0 if base==1
pwcorr PMJ_online PMJ_inLab if base==1, sig

//Generate graph for the changes in PMJ -- Figure 3
qui gen ub=.
qui gen lb=.
qui gen mean=.

forvalues k=1(1)3{
	qui ci means diff_proMeat if treat==`k'
	qui replace ub=`r(ub)' if treat==`k'
	qui replace lb=`r(lb)' if treat==`k'
	qui replace mean=`r(mean)' if treat==`k'
}

twoway (bar mean treat, barw(.8)) (rcap ub lb treat, color(black)),/*
	*/ytitle("Change in pro-meat justifications") graphregion(color(white)) bgcolor(white) xscale(noline)/*
	*/xlab(1 2 3, valuelabel) xtitle("")/*
	*/legend(off) 

graph export "ChangeInPMJ.eps", as(eps) preview(off) replace
drop mean ub lb


//Changes across treatments
su diff_proMeat if welf==1
su diff_proMeat if abol==1

ttest diff_proMeat=0 if welf==1
ttest diff_proMeat=0 if abol==1

//Changes compared to baseline
ttest diff_proMeat if base==1 | welf==1, by(treat)
ttest diff_proMeat if base==1 | abol==1, by(treat)

//Changes between welf and abol
ttest diff_proMeat if welf==1 | abol==1, by(treat)
ranksum diff_proMeat if welf==1 | abol==1, by(treat)

//Test if the order of screens in the lab affects the results
ren ID2_petition1playerordre_ecra ordreEcrans
ranksum diff_proMeat if base==1, by(ordreEcrans)
ranksum diff_proMeat if welf==1, by(ordreEcrans)
ranksum diff_proMeat if abol==1, by(ordreEcrans)

//Reduction of dimensionality for actual choices: generate pro-animal scores
pca donAsso petitionElevage petitionRepas newsletter
predict proanimal
su proanimal
replace proanimal=(proanimal-`r(min)')/(`r(max)'-`r(min)')
su proanimal

//Proanimal scores across treatments
su proanimal if base==1, d
su proanimal if welf==1, d
su proanimal if abol==1, d

ranksum proanimal if base==1 | welf==1, by(welf)
ranksum proanimal if base==1 | abol==1, by(abol)
ranksum proanimal if welf==1 | abol==1, by(abol)

//Table of summary statistics  -- Table 2
mat sumStat=J(31,4,.)
local k=1
foreach var in femme campagne religieux age severalTimesAWeekOrMore_oeufs severalTimesAWeekOrMore_laitiers severalTimesAWeekOrMore_poisson severalTimesAWeekOrMore_blanche severalTimesAWeekOrMore_rouge conf_AN conf_justice conf_police conf_hommesPolitiques conf_ONU conf_entreprisesIndividuelles conf_agriculteurs conf_orgaScientifiques conf_asso proanimal  donAsso petitionElevage petitionRepas newsletter PMJ_online ABC_online leftism bienPublic generalTrust nonGovTrust politicalActivism nonpartisanActivism{
	qui su `var' 
	mat sumStat[`k',1]=round(`r(mean)',0.01)
	mat sumStat[`k',2]=round(`r(sd)',0.01)
	mat sumStat[`k',3]=round(`r(min)',0.01)
	mat sumStat[`k',4]=round(`r(max)',0.01)
	local k=`k'+1
}
mat rownames sumStat=femme campagne religieux age severalTimesAWeekOrMore_oeufs severalTimesAWeekOrMore_laitiers severalTimesAWeekOrMore_poisson severalTimesAWeekOrMore_blanche severalTimesAWeekOrMore_rouge conf_AN conf_justice conf_police conf_hommesPolitiques conf_ONU conf_entreprisesIndividuelles conf_agriculteurs conf_orgaScientifiques conf_asso proanimal  donAsso petitionElevage petitionRepas newsletter PMJ_online ABC_online leftism bienPublic generalTrust nonGovTrust politicalActivism nonpartisanActivism
mat list sumStat

//Detecting Potential Differences across treatments  -- Table 6
mat sumStat=J(13,6,.)
local k=1
foreach var in proanimal femme campagne religieux PMJ_online age ABC_online leftism bienPublic generalTrust nonGovTrust politicalActivism nonpartisanActivism{
	qui su `var' if base==1
	mat sumStat[`k',1]=round(`r(mean)',0.01)
	qui su `var' if welf==1
	mat sumStat[`k',2]=round(`r(mean)',0.01)
	qui su `var' if abol==1
	mat sumStat[`k',3]=round(`r(mean)',0.01)
	qui ranksum `var' if base==1 | welf==1, by(welf)
	mat sumStat[`k',4]=round(2 * normprob(-abs(`r(z)')),0.001)
	qui ranksum `var' if base==1 | abol==1, by(abol)
	mat sumStat[`k',5]=round(2 * normprob(-abs(`r(z)')),0.001)
	qui ranksum `var' if welf==1 | abol==1, by(abol)
	mat sumStat[`k',6]=round(2 * normprob(-abs(`r(z)')),0.001)
	local k=`k'+1
}
mat list sumStat


//Regressions -- Table 7 and OA5
reg proanimal welf abol
outreg2  using "treatmentReg",  stats(coef se)  replace 
reg proanimal welf abol femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg",  stats(coef se)  append
test welf=abol
reg proanimal welf abol bienPublic femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg",  stats(coef se)  append
reg proanimal welf abol inter_public_base inter_public_welf inter_public_abol femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg",  stats(coef se)  append

//Regressions per type of action  -- Table 8 and OA6
reg donAsso welf abol bienPublic femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  replace
reg donAsso welf abol inter_public_base inter_public_welf inter_public_abol femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  append
reg petitionElevage welf abol bienPublic femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  append
reg petitionElevage welf abol inter_public_base inter_public_welf inter_public_abol femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  append
reg petitionRepas welf abol bienPublic femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  append
reg petitionRepas welf abol inter_public_base inter_public_welf inter_public_abol femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  append
reg newsletter welf abol bienPublic femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  append
reg newsletter welf abol inter_public_base inter_public_welf inter_public_abol femme campagne PMJ_online religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0 
outreg2  using "treatmentReg_decomposed",  stats(coef se)  append

//Relationship between proanimal and PMJ in Baseline
pwcorr PMJ_inLab proanimal if base==1, sig

//Relationship between online and inlab PMJ
pwcorr PMJ_inLab PMJ_online if base==1, sig

//Regression on the residuals
reg proanimal PMJ_inLab if base==1
predict xb_proAnim if base==1
gen res_proAnim=proanimal-xb_proAnim if base==1
reg res_proAnim PMJ_online


//3SLS -- Table 9 and OA7
global controls "femme bienPublic campagne religieux age ABC_online leftism generalTrust nonGovTrust missingActivism politicalActivism_miss0 nonpartisanActivism_miss0"
reg3 (PMJ_inLab PMJ_online welf abol $controls) (proanimal PMJ_inLab welf abol $controls)
outreg2  using "3SLS",  stats(coef se)  replace

//Belieff effect
nlcom [PMJ_inLab]_b[welf]*[proanimal]_b[PMJ_inLab]
nlcom [PMJ_inLab]_b[abol]*[proanimal]_b[PMJ_inLab]

//Reactance effects
nlcom [proanimal]_b[welf]
nlcom [proanimal]_b[abol]

//Total effects
nlcom [PMJ_inLab]_b[welf]*[proanimal]_b[PMJ_inLab]+[proanimal]_b[welf]
nlcom [PMJ_inLab]_b[abol]*[proanimal]_b[PMJ_inLab]+[proanimal]_b[abol]

//Save data
save "Data/DataAnalyzed.dta", replace


//Graph for PMJ arguments -- Figure OA1
keep participantcode conso_souffrance_EnLigne conso_intellect_EnLigne conso_elevesPour_EnLigne conso_dieu_EnLigne conso_sante_EnLigne conso_genes_EnLigne conso_normal_EnLigne conso_aimeTrop_EnLigne conso_necessaireSante_EnLigne conso_environnement_EnLigne
reshape long conso_, i(participantcode)  string

replace _j="Nice" if _j=="aimeTrop_EnLigne"
replace _j="Religious Justification" if _j=="dieu_EnLigne"
replace _j="Hierarchical Justification" if _j=="elevesPour_EnLigne"
replace _j="Environment" if _j=="environnement_EnLigne"
replace _j="Natural" if _j=="genes_EnLigne"
replace _j="Animal Mind" if _j=="intellect_EnLigne"
replace _j="Necessary" if _j=="necessaireSante_EnLigne"
replace _j="Normal" if _j=="normal_EnLigne"
replace _j="Good for health" if _j=="sante_EnLigne"
replace _j="Animal Pain" if _j=="souffrance_EnLigne"

gen order=1
replace order=2 if _j=="Animal Mind"
replace order=3 if _j=="Hierarchical Justification"
replace order=4 if _j=="Religious Justification"
replace order=5 if _j=="Good for health"
replace order=6 if _j=="Natural"
replace order=7 if _j=="Normal"
replace order=8 if _j=="Nice"
replace order=9 if _j=="Necessary"
replace order=10 if _j=="Environment"

graph hbar conso_/*
	*/, bargap(10) over(_j, sort(order)) graphregion(color(white)) bgcolor(white) ytitle("Average score")
graph export "PMJScores.eps", as(eps) preview(off) replace
