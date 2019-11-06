## Code for simple Monte Carlo exercise

```Stata
* **********************************************************************
* Project: Monte Carlo lecture
* Created: October 2018
* Last modified: November 2019
* Stata v.16

* Note: file directory is set in section 0
* users only need to change the location of their path there

* does
    * Add description here

* assumes
    * Add any dependencies here
    {::options parse_block_html="true" /}
    <div style="background-color:##BCE954">
    * for packages, make a local with the packages
    local userpack ""
    </div>
* TO DO:
    * You can add next steps here if useful (or things that need to be done before code is useful)

* **********************************************************************
* 0 - General setup
* **********************************************************************
* Users can change these two filepaths
* All subsequent files are referred to using dynamic, absolute filepaths
    global myDocs "N:/users/tjernstroem"
    global mainFolder "$myDocs/PA881/stata"

* Check if the required packages are installed:
    foreach package in `userpack' {
        capture : which `package'
        if (_rc) {
            display as result in smcl `"Please install package {it:`package'} from SSC in order to run this do-file."' _newline `"You can do so by clicking this link: {stata "ssc install `package'":auto-install `package'}"'
            exit 199
        }
    }

* **********************************************************************
*     After this, please refer to all files throughout the code accordingly.
*     Include all files in " " in case other users have spaces in filepath.
*     For example                                                
*     use "$mainFolder/Input/raw_data/coolnewdata.dta", clear        
* **********************************************************************

* **********************************************************************
*     Every time you save a data set, label it and add a note
*     The most important part is the "created by [current-do-file]
*     
*     label data "Short description \ $S_DATE"
*     note: data_name.dta \ Short description \ created using current-do-file.do \ your initials \ $S_DATE
*     save "$mainFolder/Input/raw_data/data_name", replace
* **********************************************************************

* Set graph and Stata preferences
    set more off

* Start a log file
    cap: log close
    log using "$mainFolder/code/logs/mc_lecture", replace


**********************************************************************
* 1 - Set-up
**********************************************************************
    clear all
* Set a seed to ensure replicability
    set seed 101010101
* The number of observations equals the number of ...?
    set obs 500

* Let's build a pool
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


* Generate a variable that contains PVNB
* Let's look just at 10 years for simplicity
* Assume costs incurred in year 0, and revenues. maintenance kick in in year 1
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

sum pvnb
di in red "Our base case results in PVNB = " pvnb

**********************************************************************
* 2 - Introduce uncertainty
**********************************************************************
* So what about if we feel uncertain about our estimate of consumer surplus?
* Let's make a small Monte Carlo exercise, drawing from a uniform distribution

gen consumer_surplus_uniform = runiform(0, 2.74)
lab var consumer_surplus_uniform "Consumer surplus, drawn from a uniform"
br consumer_surplus_uniform
hist consumer_surplus_uniform, percent scheme(plotplain)

* That looks pretty lumpy --> go up to top and set obs to 5000 instead
* set obs 5000
hist consumer_surplus_uniform, percent scheme(plotplain)

x
* That looks better
* So let's re-calculate our pvnb:

gen pvnb_uniform = -construction_costs ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^1 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^2 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^3 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^4 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^5 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^6 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^7 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^8 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate)^9 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs + scrap_value)/(1+discount_rate)^10

lab var pvnb_uniform "PVNB with random CS, million USD"

br pvnb_uniform
hist pvnb_uniform, percent scheme(plotplain) title("PVNB of pool construction" "with varying consumer surplus and discount rate = 7%")
sum pvnb_uniform, det


* **********
* 3 - Change discount rate to 3%
* **********
* What if we wanted to change the discount rate?
scalar discount_rate_low = .03
gen pvnb_uniform2 = -construction_costs ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^1 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^2 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^3 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^4 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^5 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^6 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^7 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^8 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs)/(1+discount_rate_low)^9 ///
+ (revenues + consumer_surplus_uniform - maintenance_costs + scrap_value)/(1+discount_rate_low)^10
lab var pvnb_uniform2 "PVNB with random CS, million USD"

hist pvnb_uniform2, percent scheme(plotplain) title("PVNB of pool construction" "with varying consumer surplus and discount rate = 3%")
sum pvnb_uniform2, det
**********************************************************************
* 3 - Make ugly graph
**********************************************************************

clear all

* Make ugly graph first

set seed 101010101

set obs 5000

gen pvnb1 = rnormal(10.2, 3.5)
gen pvnb2 = rnormal(12.3, 9)

twoway    (hist pvnb1, width(1.2))    ///
        ,legend(order(1 "Option 1" 2 "Option 2") pos(5) cols(2))    ///
        ytitle("Density") xtitle("PVNB (millions, USD)") ylab(,angle(vertical))

**********************************************************************
* 4 - Make less ugly graph
**********************************************************************        

set scheme plotplain

* Some graphs by treatment and control
* Set some graph options
local hist1 = "fcolor(red%30) lcolor(red%80) density"
local hist2 = "fcolor(ebblue%40) lcolor(ebblue%80) lwidth(vvthin) density"
local density1 = "fcolor(red%20) lcolor(%0)"
local density2 = "fcolor(ebblue%20) lcolor(%0)"

sum pvnb1
local mean1 = `r(mean)'
sum pvnb2
local mean2 = `r(mean)'

twoway    (hist pvnb1, `hist1')    ///
        (kdensity pvnb1, recast(area) `density1')    ///
        ,legend(order(1 "Option 1") pos(5) cols(1))    ///
        ytitle("Density") xtitle("PVNB (millions, USD)") ylab(,angle(vertical))



twoway    (hist pvnb1, `hist1' width(1.2))    ///
        (hist pvnb2, `hist2' width(1.2))    ///
        (kdensity pvnb1, recast(area) `density1')    ///
        (kdensity pvnb2, recast(area) `density2')     ///
        ,legend(order(1 "Option 1" 2 "Option 2") pos(5) cols(2))    ///
        ytitle("Density") xtitle("PVNB (millions, USD)") ylab(,angle(vertical))

```
