* **********************************************************************
* Project: Mont Carlo lecture
* Created: October 2018
* Last modified: November 2019
* Stata v.16

* Note: file directory is set in section 0
* users only need to change the location of their path there

* does
	* Add description here

* assumes
	* Add any dependencies here

* TO DO:
	* You can add next steps here if useful (or things that need to be done before code is useful)

* **********************************************************************
* 0 - General setup
* **********************************************************************
* Users can change these two filepaths
* All subsequent files are referred to using dynamic, absolute filepaths
	global myDocs 		"N:/users/tjernstroem"
	global mainFolder 	"$myDocs/Teaching/CBA/docs/stata"

* **********************************************************************
* 	After this, please refer to all files throughout the code accordingly.
* 	Include all files in " " in case other users have spaces in filepath.
* 	For example:
* 	use "$mainFolder/data/coolnewdata.dta", clear
* **********************************************************************
* 	Also, label your data EVERY time you save a data set
* 	The most important part is the "created by [current-do-file]" part
*
* 	label data "Short description | $S_DATE | created using do-file.do"
* 	save "$mainFolder/data/coolnewdata.dta", replace
* **********************************************************************

* Set graph and Stata preferences
	set more off

* Start a log file
	cap: log close
	log using "$myDocs/logs/same_name_as_dofile", replace

**********************************************************************
* 1 - Set-up
**********************************************************************
* Clear memory
	clear all
* Set a seed to ensure replicability
	set seed 101010101
* The number of observations equals the number of ...?
	set obs 5000

* Let's build a pool!
* Define some basic parameters for building a pool:
* One-time costs and benefits:
	gen construction_costs = 14.5
	lab var construction_costs "Construction costs, million USD"

	gen scrap_value = 0.8
	lab var scrap_value "Scrap value, million USD"

* Ongoing costs and benefits:
	gen maintenance_costs = 6.2
	lab var maintenance_costs "Maintenance costs, million USD"

	gen revenues = 6.6
	lab var revenues "Yearly revenues, million USD"

	gen consumer_surplus = 1.37
	lab var consumer_surplus "Consumer surplus generated, million USD"

	scalar discount_rate = .07

**********************************************************************
* 2 - Generate a variable that contains PVNB
**********************************************************************
* Let's look just at 10 years for simplicity
* Assume up-front costs incurred in year 0
* and revenues + maintenance costs kick in in year 1
	gen pvnb = -construction_costs ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^1 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^2 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^3 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^4 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^5 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^6 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^7 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^8 ///
	+ (revenues + consumer_surplus - maintenance_costs)/(1+discount_rate)^9 ///
	+ (revenues + consumer_surplus - maintenance_costs + ///
	scrap_value)/(1+discount_rate)^10

* Simple summary of results
	sum pvnb
	di in red "Our base case results in PVNB = " pvnb

**********************************************************************
* 3 - Introduce uncertainty in one variable
**********************************************************************
* So what about if we feel uncertain about our estimate of consumer surplus?
* Let's do a small Monte Carlo exercise, drawing from a uniform distribution

* Draw consumer surplus values from the uniform distribution
	gen cs_uniform = runiform(0, 2.74)
	lab var cs_uniform "Consumer surplus, drawn from a uniform"

* Look at them
	br cs_uniform

	hist cs_uniform, percent scheme(plotplain)

* That looks pretty lumpy --> go up to top and set obs to 5000 instead
* set obs 5000
	hist cs_uniform, percent scheme(plotplain)

* That looks better
* So let's re-calculate our pvnb:
	gen pvnb_uniform = -construction_costs ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^1 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^2 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^3 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^4 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^5 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^6 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^7 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^8 ///
	+ (revenues + cs_uniform - maintenance_costs)/(1+discount_rate)^9 ///
	+ (revenues + cs_uniform - maintenance_costs 		///
	+ scrap_value)/(1+discount_rate)^10
	lab var pvnb_uniform "PVNB with CS drawn from uniform, million USD"

* What does it look like?
	br pvnb*	// More interesting!

* Summarize
	sum pvnb_uniform, detail	// Add detail to get more info from summarize

* Let's see it in a histogram
	hist pvnb_uniform, percent scheme(plotplain) ///
	title("PVNB of pool construction" 			///
	"with CS drawn from U(0, 2.74), {&delta} = 7%")


**********************************************************************
* 4 - Draw another variable from the triangular distribution
**********************************************************************
* We think the probability distribution of maintenance costs
* can be approximated by a triangular centered at 6.2

* First we need to define a program to draw from the triangular
	* might want to move this up to the top of the .do file

* Program to generate triangular distributions
	* 1 = minimum value
	* 2 = mode (peak)
	* 3 = maximum value
	* 4 = name of triangular variable generated

	quietly: capture program drop Triangular    // (will get error if in memory)
	quietly: program define Triangular
	local min = `1'
	local mode = `2'
	local max = `3'
	local variable = "`4'"
	local cutoff=(`mode'-`min')/(`max'-`min')
	generate Tri_temp = uniform()

	generate `variable' = `min' + 	///
	sqrt(Tri_temp*(`mode'-`min')*(`max'-`min')) if Tri_temp<`cutoff'

	replace `variable' = `max' -	///
	sqrt((1-Tri_temp)*(`max'-`mode')*(`max'-`min')) if Tri_temp>=`cutoff'

	drop Tri_temp					// No longer needed
	end

* Generate variable called mc_triangular with the following features
	* mode: the previous fixed value, i.e. 6.2
	* set min: 6.2 - 3 = 3.2
	* set max: 6.2 + 3 = 9.2

	Triangular 3.2 6.2 9.2 mc_triangular
	lab var mc_triangular "Maintenance costs drawn from triangular distribution"

* What happens to our pvnb?
	gen pvnb_tri = -construction_costs ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^1 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^2 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^3 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^4 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^5 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^6 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^7 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^8 ///
	+ (revenues + cs_uniform - mc_triangular)/(1+discount_rate)^9 ///
	+ (revenues + cs_uniform - mc_triangular 		///
	+ scrap_value)/(1+discount_rate)^10
	lab var pvnb_uniform "PVNB with CS drawn from triangular, million USD"

**********************************************************************
* 5 - Graphs
**********************************************************************
clear all

* Make ugly graph first
	set seed 101010101
	set obs 5000

	gen pvnb1 = rnormal(10.2, 3.5)
	gen pvnb2 = rnormal(12.3, 9)

	twoway	(hist pvnb1, width(1.2))	///
		,legend(order(1 "Option 1" 2 "Option 2") pos(5) cols(2))	///
		ytitle("Density") xtitle("PVNB (millions, USD)") ylab(,angle(vertical))

**********************************************************************
* 6 - Make less ugly graph
**********************************************************************
* Save some typing by setting scheme here
	set scheme plotplain

* Set some graph options
	local hist1 = "fcolor(red%30) lcolor(red%80) density"
	local hist2 = "fcolor(ebblue%40) lcolor(ebblue%80) lwidth(vvthin) density"
	local density1 = "fcolor(red%20) lcolor(%0)"
	local density2 = "fcolor(ebblue%20) lcolor(%0)"

twoway	(hist pvnb1, `hist1')	///
		(kdensity pvnb1, recast(area) `density1')	///
		,legend(order(1 "Option 1") pos(5) cols(1))	///
		ytitle("Density") xtitle("PVNB (millions, USD)") ylab(,angle(vertical))

twoway	(hist pvnb1, `hist1' width(1.2))	///
		(hist pvnb2, `hist2' width(1.2))	///
		(kdensity pvnb1, recast(area) `density1')	///
		(kdensity pvnb2, recast(area) `density2') 	///
		,legend(order(1 "Option 1" 2 "Option 2") pos(5) cols(2))	///
		ytitle("Density") xtitle("PVNB (millions, USD)") ylab(,angle(vertical))

* Generate random variable for graph purposes
	gen randomThing = mc_triangular + 3*cs_uniform
	gen randomThing2 = 0.5*mc_triangular + 2.3*cs_uniform - 1

* Use macros!
	local scatter1 = "msymb(oh) color(red%30)"
	local scatter2 = "msymb(th) color(ebblue%30)"
	local fit1 = "alcolor(%0) fcolor(red%70) 	clpattern(shortdash)"
	local fit2 = "alcolor(%0) fcolor(ebblue%70) clpattern(solid)"

* Make graph
	twoway (scatter randomThing mc_triangular, `scatter1')   ///
	(scatter randomThing2 mc_triangular, `scatter2') 		///
	(lfitci randomThing mc_triangular, `fit1') 			    ///
	(lfitci randomThing2 mc_triangular, `fit2')			   ///
	, scheme(plotplain) legend(pos(5) col(2) 		       ///
	order(1 "First random thing" 2 "Second random thing"   ///
	4 "Fitted values, first random thing" 			      ///
	6 "Fitted values, second random thing"                ///
	3 "95% confidence interval" 5 "95% confidence interval"))

log close
