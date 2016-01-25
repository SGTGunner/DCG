/*
Author: Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"
#define ZDIST 65
#define EXPRESSIONS [["(1 - forest) * (2 + meadow) * (1 - sea) * (1 - houses) * (1 - hills)","meadow"],["(2 + forest) * (1 - sea) * (1 - houses)","forest"],["(2 + hills) * (1 - sea)","hills"],["(2 + houses) * (1 - sea)","houses"]]
#define THRESHOLD ceil(EGVAR(main,range)*0.002)

if !(isServer) exitWith {};

if (GVAR(enable) isEqualTo 0) exitWith {
	LOG_DEBUG("Addon is disabled.");
};

[{
	if (DOUBLES(PREFIX,main)) exitWith {
		[_this select 1] call CBA_fnc_removePerFrameHandler;

		_locations = [];
		{
			if !(CHECK_DIST2D((_x select 1),locationPosition EGVAR(main,mobLocation),EGVAR(main,mobRadius))) then {
				_locations pushBack _x;
			};
			false
		} count EGVAR(main,locations);

		if (CHECK_DEBUG) then {
			private "_mrk";
			{
				LOG_DEBUG_1("%1 initialized.", _x select 0);
				_mrk = createMarker [format["%1_%2",QUOTE(ADDON),_x select 0],_x select 1];
				_mrk setMarkerColor "ColorCivilian";
				_mrk setMarkerShape "ELLIPSE";
				_mrk setMarkerBrush "SolidBorder";
				_mrk setMarkerAlpha 0.5;
				_mrk setMarkerSize [GVAR(spawnDist),GVAR(spawnDist)];
			} forEach _locations;
		};

		[{
			params ["_args","_idPFH"];
			_args params ["_locations"];
			{
				if !(missionNamespace getVariable [format ["%1_%2", QUOTE(ADDON),_x select 0],false]) then {
					private ["_position","_unitCount","_vehCount"];
					_position = _x select 1;
					_position = ASLToAGL _position;
					if ({((vehicle _x) distance _position < GVAR(spawnDist) && {((getPos (vehicle _x)) select 2) < ZDIST})} count allPlayers > 0) then {
						call {
							if ((_x select 3) isEqualTo "NameCityCapital") exitWith {
								_unitCount = ceil(GVAR(count));
								_vehCount = ceil(GVAR(vehCount));
							};
							if ((_x select 3) isEqualTo "NameCity") exitWith {
								_unitCount = ceil(GVAR(count)*GVAR(cityMultiplier));
								_vehCount = ceil(GVAR(vehCount)*GVAR(cityMultiplier));
							};
							_unitCount = ceil(GVAR(count)*GVAR(townMultiplier));
							_vehCount = ceil(GVAR(vehCount)*GVAR(townMultiplier));
						};
						[_position,_unitCount,_vehCount,_x select 0] spawn FUNC(spawn);
					};
				};
			} forEach _locations;
		}, 10, [_locations]] call CBA_fnc_addPerFrameHandler;

		_posArray = [];
		[{
			params ["_args","_idPFH"];
			_args params ["_posArray"];

			if (count _posArray > THRESHOLD) exitWith {
				[_idPFH] call CBA_fnc_removePerFrameHandler;
				if (CHECK_DEBUG) then {
					{
						_pos = _x select 0;
						_mrk = createMarker [format["%1_animal_%2",QUOTE(ADDON),_pos],_pos];
						_mrk setMarkerColor "ColorBlack";
						_mrk setMarkerShape "ELLIPSE";
						_mrk setMarkerBrush "SolidBorder";
						_mrk setMarkerAlpha 0.5;
						_mrk setMarkerSize [GVAR(spawnDist),GVAR(spawnDist)];
					} forEach _posArray;
				};
				[{
					params ["_args","_idPFH"];
					_args params ["_posArray"];

					{
						if !(missionNamespace getVariable [format ["%1_%2", QUOTE(ADDON),_x select 0],false]) then {
							_pos = _x select 0;
							_str = _x select 1;

							if ({((vehicle _x) distance _pos < GVAR(spawnDist) && {((getPosATL (vehicle _x)) select 2) < ZDIST})} count allPlayers > 0) then {
								[_pos,_str,GVAR(spawnDist)] spawn FUNC(spawnAnimal);
							};
						};
					} forEach _posArray;
				}, 10, [_posArray]] call CBA_fnc_addPerFrameHandler;
			};

			_selected = EXPRESSIONS select floor (random (count EXPRESSIONS));
			_expression = _selected select 0;
			_str = _selected select 1;
			_pos = [EGVAR(main,center),0,EGVAR(main,range)] call EFUNC(main,findRandomPos);
			_ret = selectBestPlaces [_pos,5000,_expression,70,1];
			if (!(_ret isEqualTo []) && {!(CHECK_DIST2D((_ret select 0 select 0),locationPosition EGVAR(main,mobLocation),EGVAR(main,mobRadius)))} && {!(surfaceIsWater(_ret select 0 select 0))} && {{CHECK_DIST2D((_ret select 0 select 0),(_x select 0),GVAR(spawnDist))} count _posArray isEqualTo 0}) then {
				_posArray pushBack [_ret select 0 select 0,_str];
			};
		}, 0.1, [_posArray]] call CBA_fnc_addPerFrameHandler;
	};
}, 0, []] call CBA_fnc_addPerFrameHandler;

ADDON = true;