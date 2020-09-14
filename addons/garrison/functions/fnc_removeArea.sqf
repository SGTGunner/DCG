/*
Author:
Nicholas Clark (SENSEI)

Description:
remove area of operations on server

Arguments:

Return:
nothing
__________________________________________________________________*/
#include "script_component.hpp"

if !(isServer) exitWith {};

params [
    ["_key","",[""]],
    ["_value",locationNull,[locationNull]]
];

// remove units
[QEGVAR(main,cleanup),_value getVariable [QGVAR(groups),[]]] call CBA_fnc_localEvent;

// remove map polygons
[
    [],
    {
        {
            (findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["Draw",_x];
        } forEach GVAR(polygonDraw);
    }
] remoteExecCall [QUOTE(call),0,false];

// remove tasks
[_value getVariable [QGVAR(task),""],true] call BIS_fnc_deleteTask;

// reset score
GVAR(score) = 0;

INFO_1("removed area: %1",_key);

_value call CBA_fnc_deleteEntity;

nil