## Code to establish directory structure

```Stata
* **********************************************************************
* **********************************************************************
* Project: YourProject
* Created: November 2019
* Last modified: 11/04/2019 by ET
* Stata v.16

* Note: file directory is set in section 0
* users only need to change the location of their path there
* or their initials
* **********************************************************************
* does
    /* This code runs all do-files needed for data work.
    It runs all "round"-specific master scripts, which contain the
    round-specific tasks. Rounds here means all the different data sources.

    This script also establishes an identical workspace between users
    by specifying settings, noting any required programs / user-written code,
    and setting global macros. These globals help ensure consistency, accuracy
    and conciseness in the code.

    Further, this master .do file maps all files within the data folder
    and serves as the starting point to find any do-file, dataset or output. */

* assumes
	* Add any dependencies here
	* for packages, make a local containing any required packages
        local userpack ""

* TO DO:
    * Add to do list here

* **********************************************************************
* 0 - General setup
* **********************************************************************
* Users can change their initials
* All subsequent files are referred to using dynamic, absolute filepaths

* User initials:
* Emilia	et
* Tanvi 	tt
* Erik 		ek

* Set this value to the user currently using this file
    global user "et"
* **********************************************************************
* Set root folder globals
    if "$user" == "et" {
        global myDocs "Z:"
    }
    if "$user" == "tt" {
        global myDocs  "C:/Users/TanviTilloo/YourFavoriteFolder"
    }
    if "$user" == "ek" {
        global myDocs  "C:/Users/TanviTilloo/YourFavoriteFolder"
    }
* **********************************************************************
* Set sub-folder globals
    global projectFolder          "$myDocs/fertilizer_markets"
    global dataWork               "$projectFolder/dataWork"
    global inputSurvey            "$dataWork/inputSurvey"
    global mysteryShoppingR1      "$dataWork/mysteryShoppingR1"
	global mysteryShoppingR2      "$dataWork/mysteryShoppingR2"
    global fertilizerQuality      "$dataWork/fertilizerQuality"

/* Within each data folder, we will have the same sub-folders
	dataSets
    	raw 	// contains raw data, never to be altered
    	intermediate	// contains any intermediate data sets
		analysis	// analysis-ready data sets
	code	    // scripts specific to folder data & a folder-master .do file
        code/logs // where all log files should live
	output
        tables
        figures
	documentation	   // documentation
	questionnaire	   // questionnaires */

* Make a local macro containing all the folder names
    * temporarily set delimiter to ; so can break the line
    #delimit ;
    local directories = "$inputSurvey $mysteryShoppingR1 $mysteryShoppingR2
    $fertilizerQuality";
    #delimit cr

* Create file structure
	foreach folder of local directories {
		* capture ignores the error code if directory exists
		qui: capture mkdir "`folder'/"
		qui: capture mkdir "`folder'/dataSets/"
		qui: capture mkdir "`folder'/dataSets/raw/"
		qui: capture mkdir "`folder'/dataSets/intermediate/"
		qui: capture mkdir "`folder'/dataSets/analysis/"
		qui: capture mkdir "`folder'/code/"
		qui: capture mkdir "`folder'/code/logs"
		qui: capture mkdir "`folder'/output/"
		qui: capture mkdir "`folder'/output/tables/"
		qui: capture mkdir "`folder'/output/figures/""
		qui: capture mkdir "`folder'/documentation/"
		qui: capture mkdir "`folder'/questionnaire/"
	}

* **********************************************************************
* Check if any required packages are installed:
	foreach package in `userpack' {
		capture : which `package'
		if (_rc) {
			display as result in smcl `"Please install package {it:`package'} from SSC in order to run this do-file."' _newline `"You can do so by clicking this link: {stata "ssc install `package'":auto-install `package'}"'
			exit 199
		}
	}
* **********************************************************************
* Every time you save a data set, label it and add a note
* The most important part is the "created by [current-do-file]
*
* label data "Short description | $S_DATE"
* note: data_name.dta | Short description | ///
* created using current-do-file.do | $user | $S_DATE
* save "$mainFolder/appropriateFolder/data_name.dta", replace
* **********************************************************************
* Set graph and Stata preferences
    set scheme plotplain
    set more off

* Start a log file
    cap: log close
    log using "$mainFolder/code/logs/same_name_as_do_file", replace

*******************************************
* 1 - Descriptive section headers
*******************************************
* Lots of comments describing what you are doing










log close

```
