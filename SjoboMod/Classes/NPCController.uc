//#############################################################################
// NPC Controller - Contains NPC controller logic
//#############################################################################
class NPCController extends NPCControllerBase;


//#############################################################################
// Properties
//#############################################################################
var bool HasBeenSetup, HasBeenBotheredRegardingRenting;
var bool IsBusy; // If true then it will prevent SMInterestPoints from fireing
var int Salary;
var NPC NPC;
var PlayerLandlordController InterestPlayerController;

// LandlordClipboard
var float WaitTimeoutExpire;
var LandlordClipboardWeapon LandlordClipboard;
var bool HasGivenAttention;


//#############################################################################
// Constants
//#############################################################################
const WaitTimeout = 20;


//#############################################################################
// Events
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay() 
{
    Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Gets called once when the NPC reaches his first Thinking state
///////////////////////////////////////////////////////////////////////////////
function Setup()
{
    
    local MoneyInv Money;
    NPC = NPC(MyPawn);
    Salary = Rand(NPC.NPCSalaryMax - NPC.NPCSalaryMin);
    Money = MoneyInv(MustGetOrCreateItem(class'MoneyInv'));
    Money.Amount = Salary;
}

///////////////////////////////////////////////////////////////////////////////
// Called by Main whenever a new day starts
///////////////////////////////////////////////////////////////////////////////
function NewDay()
{
    AddSalaryToBankAccount();
}

///////////////////////////////////////////////////////////////////////////////
// Adds NPC's assigned salary to
///////////////////////////////////////////////////////////////////////////////
function AddSalaryToBankAccount(){
    MoneyInv(MustGetOrCreateItem(class'MoneyInv')).Amount += Salary;
}

///////////////////////////////////////////////////////////////////////////////
// EndStateClipboard - Invoked by BeginState of all Clipboard related states
///////////////////////////////////////////////////////////////////////////////
function EndStateClipboard()
{
    if(LandlordClipboard.Target != MyPawn){
        return;
    }
    LandlordClipboard.Target = None;
    LandlordClipboard.SetClipboardState(LCB_NONE_SELECTED);
    InterestPlayerController = None;
    InterestPawn = None;
    LandlordClipboard = None;
}

///////////////////////////////////////////////////////////////////////////////
// BeginStateClipboard - Invoked by EndState of all Clipboard related states
///////////////////////////////////////////////////////////////////////////////
function BeginStateClipboard()
{
    MyPawn.StopAcc();

    InterestPlayerController = PlayerLandlordController(InterestPawn.Controller);
    WaitTimeoutExpire = Level.TimeSeconds + WaitTimeout;
    LandlordClipboard = LandlordClipboardWeapon(InterestPlayerController.GetItem(class'SjoboMod.LandlordClipboardWeapon'));

    Focus = InterestPawn;
    HasGivenAttention = false;
    IsBusy = true;
}


//#############################################################################
// States
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// Thinking
///////////////////////////////////////////////////////////////////////////////
state Thinking {
    function BeginState()
	{
        if(!HasBeenSetup){
            HasBeenSetup = true;
            Setup();
        }
        IsBusy = false;
        Super.BeginState();
    }
}

///////////////////////////////////////////////////////////////////////////////
// ReactToLandlordSpeaking - Invoked on Select Dude action
///////////////////////////////////////////////////////////////////////////////
state ReactToLandlordSpeaking
{

	function BeginState()
	{
		BeginStateClipboard();
	}

    function EndState()
	{
		Super.EndState();
        if(IsUpcomingState('Thinking'))
            EndStateClipboard();
	}

Begin:
    Sleep(2.0 - MyPawn.Reactivity);
    if(WaitTimeoutExpire < Level.TimeSeconds || LandlordClipboard.Target != MyPawn || VSize(InterestPawn.Location - MyPawn.Location) > 300){
        NPC.SetMood(MOOD_Angry, 1.0);
        Sleep(Say(MyPawn.myDialog.lDefiant, true));
        if(MyNextState == 'None')
            SetNextState('Thinking');
    }else if(!HasGivenAttention){
        HasGivenAttention = true;
        Sleep(Say(MyPawn.myDialog.lGreeting, true));
        LandlordClipboard.TargetGivesAttention();
    }
    if(MyNextState == 'None')
        SetNextState('ReactToLandlordSpeaking');
    GoToNextState();
    
    
	

   
}

///////////////////////////////////////////////////////////////////////////////
// FollowLandlordToPotentialHousing - Invoked on Offer Housing action
///////////////////////////////////////////////////////////////////////////////
state FollowLandlordToPotentialHousing
{
    function BeginState()
	{
		BeginStateClipboard();
	}

    function EndState()
	{
		Super.EndState();
        if(!IsUpcomingState('WalkToTarget') && !IsUpcomingState('DecideOnHousing'))
            EndStateClipboard();
	}

Begin:
    if(Salary < 20){
        if(HasBeenBotheredRegardingRenting){
            NPC.SetMood(MOOD_Angry, 1.0);
            Sleep(Say(MyPawn.myDialog.lDefiant, true));
        }else{
            Sleep(Say(MyPawn.myDialog.lDontAcceptDeal, true));
        }
        HasBeenBotheredRegardingRenting = true;
        GotoStateSave('Thinking');
    }
    if(InterestPawn == None){
        log("No more interest");
        SetNextState('Thinking');
    }else if(VSize(InterestPawn.Location - MyPawn.Location) > 300){
        SetEndGoal(InterestPawn, 70);
        SetNextState('FollowLandlordToPotentialHousing');
        GotoStateSave('WalkToTarget');
    }else{
        if(!HasGivenAttention){
            HasGivenAttention = true;
            Sleep(Say(MyPawn.myDialog.lYes, true));
        }else if(WaitTimeoutExpire < Level.TimeSeconds || LandlordClipboard.Target != MyPawn){
            NPC.SetMood(MOOD_Angry, 1.0);
            Sleep(Say(MyPawn.myDialog.lDefiant, true));
            if(MyNextState == 'None')
                SetNextState('Thinking');
        }
    }

    if(MyNextState == 'None'){
        Sleep(2.0 - MyPawn.Reactivity);
        SetNextState('FollowLandlordToPotentialHousing');
    }
    GoToNextState(true);
}

///////////////////////////////////////////////////////////////////////////////
// DecideOnHousing - Invoked on Show Housing action
///////////////////////////////////////////////////////////////////////////////
state DecideOnHousing
{

    function BeginState()
	{
		BeginStateClipboard();
	}

    function EndState()
	{
		Super.EndState();
        if(!IsUpcomingState('FollowLandlordToPotentialHousing'))
            EndStateClipboard();
	}

Begin:
    if(false){ // TODO: craete a fair way of denial
        Sleep(Say(MyPawn.myDialog.lDontAcceptDeal, true));
        GotoStateSave('FollowLandlordToPotentialHousing');
    }
    Sleep(Say(MyPawn.myDialog.lAcceptDeal, true));
    NPC.NPCHomeTag = LandlordClipboard.SuggestedTag;
    NPC.HomeTag = NPC.NPCHomeTag;
    FindHomeList(NPC.HomeTag);
    NPC.bCanEnterHomes = true;

    // To prevent the character from going into limbo
    if(MyNextState == 'None')
        GotoStateSave('Thinking');
    GoToNextState(true);

}