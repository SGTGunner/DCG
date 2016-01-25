/*
Author: Nicholas Clark (SENSEI)

Description:
display message

Arguments:

Return:
none
__________________________________________________________________*/
#include "script_component.hpp"

params ["_msg","_sound"];

if (CHECK_ADDON_1("ace_common")) then {
	[_msg,_sound,8,0] call ace_common_fnc_displayText;
} else {
	if (_sound) then {
		hint _msg;
	} else {
		hintSilent _msg;
	};
};
