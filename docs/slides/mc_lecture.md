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
```

**This is new; shows where you would add the names of user-installed packages (with an example)**

```Stata
    * for packages, make a local with the packages
    local userpack "winsor2"
 ```
 
```Stata 
* TO DO:
    * You can add next steps here if useful (or things that need to be done before code is useful)

* **********************************************************************
* 0 - General setup
* **********************************************************************
* Users can change these two filepaths
* All subsequent files are referred to using dynamic, absolute filepaths
    global myDocs "N:/users/tjernstroem"
    global mainFolder "$myDocs/PA881/stata"
```

**...then this is the code to actually check if the user has the required package**

```Stata
* Check if the required packages are installed:
    foreach package in `userpack' {
        capture : which `package'
        if (_rc) {
            display as result in smcl `"Please install package {it:`package'} from SSC in order to run this do-file."' _newline `"You can do so by clicking this link: {stata "ssc install `package'":auto-install `package'}"'
            exit 199
        }
    }
```
