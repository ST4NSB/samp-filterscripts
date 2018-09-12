#define FILTERSCRIPT

#include <a_samp>

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print("Loaded pong_minigame filterscript!");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

main()
{}

#endif




public OnGameModeInit()
{
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

#define white 0xFFFFFFFF
#define black 0x000000FF
#define grey 0xAFAFAFAA
#define ni 20
#define nj 40
new const Float:di = 6.5, Float:dj = 5.6;
new const Float:startX = 200.0, Float:startY = 150.0;
new const speed = 75;

new gameTimer[MAX_PLAYERS];
new Text:pongBoard[ni][nj];
new Text:score;
new bool:drawingCompleted = false;
new realBoard[ni][nj];
new direction, trajectory, balli, ballj;
new scorep1 = 0, scorep2 = 0;


forward changeColorTD(playerid, Text:pixel[][], color, i, j);
public changeColorTD(playerid, Text:pixel[][], color, i, j)
{
    TextDrawHideForPlayer(playerid, pixel[i][j]);
    TextDrawColor(pixel[i][j], color);
	TextDrawBoxColor(pixel[i][j], color);
	TextDrawBackgroundColor(pixel[i][j], color);
	TextDrawShowForPlayer(playerid, pixel[i][j]);
	
	if(color == black)
	    realBoard[i][j] = 0;
	else realBoard[i][j] = 1;
}

forward setDefault(playerid,Text:pixel[][], i, j);
public setDefault(playerid,Text:pixel[][], i, j)
{
    TextDrawUseBox(pixel[i][j], 1); // Toggle box ON
	TextDrawSetProportional(pixel[i][j],1);
	changeColorTD(playerid,pixel, black,i,j);
	TextDrawAlignment(pixel[i][j], 2);
	TextDrawTextSize(pixel[i][j], 3.0, 3.0);
	TextDrawLetterSize(pixel[i][j], 0.1 ,0.4);
}

forward draw(playerid, Text:pixel[][]);
public draw(playerid, Text:pixel[][])
{
	changeColorTD(playerid, pixel, white, 9, 0);
	changeColorTD(playerid, pixel, white, 10, 0);
	changeColorTD(playerid, pixel, white, 11, 0);
	
	changeColorTD(playerid, pixel, white, 9, nj-1);
	changeColorTD(playerid, pixel, white, 10, nj-1);
 	changeColorTD(playerid, pixel, white, 11, nj-1);
 	
	changeColorTD(playerid, pixel, white, 10, nj/2);
	balli = 10; ballj = nj/2;
	drawingCompleted = true;
}

forward gameUpdate(playerid);
public gameUpdate(playerid)
{
    changeColorTD(playerid, pongBoard, black, balli, ballj);
	if(direction == 0 && trajectory == 0) {
		balli--;
		ballj--;
	}
	else if(direction == 0 && trajectory == 1)
	{
	    balli++;
	    ballj--;
	}
	else if(direction == 1 && trajectory == 0) {
	    balli--;
	    ballj++;
	}
	else if(direction == 1 && trajectory == 1) {
		balli++;
		ballj++;
	}
	if(balli < 0) {
		balli = 1;
		trajectory = 1;
	}
	if(balli >= ni) {
		balli = ni-2;
		trajectory = 0;
	}
	
	new bool:dothis = true;
	if(ballj <= 0) {
		if(realBoard[balli][0] == 1) {
			ballj = 2;
			direction = 1;
		}
		else {
			scorep2++;
			getScore();
			balli = 10; ballj = nj/2;
			direction = random(2);
			trajectory = random(2);
			dothis = false;
		}
	}
	if(ballj >= nj-1) {
	    if(realBoard[balli][nj-1] == 1) {
			ballj = nj-3;
			direction = 0;
		}
		else {
		    scorep1++;
		    getScore();
		    balli = 10; ballj = nj/2;
			direction = random(2);
			trajectory = random(2);
			dothis = false;
		}
	}
	if(dothis) changeColorTD(playerid, pongBoard, white, balli, ballj);
	
	// ai

	new chance = random(2); // 1/2
	if(chance == 1) {
	    new ballfound = balli;
	    new keyfoundup = -1, keyfounddown = -1;
	    for(new i=ni-1;i>0;i--)
	        if(realBoard[i][nj-1] == 1)
				keyfoundup = i;

        for(new i=0;i<ni-1;i++)
	        if(realBoard[i][nj-1] == 1)
				keyfounddown = i;
		while(ballfound < (keyfoundup + 1) && (keyfoundup + 1 < ni) && ballfound > 0 && ballfound < ni - 1) {
			new keyaux = keyfoundup;
			for(new i=0;i<3;i++) {
				changeColorTD(playerid,pongBoard, white, keyfoundup-1,nj-1);
				keyfoundup++;
			}
			changeColorTD(playerid,pongBoard, black, keyfoundup,nj-1);
			keyfoundup = keyaux - 1;
		}
		while(ballfound > (keyfounddown - 1) && (keyfounddown - 1 >= 0) && ballfound > 0 && ballfound < ni - 1) {
		    new keyaux = keyfounddown;
            for(new i=0;i<3;i++) {
				changeColorTD(playerid,pongBoard, white, keyfounddown+1,nj-1);
				keyfounddown--;
			}
			changeColorTD(playerid,pongBoard, black, keyfounddown,nj-1);
			keyfounddown = keyaux + 1;
		}
	}
	
	
}

forward getScore();
public getScore() {
	new sc[50];
	format(sc, sizeof(sc), "%d - %d", scorep1, scorep2);
 	TextDrawSetString(score, sc);
}

forward addScore();
public addScore() {
	score = TextDrawCreate(startX + startX/2 + startX/12, startY - 15.0, "");
    TextDrawColor(score, white);
    TextDrawAlignment(score, 2);
    TextDrawFont(score, 2);
    TextDrawSetShadow(score, 1);
    TextDrawSetOutline(score, 1);
    getScore();
}

public OnPlayerCommandText(playerid, cmdtext[])
{

	if (strcmp("/startpong", cmdtext, true, 10) == 0)
	{
	    // for
	    scorep1 = 0; scorep2 = 0;
	    addScore();
	    TextDrawShowForPlayer(playerid, score);
	    scorep1 = 0; scorep2 = 0;
	    for(new i = 0; i < ni; i++)
	        for(new j = 0; j < nj; j++) {
		   	 	pongBoard[i][j] = TextDrawCreate(startX + j*dj,startY + i*di , "I");
		   		setDefault(playerid,pongBoard,i,j);
		   		TextDrawShowForPlayer(playerid, pongBoard[i][j]);
   		    }
		// drawing palletes and ball
        draw(playerid, pongBoard);
        // start game
        direction = random(2);
        trajectory = random(2);
		gameTimer[playerid] = SetTimer("gameUpdate", speed, true);
		return 1;
	}
	
	
	if (strcmp("/stoppong", cmdtext, true, 10) == 0)
	{
	    // for
        for(new i = 0; i < ni; i++)
	        for(new j = 0; j < nj; j++) {
				TextDrawDestroy(pongBoard[i][j]);
			}
		TextDrawDestroy(score);
        drawingCompleted = false;
        KillTimer(gameTimer[playerid]);
		return 1;
	}
	return 0;
}

public OnPlayerUpdate(playerid)
{
    new Keys,ud,lr;
    GetPlayerKeys(playerid,Keys,ud,lr);

    if(ud == KEY_UP && drawingCompleted) {
        new keyfound = -1;
		for(new i = ni-1; i>0;i--)
		    if(realBoard[i][0] == 1)
		        keyfound = i;
		//if(keyfound == 0) keyfound = -1;
        if(keyfound != -1) {
			for(new i=0;i<3;i++) {
				changeColorTD(playerid,pongBoard, white, keyfound-1,0);
				keyfound++;
			}
			changeColorTD(playerid,pongBoard, black, keyfound,0);
		}
	}
    if(ud == KEY_DOWN && drawingCompleted) {
        new keyfound = -1;
		for(new i = 0; i<ni-1;i++)
		    if(realBoard[i][0] == 1)
		        keyfound = i;
		//if(keyfound == (ni-1)) keyfound = -1;
		if(keyfound != -1) {
			for(new i=0;i<3;i++) {
				changeColorTD(playerid,pongBoard, white, keyfound+1,0);
				keyfound--;
			}
			changeColorTD(playerid,pongBoard, black, keyfound,0);
		}
    }
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
