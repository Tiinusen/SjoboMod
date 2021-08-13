//#############################################################################
// Contains all custom HUD logics/graphics
//#############################################################################
class PlayerLandlordHUD extends P2HUD;


//#############################################################################
// Properties
//#############################################################################
var string TheMessage;
var float MessageExpires;
var bool showMessage;
var MainGameInfo mgi;
var PlayerController player;


//#############################################################################
// Constants
//#############################################################################
const MessageFadeOutTime = 2;


//#############################################################################
// Events / Event Helpers
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay() {
	Super.PostBeginPlay();

    mgi = MainGameInfo(Level.Game);
	player = PlayerController(Owner);
}

///////////////////////////////////////////////////////////////////////////////
// DrawHUD
///////////////////////////////////////////////////////////////////////////////
simulated function DrawHUD( Canvas canvas ){
    Super.DrawHUD(canvas);
    if(!bHideHUD){
        DrawTimeOfDay(canvas);
        if(showMessage){
            DrawMessage(canvas);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
// DrawMessage - Draws fading out message on screen
///////////////////////////////////////////////////////////////////////////////
simulated function DrawMessage( canvas Canvas )
{
    local float XL, YL, X, Y, fadeOut;

    if(MessageExpires - mgi.TheGameState.TimeElapsed <= 0.1){
        showMessage = false;
        TheMessage = "";
        return;
    }

    fadeOut = 1;
    if(MessageExpires - mgi.TheGameState.TimeElapsed <= MessageFadeOutTime){
        fadeOut = ((MessageExpires - mgi.TheGameState.TimeElapsed) / MessageFadeOutTime);
    }

    Canvas.bCenter = false;
    Canvas.DrawColor = RedColor;
    Canvas.DrawColor = Canvas.DrawColor * FadeOut;
    Canvas.Style = ERenderStyle.STY_Normal;
	
	Canvas.Font = MyFont.GetFont(2, false, CanvasWidth);
	Canvas.StrLen(TheMessage, XL, YL);
    X = CanvasWidth/2 - XL/2;
    Y = CanvasHeight/4 - YL/2;
	Canvas.SetPos(X, Y);
    MyFont.DrawText(Canvas, TheMessage, fadeOut);
}

///////////////////////////////////////////////////////////////////////////////
// DrawTimeOfDay -Draws Time of Day on HUD
///////////////////////////////////////////////////////////////////////////////
simulated function DrawTimeOfDay( canvas Canvas )
{
	local float XL, YL, X, Y;
    local string time;
    local int days, remainers, hours, minutes;
    local string padHours, padMinutes, text;

    days = mgi.TheGameState.TimeElapsed / mgi.DayLengthInSeconds;
    //log(mgi.TheGameState.TimeElapsed@" / "@mgi.DayLengthInSeconds@" = "@days);
    remainers = mgi.TheGameState.TimeElapsed - (days * mgi.DayLengthInSeconds);
    minutes = int((float(remainers) / float(mgi.DayLengthInSeconds)) * 24 * 60);
    hours = minutes / 60; 
    minutes -= hours * 60;
    if(hours < 10){
        padHours = " ";
    }
    if(minutes < 10){
        padMinutes = "0";
    }
    time = padHours@hours@":"@padMinutes@minutes;
    text = "Day "@(days+1)@" "@time;

	Canvas.bCenter = false;
    Canvas.DrawColor = RedColor;
    Canvas.Style = ERenderStyle.STY_Normal;
	
	Canvas.Font = MyFont.GetFont(2, false, CanvasWidth);
	Canvas.StrLen(text, XL, YL);
    X = CanvasWidth - XL-5;
    Y = 5;
	Canvas.SetPos(X, Y);
    MyFont.DrawText(Canvas, text, 0);
}


//#############################################################################
// Externally Invoked Actions
//#############################################################################

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DisplayMessage - DisplayMessage displays a message for provided amount of seconds or default for 5 seconds
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
function DisplayMessage(string message, optional int seconds)
{
    if(message == ""){
        return;
    }
    if(seconds <= 1){
        seconds = 5;
    }
    TheMessage = message;
    MessageExpires = mgi.TheGameState.TimeElapsed + seconds;
    showMessage = true;
}