/*
Author:
Nicholas Clark (SENSEI)

Description:
handle client setup

Arguments:

Return:
nothing
__________________________________________________________________*/
#include "script_component.hpp"
#include "\a3\editor_f\Data\Scripts\dikCodes.h"

if (!hasInterface) exitWith {};

{
    _x call EFUNC(main,setAction);
} forEach [
    [QGVARMAIN(actions),format["%1 Actions",toUpper QUOTE(PREFIX)],{},{true},{},[],player,1,["ACE_SelfActions"]],
    [QGVARMAIN(data),"Mission Data"],
    [QGVAR(saveData),SAVE_ACTION_NAME,{SAVE_ACTION_STATEMENT},{SAVE_ACTION_COND},{},[],player,1,["ACE_SelfActions",QGVARMAIN(actions),QGVARMAIN(data)]],
    [QGVAR(deleteSaveData),SAVE_ACTION_NAME_DELETE,{SAVE_ACTION_STATEMENT_DELETE},{SAVE_ACTION_COND_DELETE},{},[],player,1,["ACE_SelfActions",QGVARMAIN(actions),QGVARMAIN(data)]]
];

nil