clear
set more off

cd "~/Dropbox/Recherche/Expe NGOs/Final submission/ModerateRadicalNGO Code"

use "RawData/RawDatasetMerged.dta", clear

//Rename the variables
ren q11 alim_rouge
ren q12 alim_blanche 
ren q13 alim_poisson
ren q14 alim_oeufs
ren q15 alim_laitiers
ren q16 alim_legumes
ren q17 alim_legumineuses
ren q18 alim_fruits
ren q19 alim_feculents
ren q21 opinion_changeClim
ren q22 opinion_revenu 
ren q23 opinion_femmesEmploi 
ren q24 opinion_homosexuels 
ren q31 conf_AN
ren q32 conf_justice 
ren q33 conf_police 
ren q34 conf_hommesPolitiques 
ren q35 conf_ONU 
ren q36 conf_entreprisesIndividuelles 
ren q37 conf_agriculteurs 
ren q38 conf_orgaScientifiques 
ren q39 conf_asso 
ren q41 polit_contact
ren q42 polit_milit
ren q43 polit_membre
ren q44 polit_badge
ren q45 polit_petition
ren q46 polit_manif
ren q47 polit_boycott
ren q48 polit_reseauxSociaux
ren q51 conso_souffrance
ren q52 conso_intellect
ren q53 conso_elevesPour
ren q54 conso_dieu
ren q55 conso_sante
ren q56 conso_genes
ren q57 conso_normal
ren q58 conso_aimeTrop
ren q59 conso_necessaireSante
ren q510 conso_environnement

//Recode variable into numerics
foreach var in  alim_feculents alim_fruits alim_legumineuses alim_legumes alim_laitiers alim_oeufs alim_poisson alim_blanche alim_rouge{
	replace `var'="1" if `var'=="Jamais"
	replace `var'="2" if `var'=="Quelques fois par an"
	replace `var'="3" if `var'=="Quelques fois par mois"
	replace `var'="4" if `var'=="Quelques fois par semaine"
	replace `var'="5" if `var'=="Presque à tous les repas"
	destring `var', replace
}

foreach var in conso_souffrance conso_intellect conso_elevesPour conso_dieu conso_sante conso_genes conso_normal conso_aimeTrop conso_necessaireSante conso_environnement opinion_homosexuels opinion_femmesEmploi opinion_revenu opinion_changeClim{ 
	replace `var'="1" if `var'=="1 (pas du tout d'accord)"
	replace `var'="7" if `var'=="7 (tout à fait d'accord)"
	destring `var', replace
}

foreach var in conf_asso conf_orgaScientifiques conf_agriculteurs conf_entreprisesIndividuelles conf_ONU conf_hommesPolitiques conf_police conf_justice conf_AN{
	replace `var'="1" if `var'=="1 (pas du tout confiance)"
	replace `var'="7" if `var'=="7 (complètement confiance)"
	destring `var', replace
}

foreach var in polit_contact polit_milit polit_membre polit_badge polit_petition polit_manif polit_boycott polit_reseauxSociaux{
	gen bin_`var'=.
	replace bin_`var'=0 if `var'=="Non"
	replace bin_`var'=1 if `var'=="Oui"
}

//Generate dummy for the treatment of the online questionnaire (order of the screens) (3/3)
encode t, gen(treat_quest)

//Types of diets
gen alimentation="Omnivore"
replace alimentation="Pescetarien" if alim_rouge<=2 & alim_blanche<=2
replace alimentation="Lacto-Ovo-Végétarien" if alimentation=="Pescetarien" & alim_poisson<=2
replace alimentation="Lacto-Végétarien" if alimentation=="Lacto-Ovo-Végétarien" & alim_oeufs<=2
replace alimentation="Vegan" if alimentation=="Lacto-Végétarien" & alim_laitiers<=2

gen regime=1 if alimentation=="Omnivore"
replace regime=2 if alimentation=="Pescetarien"
replace regime=3 if alimentation=="Lacto-Ovo-Végétarien"
replace regime=3 if alimentation=="Lacto-Végétarien"
replace regime=4 if alimentation=="Vegan"

//Diets
foreach var in oeufs laitiers poisson blanche rouge{
	gen severalTimesAWeekOrMore_`var'=cond(alim_`var'>=4,1,0)
}

//Rename variables of PMJ to show these are online
foreach var in conso_souffrance conso_intellect conso_elevesPour conso_dieu conso_sante conso_genes conso_normal conso_aimeTrop conso_necessaireSante conso_environnement{
	ren `var' `var'_EnLigne
}

//Keep the variables of interest
//keep conso_souffrance conso_intellect conso_elevesPour conso_dieu conso_sante conso_genes conso_normal conso_aimeTrop conso_necessaireSante conso_environnement treat_quest alim_oeufs alim_poisson alim_blanche alim_rouge alim_laitiers regime  opinion_* conf_* bin_* severalTimesAWeekOrMore_* conf_asso conf_orgaScientifiques conf_agriculteurs conf_entreprisesIndividuelles conf_ONU conf_hommesPolitiques conf_police conf_justice conf_AN
save  "Data/partiallyTreatedData.dta", replace
