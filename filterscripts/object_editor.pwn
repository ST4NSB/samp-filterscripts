#define FILTERSCRIPT

#include <a_samp>

#define DIALOG_CREATE_OBJECT 1
#define DIALOG_DELETE_OBJECT 2
#define DIALOG_CHANGE_POS_SPEED 3
#define DIALOG_CHANGE_ROT_SPEED 4

#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED 0xFF0000FF
#define COLOR_LIGHTBLUE 0x00FFFFFF
#define COLOR_GREEN 0x00FF00FF
#define COLOR_ORANGE 0xFF9900FF
#define COLOR_LIME 0x00FFCCFF
#define COLOR_TEAL 0x00CCCCFF

new pObject[MAX_PLAYERS][512];
new bool:objectCreated[MAX_PLAYERS] = false;
new objectId[MAX_PLAYERS] = 0;
new objectModelId[512];
new Float:objectDetails[512][6];
new objectEditState = 0;
new bool:canEditObject = false;

new Text:tdPos[3];
new Text:tdRot[3];
new Text:tdSpeed[2];

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print("Loaded Object-SAMP-Editor filterscript!");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#endif

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/createobject", cmdtext, true, 10) == 0 || strcmp("/co", cmdtext, true, 10) == 0)
	{
		if(objectCreated[playerid])
		    return SendClientMessage(playerid, COLOR_RED, "Finish editing your object first!");
	    ShowPlayerDialog(playerid, DIALOG_CREATE_OBJECT, DIALOG_STYLE_INPUT, "Object ID", "{FFFFFF}You can use: {FF0000}https://dev.prineside.com/en/gtasa_samp_model_id/{FFFFFF} for object ideas\n\tType the Object ID below: ", "Ok", "Cancel");
		return 1;
	}
	if (strcmp("/changepositionspeed", cmdtext, true, 10) == 0 || strcmp("/cps", cmdtext, true, 10) == 0)
	{
		if(!objectCreated[playerid])
		    return SendClientMessage(playerid, COLOR_RED, "Create an object first!");
	    ShowPlayerDialog(playerid, DIALOG_CHANGE_POS_SPEED, DIALOG_STYLE_INPUT, "Object ID", "{FFFFFF}Type-in the number below (pref. float): ", "Ok", "Cancel");
		return 1;
	}
	if (strcmp("/changerotationspeed", cmdtext, true, 10) == 0 || strcmp("/crs", cmdtext, true, 10) == 0)
	{
		if(!objectCreated[playerid])
		    return SendClientMessage(playerid, COLOR_RED, "Create an object first!");
	    ShowPlayerDialog(playerid, DIALOG_CHANGE_ROT_SPEED, DIALOG_STYLE_INPUT, "Object ID", "{FFFFFF}Type-in the number below (pref. float): ", "Ok", "Cancel");
		return 1;
	}
	if(strcmp("/deleteobject", cmdtext, true, 10) == 0 || strcmp("/do", cmdtext, true, 10) == 0)
	{
		if(objectId[playerid] == 0)
		    return SendClientMessage(playerid, COLOR_RED, "There is no object created or finished to delete!");
		if(objectCreated[playerid])
		    return SendClientMessage(playerid, COLOR_RED, "End editing your object via /endedit (/ee)!");
		new outp[256], aux[100];
		for(new i = 0; i < objectId[playerid]; i++)
		{
		    format(aux, sizeof(aux), "{FFFFFF}%d. ID: %d\n", i, objectModelId[i]);
		    strcat(outp, aux);
		}
        ShowPlayerDialog(playerid, DIALOG_DELETE_OBJECT, DIALOG_STYLE_LIST, "Object ID's", outp, "Delete", "Cancel");
	    return 1;
	}
	if (strcmp("/endedit", cmdtext, true, 10) == 0 || strcmp("/ee", cmdtext, true, 10) == 0)
	{
	    if(!objectCreated[playerid])
	        return SendClientMessage(playerid, COLOR_RED, "You aren't editing any object!");
	    objectCreated[playerid] = false;
	    canEditObject = false;

	    for(new i = 0; i < 3; i++)
	    {
	   		TextDrawDestroy(tdPos[i]);
	   		TextDrawDestroy(tdRot[i]);
	   		if(i < 2)
	   			TextDrawDestroy(tdSpeed[i]);
   	 	}

		new Float:x, Float:y, Float:z;
		GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], x, y, z);
		new Float:RotX,Float:RotY,Float:RotZ;
		GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], RotX, RotY, RotZ);

		objectDetails[objectId[playerid]][0] = x;
		objectDetails[objectId[playerid]][1] = y;
		objectDetails[objectId[playerid]][2] = z;
		objectDetails[objectId[playerid]][3] = RotX;
		objectDetails[objectId[playerid]][4] = RotY;
		objectDetails[objectId[playerid]][5] = RotZ;

		objectId[playerid]++;

		SendClientMessage(playerid, COLOR_WHITE, "You finished your edit! Type /createobject (/co) to create another object!\n");
		SendClientMessage(playerid, COLOR_WHITE, "Type /showcode (/sc) to get all the code for your objects!");
		return 1;
	}
	if(strcmp("/showcode", cmdtext, true, 10) == 0 || strcmp("/sc", cmdtext, true, 10) == 0)
	{
		if(objectId[playerid] == 0)
		    return SendClientMessage(playerid, COLOR_RED, "You didn't create any object or didn't finish editing!");
        if(objectCreated[playerid])
	        return SendClientMessage(playerid, COLOR_RED, "Finish editing your object via /endedit (/ee)");

		SendClientMessage(playerid, COLOR_WHITE, "");
		SendClientMessage(playerid, COLOR_LIGHTBLUE, "//Map edited via Object SA:MP Editor filterscript!");
	    for(new iter = 0; iter < objectId[playerid]; iter++)
	    {
	        new output[256], aux[100];
			strcat(output, "CreateObject(");
			format(aux, sizeof(aux), "%d, ", objectModelId[iter]);
			strcat(output, aux);
			for(new i = 0; i < 5; i++)
			{
			    format(aux, sizeof(aux), "%f, ", objectDetails[iter][i]);
				strcat(output, aux);
			}
			format(aux, sizeof(aux), "%f); //%d\n", objectDetails[iter][5], iter);
			strcat(output, aux);

			SendClientMessage(playerid, COLOR_LIGHTBLUE, output);
	    }
	    return 1;
	}
	return 0;
}

#define PRESSING(%0,%1) \
	(%0 & (%1))
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
new Float:speed = 0.05;
new Float:rotation = 1.0;
new Float:px, Float:py, Float:pz;
new zKeyTimer[MAX_PLAYERS];

forward changeTDString(playerid);
public changeTDString(playerid)
{
    new Float:posx, Float:posy, Float:posz;
	new Float:rotx, Float:roty, Float:rotz;
	GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], posx, posy, posz);
	GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rotx, roty, rotz);
	new outpx[256], outpy[256], outpz[256];
	new outrx[256], outry[256], outrz[256];
	new outpspeed[256], outrspeed[256];
	format(outpx, sizeof(outpx), "Pos X: %f", posx);
	format(outpy, sizeof(outpy), "Pos Y: %f", posy);
	format(outpz, sizeof(outpz), "Pos Z: %f", posz);
	format(outrx, sizeof(outrx), "Rot X: %f", rotx);
	format(outry, sizeof(outry), "Rot Y: %f", roty);
	format(outrz, sizeof(outrz), "Rot Z: %f", rotz);
	format(outpspeed, sizeof(outpspeed), "Pos Speed: %f", speed);
	format(outrspeed, sizeof(outrspeed), "Rot Speed: %f", rotation);
	TextDrawSetString(tdPos[0], outpx);
	TextDrawSetString(tdPos[1], outpy);
	TextDrawSetString(tdPos[2], outpz);
	TextDrawSetString(tdRot[0], outrx);
	TextDrawSetString(tdRot[1], outry);
	TextDrawSetString(tdRot[2], outrz);
	TextDrawSetString(tdSpeed[0], outpspeed);
	TextDrawSetString(tdSpeed[1], outrspeed);
}

forward editAxisZPlus(playerid);
public editAxisZPlus(playerid)
{
	changeTDString(playerid);
	if(objectCreated[playerid] && canEditObject)
	{
		if(objectEditState % 2 == 0)
	 	{
			        new Float:x, Float:y, Float:z;
			        GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], x, y, z);
					z+=speed;
					SetPlayerObjectPos(playerid,pObject[playerid][objectId[playerid]],x,y,z);
					SetPlayerPos(playerid, px, py, pz);
		}
		else
		{
				    new Float:rx, Float:ry, Float:rz;
				    GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
	   				rz+=rotation;
				    SetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
				    SetPlayerPos(playerid, px, py, pz);
		}
	}
}

forward editAxisZMinus(playerid);
public editAxisZMinus(playerid)
{
    changeTDString(playerid);
	if(objectCreated[playerid] && canEditObject)
	{
		if(objectEditState % 2 == 0)
	 	{
			        new Float:x, Float:y, Float:z;
			        GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], x, y, z);
					z-=speed;
					SetPlayerObjectPos(playerid,pObject[playerid][objectId[playerid]],x,y,z);
					SetPlayerPos(playerid, px, py, pz);
		}
		else
		{
				    new Float:rx, Float:ry, Float:rz;
				    GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
	   				rz-=rotation;
				    SetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
				    SetPlayerPos(playerid, px, py, pz);
		}
	}
}

new bool:keyPressure = false;
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(objectCreated[playerid])
	{
	    if(PRESSING( newkeys, KEY_CROUCH ))
	    {
			canEditObject = !canEditObject;
			KillTimer(zKeyTimer[playerid]);
			if(canEditObject)
			{
				SendClientMessage(playerid, COLOR_WHITE, "You can edit your object with controls!");
				GetPlayerPos(playerid,px,py,pz);
			}
			else SendClientMessage(playerid, COLOR_WHITE, "You are in look out mode! Press crouch to enable edit mode or /endedit (/ee) to finish editing!");
	    }
	    if(PRESSING( newkeys, KEY_SECONDARY_ATTACK ))
	    {
	    	objectEditState++;
	    	KillTimer(zKeyTimer[playerid]);
	    	if(objectEditState % 2 == 0)
	    	    SendClientMessage(playerid, COLOR_WHITE, "Object: {FF0000}MOVEMENT");
			else SendClientMessage(playerid, COLOR_WHITE, "Object: {FF0000}ROTATION");
	    }
	    if(HOLDING( KEY_FIRE ) && canEditObject && !keyPressure)
	    {
	        keyPressure = true;
	        zKeyTimer[playerid] = SetTimer("editAxisZPlus", 60, true);
	    }
	    if(HOLDING( KEY_HANDBRAKE ) && canEditObject && !keyPressure)
	    {
	        keyPressure = true;
			zKeyTimer[playerid] = SetTimer("editAxisZMinus", 60, true);
	    }
	    if(PRESSING( newkeys, KEY_FIRE ) && canEditObject)
			editAxisZPlus(playerid);
        if(PRESSING( newkeys, KEY_HANDBRAKE ) && canEditObject)
			editAxisZMinus(playerid);
	    if (RELEASED( KEY_FIRE ) && keyPressure)
	    {
			keyPressure = false;
	        KillTimer(zKeyTimer[playerid]);
		}
	    if (RELEASED( KEY_HANDBRAKE ) && keyPressure)
	    {
	        keyPressure = false;
	       	KillTimer(zKeyTimer[playerid]);
		}
    }
	return 1;
}

public OnPlayerUpdate(playerid)
{
    new Keys,ud,lr;
    GetPlayerKeys(playerid,Keys,ud,lr);
    if(objectCreated[playerid])
    {
        changeTDString(playerid);
        for(new i = 0; i < 3; i++)
        {
            TextDrawShowForPlayer(playerid, tdPos[i]);
            TextDrawShowForPlayer(playerid, tdRot[i]);
            if(i < 2)
                TextDrawShowForPlayer(playerid, tdSpeed[i]);
        }
        if(ud == KEY_UP && canEditObject)
        {
            if(objectEditState % 2 == 0)
            {
	            new Float:x, Float:y, Float:z;
		        GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], x, y, z);
				x+=speed;
		        SetPlayerObjectPos(playerid,pObject[playerid][objectId[playerid]],x,y,z);
		        SetPlayerPos(playerid, px, py, pz);
	        }
			else
			{
			    new Float:rx, Float:ry, Float:rz;
			    GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
			    rx+=rotation;
			    SetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
			    SetPlayerPos(playerid, px, py, pz);
			}
        }
        else if(ud == KEY_DOWN && canEditObject)
        {
            if(objectEditState % 2 == 0)
            {
	            new Float:x, Float:y, Float:z;
		        GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], x, y, z);
				x-=speed;
		        SetPlayerObjectPos(playerid,pObject[playerid][objectId[playerid]],x,y,z);
		        SetPlayerPos(playerid, px, py, pz);
	        }
	        else
			{
			    new Float:rx, Float:ry, Float:rz;
			    GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
			    rx-=rotation;
			    SetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
			    SetPlayerPos(playerid, px, py, pz);
			}
        }
		if(lr == KEY_LEFT && canEditObject)
		{
            if(objectEditState % 2 == 0)
            {
			    new Float:x, Float:y, Float:z;
		        GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], x, y, z);
				y+=speed;
		        SetPlayerObjectPos(playerid,pObject[playerid][objectId[playerid]],x,y,z);
		        SetPlayerPos(playerid, px, py, pz);
			}
			else
			{
			    new Float:rx, Float:ry, Float:rz;
			    GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
   				ry+=rotation;
			    SetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
			    SetPlayerPos(playerid, px, py, pz);
			}
		}
		else if(lr == KEY_RIGHT && canEditObject)
		{
		    if(objectEditState % 2 == 0)
            {
			    new Float:x, Float:y, Float:z;
		        GetPlayerObjectPos(playerid, pObject[playerid][objectId[playerid]], x, y, z);
				y-=speed;
		        SetPlayerObjectPos(playerid,pObject[playerid][objectId[playerid]],x,y,z);
		        SetPlayerPos(playerid, px, py, pz);
	        }
	        else
			{
			    new Float:rx, Float:ry, Float:rz;
			    GetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
   				ry-=rotation;
			    SetPlayerObjectRot(playerid, pObject[playerid][objectId[playerid]], rx, ry, rz);
			    SetPlayerPos(playerid, px, py, pz);
			}
		}
	}
	return 1;
}

IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

stock IsFloat(const string[])
{
    new possiblefloat = 0;
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0')
        {
            if(string[i] != '.')
                return 0;
            else
                possiblefloat = 1;
        }
    }
    if(possiblefloat == 1)
        return 2;
    else
        return 1;
}

forward editTextDraw(Text:td[3], id, tdtype);
public editTextDraw(Text:td[3], id, tdtype)
{
	if(tdtype == 0)
    	TextDrawColor(td[id], COLOR_LIGHTBLUE);
	else if(tdtype == 1)
		TextDrawColor(td[id], COLOR_LIME);
	else if(tdtype == 2)
		TextDrawColor(td[id], COLOR_TEAL);
	TextDrawFont(td[id], 1);
	TextDrawSetShadow(td[id], 0);
	TextDrawSetOutline(td[id], 1);
	TextDrawLetterSize(td[id], 0.25, 0.76);
}

forward editTextDrawSpeed(Text:td[2], id);
public editTextDrawSpeed(Text:td[2], id)
{
	TextDrawColor(td[id], COLOR_TEAL);
	TextDrawFont(td[id], 1);
	TextDrawSetShadow(td[id], 0);
	TextDrawSetOutline(td[id], 1);
	TextDrawLetterSize(td[id], 0.25, 0.76);
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_CREATE_OBJECT)
	{
		if(response)
		{
			if(!IsNumeric(inputtext))
			    return SendClientMessage(playerid, COLOR_RED, "Your input is not a number!");

			objectCreated[playerid] = true;
			canEditObject = true;
			new modelid = strval(inputtext);


		    new Float:x, Float:y, Float:z;
		    new Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0;
			GetPlayerPos(playerid, x, y, z);

			pObject[playerid][objectId[playerid]] = CreatePlayerObject(playerid, modelid, x + 3.0, y, z, rx, ry, rz);
			objectModelId[objectId[playerid]] = modelid;


			objectEditState = 0;
			SendClientMessage(playerid, COLOR_WHITE, "Object: {FF0000}MOVEMENT");
			SendClientMessage(playerid, COLOR_WHITE, "Type /endedit (/ee) to finish editing the current object!");
			GetPlayerPos(playerid,px,py,pz);

			new Float:startX = 15.0, Float:startY = 180.0, Float:dist = 8.5;
			for(new i = 0; i < 3; i++)
			{
			    tdPos[i] = TextDrawCreate(startX,startY + i*dist,"");
			    editTextDraw(tdPos, i, 0);
			}
			startY = startY + 3*dist;
			for(new i = 0; i < 3; i++)
			{
			    tdRot[i] = TextDrawCreate(startX,startY + i*dist,"");
			    editTextDraw(tdRot, i, 1);
			}
			startY = startY + 4*dist;
			for(new i = 0; i < 2; i++)
			{
			    tdSpeed[i] = TextDrawCreate(startX,startY + i*dist,"");
			    editTextDrawSpeed(tdSpeed, i);
			}
		}
	}
	if(dialogid == DIALOG_DELETE_OBJECT)
	{
		if(response)
		{
			DestroyPlayerObject(playerid, pObject[playerid][listitem]);
			for(new i = listitem; i < objectId[playerid] - 1; i++)
			{
			    pObject[playerid][i] = pObject[playerid][i+1];
                objectModelId[i] = objectModelId[i+1];
                objectDetails[i] = objectDetails[i+1];
			}
			objectId[playerid]--;
			new outp[256];
			format(outp, sizeof(outp), "You deleted an object {FF0000}(ID: %d)", listitem);
			SendClientMessage(playerid, COLOR_WHITE, outp);
		}
	}
	if(dialogid == DIALOG_CHANGE_POS_SPEED)
	{
	    if(response)
	    {
			if(!IsFloat(inputtext))
			    return SendClientMessage(playerid, COLOR_RED, "Your input is not a number!");
            new Float:input = floatstr(inputtext);
			speed = input;
	    }
	}
	if(dialogid == DIALOG_CHANGE_ROT_SPEED)
	{
	    if(response)
	    {
			if(!IsFloat(inputtext))
			    return SendClientMessage(playerid, COLOR_RED, "Your input is not a number!");
            new Float:input = floatstr(inputtext);
			rotation = input;
	    }
	}
	return 1;
}
