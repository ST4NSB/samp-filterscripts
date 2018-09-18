#define FILTERSCRIPT

#include <a_samp>

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print("Loaded map_points filterscript!");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#endif

#define COLOR_GRAY 0xC0C0C0FF
#define COLOR_WHITE 0xFFFFFFFF
#define isnull(%1) \
	((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

new PlayerText:Coords[MAX_PLAYERS][8], PlayerText:Pos[MAX_PLAYERS], PlayerText:Linebars[MAX_PLAYERS][8];

stock Float: GetPlayerCameraFacingAngle(playerid)
{
    new Float: vX, Float: vY;
    if(GetPlayerCameraFrontVector(playerid, vX, vY, Float: playerid))
	{
        if((vX = -atan2(vX, vY)) < 0.0) return -vX; // + 360
        return -(vX - 360);
    }
    return 0.0;
}

forward IsInAxe(vect[3], par);
public IsInAxe(vect[3], par)
{
	switch(par)
	{
	    case 0..29: vect = "N";
	    case 30..60: vect = "NE";
	    case 61..90: vect = "E";
	    case 91..119: vect = "E";
	    case 120..150: vect = "SE";
	    case 151..180: vect = "S";
	    case 181..209: vect = "S";
	    case 210..240: vect = "SW";
	    case 241..270: vect = "W";
	    case 271..299: vect = "W";
	    case 300..330: vect = "NW";
	    case 331..360: vect = "N";
	}
}

forward ConvertToCard(vect[3], &par);
public ConvertToCard(vect[3], &par)
{
	if(!strcmp(vect, "N")) par = 0;
	if(!strcmp(vect, "NE")) par = 45;
 	if(!strcmp(vect, "E")) par = 90;
 	if(!strcmp(vect, "SE")) par = 135;
 	if(!strcmp(vect, "S")) par = 180;
 	if(!strcmp(vect, "SW")) par = 225;
 	if(!strcmp(vect, "W")) par = 270;
 	if(!strcmp(vect, "NW")) par = 315;
}

forward lowerorhigher(&par);
public lowerorhigher(&par)
{
	if(par > 360) par = par - 360;
	if(par < 0) par = 360 + par;
}

stock abs(value)
{
   return ( ( value < 0 ) ? ( value * -1 ) : ( value ) );
}

forward CreateTDPoint(playerid, PlayerText:td[MAX_PLAYERS], Float:spX, Float:spY, color);
public CreateTDPoint(playerid, PlayerText:td[MAX_PLAYERS], Float:spX, Float:spY, color)
{
    td[playerid] = CreatePlayerTextDraw(playerid,spX,spY,"");
 	PlayerTextDrawColor(playerid,td[playerid], color);
 	PlayerTextDrawFont(playerid, td[playerid], 1);
	PlayerTextDrawLetterSize(playerid, td[playerid], 0.3 ,1.2);
	PlayerTextDrawSetOutline(playerid, td[playerid], 1);
	PlayerTextDrawAlignment(playerid, td[playerid], 1);
	PlayerTextDrawSetProportional(playerid, td[playerid],1);
}

forward CreateTDMatrix(playerid, PlayerText:td[MAX_PLAYERS][8],iter, Float:spX, Float:spY, color);
public CreateTDMatrix(playerid, PlayerText:td[MAX_PLAYERS][8],iter, Float:spX, Float:spY, color)
{
    td[playerid][iter] = CreatePlayerTextDraw(playerid,spX,spY,"");
 	PlayerTextDrawColor(playerid,td[playerid][iter], color);
 	PlayerTextDrawFont(playerid, td[playerid][iter], 1);
	PlayerTextDrawLetterSize(playerid, td[playerid][iter], 0.3 ,1.2);
	PlayerTextDrawSetOutline(playerid, td[playerid][iter], 1);
	PlayerTextDrawAlignment(playerid, td[playerid][iter], 1);
	PlayerTextDrawSetProportional(playerid, td[playerid][iter],1);
}

new Float:defaultX = 300.0, Float:defaultY = 20.0, Float:distX = 30.0, Float:distY = 10.0, mcolor;
public OnPlayerConnect(playerid)
{
	mcolor = COLOR_WHITE;
	CreateTDPoint(playerid,Pos,defaultX,defaultY, mcolor);

	new j = -3;
	for(new i = 0; i < 7;i++)
	{
		if(i==0 || i==3 || i==6) mcolor = COLOR_WHITE;
		else mcolor = COLOR_GRAY;
		CreateTDMatrix(playerid,Linebars,i,defaultX + (j*distX), defaultY + distY, mcolor);
		CreateTDMatrix(playerid,Coords,i,defaultX + (j*distX), defaultY + distY*2, mcolor);
		j++;
	}
}

public OnPlayerUpdate(playerid)
{
    new Float:Angle;
    new finalang[40][8], angpos[10];
	Angle = GetPlayerCameraFacingAngle(playerid);
	new intang = floatround(Angle, floatround_round);
	new rv1, rv2;
	new aux;
	new showang[3]="", vr1[3]="" , vr2[3]="";
	
	aux = intang;
	IsInAxe(showang, aux);
	ConvertToCard(showang, rv1);
	ConvertToCard(showang, rv2);

	rv1 -= 45;
	rv2 += 45;
	lowerorhigher(rv1);
	lowerorhigher(rv2);
	
 	IsInAxe(vr1, rv1);
 	IsInAxe(vr2, rv2);

	new d1,d2, d3,d4;
	d1 = rv1 + 15;
	d2 = rv1 + 30;
	d3 = rv2 - 30;
	d4 = rv2 - 15;
	lowerorhigher(d1);
	lowerorhigher(d2);
	lowerorhigher(d3);
	lowerorhigher(d4);
 	
 	PlayerTextDrawDestroy(playerid, Pos[playerid]);
 	
 	new Float:coordPos = defaultX;
 	if(aux >= d1 && aux < d2)
 	    coordPos = defaultX - distX*2;
	else if(aux >= d2 && aux < d2+15)
	    coordPos = defaultX - distX;
	else if(aux >= d2+15 && aux < d3)
	    coordPos = defaultX;
	else if(aux >= d3 && aux < d4)
	    coordPos = defaultX + distX;
/*
	else if(aux >= 0 && aux < 15)
	    coordPos = defaultX;
	else if(aux == 360)
	    coordPos = defaultX;*/
    CreateTDPoint(playerid,Pos,coordPos,defaultY, COLOR_WHITE);
 	
	format(angpos, sizeof(angpos), "%d", aux);
 	PlayerTextDrawSetString(playerid, Pos[playerid], angpos);
 	PlayerTextDrawShow(playerid, Pos[playerid]);
 	
	format(finalang[0], sizeof(finalang[]), "%s",vr1);
 	format(finalang[1], sizeof(finalang[]), "%d",d1);
 	format(finalang[2], sizeof(finalang[]), "%d",d2);
 	format(finalang[3], sizeof(finalang[]), "%s",showang);
 	format(finalang[4], sizeof(finalang[]), "%d",d3);
 	format(finalang[5], sizeof(finalang[]), "%d",d4);
 	format(finalang[6], sizeof(finalang[]), "%s",vr2);
 	
 	for(new i=0;i<7;i++)
 	{
 	    PlayerTextDrawSetString(playerid, Linebars[playerid][i], "I");
 		PlayerTextDrawShow(playerid, Linebars[playerid][i]);
 		
 		PlayerTextDrawSetString(playerid, Coords[playerid][i], finalang[i]);
 		PlayerTextDrawShow(playerid, Coords[playerid][i]);
 	}
 	

	return 1;
}
