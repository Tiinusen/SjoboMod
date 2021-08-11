class MainHUD extends P2HUD;

simulated function DrawHUD( Canvas canvas ){
    Super.DrawHUD(canvas);
    if(!bHideHUD){
        DrawTimeOfDay(canvas);
    }
}

simulated function DrawTimeOfDay( canvas Canvas )
{
	local float XL, YL, X, Y;
	local float FadeOut;
    local string time;
    local MainGameInfo mgi;
    local int days, remainers, hours, minutes;
    local string padHours, padMinutes, text;

    mgi = MainGameInfo(Level.Game);


    days = mgi.TheGameState.TimeElapsed / mgi.DayLengthInSeconds;
    //log(mgi.TheGameState.TimeElapsed@" / "@mgi.DayLengthInSeconds@" = "@days);
    remainers = mgi.TheGameState.TimeElapsed - (days * mgi.DayLengthInSeconds);
    minutes = int((float(remainers) / float(mgi.DayLengthInSeconds)) * 24 * 60);
    hours = minutes / 60; 
    minutes -= hours * 60;
    if(hours < 10){
        padHours = "0";
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
    MyFont.DrawText(Canvas, text, FadeOut);
}