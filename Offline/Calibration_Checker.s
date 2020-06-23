void unit_find(string name, string SIUnit, number calib, number raw){
	number scale = calib/raw
	string units = ""
	if(scale <= 10**-10){
		units = "Angstrom/10**-9"
	}
	else if(scale <= 10**-9){
		units = "n"
	}
	else if(scale <= 10**-6){
		units = "u"
	}
	else if(scale <= 10**-3){
		units = "m"
	}
	else if(scale <= 10**-2){
		units = "c"
	}
	else if(scale <= 10**-1){
		units = "d"
	}
	else if(scale <= 10**0){
		units = ""
	}
	else if(scale <= 10**1){
		units = "da"
	}
	else if(scale <= 10**2){
		units = "h"
	}
	else if(scale <= 10**3){
		units = "k"
	}
	else if(scale <= 10**6){
		units = "M"
	}
	else if(scale <= 10**9){
		units = "G"
	}
	
	result(name + " is calibrated in units of " + units + SIUnit)
}

number calibFocus = EMGetCalibratedFocus( )
number rawFocus = EMgetFocus()

unit_find("Focus","m",calibFocus,rawFocus)

okdialog("Refer to Output window for results!\nEdit code for other calibrated units, if needed.")