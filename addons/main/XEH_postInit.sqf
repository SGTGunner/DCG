/*
Author:
Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"

CHECK_POSTINIT;

// get map locations from config
_cfgLocations = configFile >> "CfgWorlds" >> worldName >> "Names";
_typeLocations = ["namecitycapital","namecity","namevillage"];
_typeLocals = ["namelocal"];
_typeHills = ["hill"];
_typeMarines = ["namemarine"];

for "_i" from 0 to (count _cfgLocations) - 1 do {
	_location = _cfgLocations select _i;
	_type = getText (_location >> "type");
	_name = getText (_location >> "name");
	_position = getArray (_location >> "position");
	_position set [2,(getTerrainHeightASL _position) max 0];
	_size = ((getNumber (_location >> "radiusA")) + (getNumber (_location >> "radiusB")))*0.5;

	call {
		if (toLower _type in _typeLocations) exitWith {
			if ({COMPARE_STR(_x,_name)} count GVAR(blacklistLocations) isEqualTo 0 && {!(_name isEqualTo "")}) then {
				GVAR(locations) pushBack [_name,_position,_size,_type];
			};
		};
		if (toLower _type in _typeLocals) exitWith {
			if !(_name isEqualTo "") then {
				GVAR(locals) pushBack [_name,_position,_size];
			};
		};
		if (toLower _type in _typeHills) exitWith {
			GVAR(hills) pushBack [_position,_size];
		};
		if (toLower _type in _typeMarines) exitWith {
			if !(_name isEqualTo "") then {
				GVAR(marines) pushBack [_name,_position,_size];
			};
		};
	};
};

{
	// update locations with center positions if available
	_nameNoSpace = (_x select 0) splitString " " joinString "";
	_cityCenterA2 = _cfgLocations >> ("ACityC_" + _nameNoSpace);
	_cityCenterA3 = _cfgLocations >> ("CityC_" + _nameNoSpace);

	if (isClass _cityCenterA2) then {
		_position = getArray (_cityCenterA2 >> "position");
		_position set [2,(getTerrainHeightASL _position) max 0];
		_x set [1,_position];
	};
	if (isClass _cityCenterA3) then {
		_position = getArray (_cityCenterA3 >> "position");
		_position set [2,(getTerrainHeightASL _position) max 0];
		_x set [1,_position];
	};

	// update locations with safe positions
	if !([_x select 1,2,0] call FUNC(isPosSafe)) then {
		_places = selectBestPlaces [_x select 1, _x select 2, "(1 + houses) * (1 - sea)", 35, 4];
		_places = _places select {(_x select 1) > 0 && {[_x select 0,2,0] call FUNC(isPosSafe)}};

		if !(_places isEqualTo []) then {
			_position = (selectRandom _places) select 0;
			_position set [2,(getTerrainHeightASL _position) max 0];
			_x set [1,_position];
		};
	};

	false
} count GVAR(locations);

// create world size position grid
GVAR(grid) = [EGVAR(main,center),1000,worldSize,0,0,0] call FUNC(findPosGrid);

//[FUNC(handleSafezone), 60, []] call CBA_fnc_addPerFrameHandler;
[FUNC(handleCleanup), 120, []] call CBA_fnc_addPerFrameHandler;

if !(isNil {HEADLESSCLIENT}) then {
	[{
		{
			deleteGroup _x; // will only delete local empty groups
		} forEach allGroups;
	}, 120, []] remoteExecCall [QUOTE(CBA_fnc_addPerFrameHandler),owner HEADLESSCLIENT,false];
};

// save functionality
if (GVAR(autoSave)) then {
    [{
        call FUNC(saveData);
    }, 1800, []] call CBA_fnc_addPerFrameHandler;
};

DATA_SAVEPVEH addPublicVariableEventHandler {
	call FUNC(saveData);
};

DATA_DELETEPVEH addPublicVariableEventHandler {
	profileNamespace setVariable [DATA_SAVEVAR,nil];
	saveProfileNamespace;
};

// load data
_data = QUOTE(ADDON) call FUNC(loadDataAddon);
[_data] call FUNC(handleLoadData);

// set client actions
[[],{
	if (hasInterface) then {
        {
            _x call EFUNC(main,setAction);
        } forEach [
            [QUOTE(DOUBLES(PREFIX,actions)),format["%1 Actions",toUpper QUOTE(PREFIX)],{},{true},{},[],player,1,["ACE_SelfActions"]],
            [QUOTE(DOUBLES(PREFIX,data)),"Mission Data"],
            [SAVEDATA_ID,SAVEDATA_NAME,{SAVEDATA_STATEMENT},{SAVEDATA_COND},{},[],player,1,["ACE_SelfActions",QUOTE(DOUBLES(PREFIX,actions)),QUOTE(DOUBLES(PREFIX,data))]],
            [DELETEDATA_ID,DELETEDATA_NAME,{DELETEDATA_STATEMENT},{DELETEDATA_COND},{},[],player,1,["ACE_SelfActions",QUOTE(DOUBLES(PREFIX,actions)),QUOTE(DOUBLES(PREFIX,data))]]
        ];
	};
}] remoteExecCall [QUOTE(BIS_fnc_call), 0, true];

ADDON = true;
publicVariable QUOTE(ADDON);