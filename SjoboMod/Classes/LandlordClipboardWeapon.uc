class LandlordClipboardWeapon extends SMWeapon;

var Texture ClipboardTextures[6];	// Textures of clipboard
var int ClipboardState;
var Texture NameTextures[3];		// Textures of names to be written on the clipboard
var Sound   WritingSound;			// Sound for when things are signed
var NPC Target;
var NPCController TargetController;	

const LCB_NONE_SELECTED = 0;
const LCB_CANCEL = 1;
const LCB_OFFER_HOUSING = 2;
const LCB_OFFER_WORK = 3;
const LCB_SHOW_HOUSING = 4;
const LCB_SHOW_WORK = 5;

//#############################################################################
// Events / User Invoked Actions
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	PlayAnim('Gesture', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Play anim to grab money
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	PlayAnim('GetSignature', WeaponSpeedShoot1, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// TBD
///////////////////////////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	Super.PlayIdleAnim();		
}

///////////////////////////////////////////////////////////////////////////////
// Overriden Normal Fire
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local Player player;
	player = Player(Instigator.Controller);
	if(player != None)
	{
		switch(ClipboardState){
			case LCB_NONE_SELECTED:
				if(Target != None){
					if(!Target.IsInState('ReactToLandlordSpeaking')){
						Target = None;
					}
					if(Target != None){
						return;
					}
				}
				Target = NPC(GetTarget(Accuracy,YOffset,ZOffset));
				if(target != None){
					TargetController = NPCController(target.Controller);
					TargetController.InterestPawn = FPSPawn(Instigator);
					TargetController.GotoStateSave('ReactToLandlordSpeaking');
				}
				break;
			case LCB_OFFER_HOUSING:
				
				break;
			case LCB_CANCEL:
				Target = None;
				SetClipboardState(LCB_NONE_SELECTED);
				TargetController.GotoState('Thinking');
				break;
		}
		
	}
}

///////////////////////////////////////////////////////////////////////////////
// Overriden Alternate Fire
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	local Player player;
	player = Player(Instigator.Controller);
	
	switch(ClipboardState){
		case LCB_NONE_SELECTED:
			AltFireNoneSelected(player);
			break;
		case LCB_OFFER_HOUSING:
			SetClipboardState(LCB_OFFER_WORK);
			break;
		case LCB_OFFER_WORK:
			SetClipboardState(LCB_CANCEL);
			break;
		case LCB_CANCEL:
			SetClipboardState(LCB_OFFER_HOUSING);
			break;
	}
}

function AltFireNoneSelected(Player player)
{
	local MainHUD hud;
	hud = MainHUD(player.MyHUD);
	hud.DisplayMessage("You need to point at someone first");
}

//#############################################################################
// Events / External Invoked Actions
//#############################################################################

function TargetGivesAttention()
{
	SetClipboardState(LCB_OFFER_HOUSING);
}

///////////////////////////////////////////////////////////////////////////////
// Point at which a noise is played and signature is written to clipboard
///////////////////////////////////////////////////////////////////////////////
// simulated function Notify_PetitionSigned()
// {
// 	local P2Player p2p;
// 	local byte StateChange;

// 	if(Instigator != None)
// 		p2p = P2Player(Instigator.Controller);
		
// 	//log(self@"notify signed"@p2p@p2p.interestpawn@PersonController(p2p.InterestPawn.Controller));

// 	if(p2p != None
// 		&& p2p.InterestPawn != None
// 		&& PersonController(p2p.InterestPawn.Controller) != None)
// 		PersonController(p2p.InterestPawn.Controller).CheckTalkerAttention(StateChange);
// 	else
// 		StateChange = 1;

// 	if(StateChange == 0)
// 	{
// 		Instigator.PlayOwnedSound(WritingSound, SLOT_Misc, 1.0, , , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
// 		AskingState = CB_GOT_SIG;
// 	}
// 	else
// 		AskingState = CB_WALKED_AWAY;
// }

function SetClipboardState(int newState)
{
	ClipboardState = newState;
	Skins[1] = ClipboardTextures[ClipboardState];
}

///////////////////////////////////////////////////////////////////////////////
// Check to invalidate the hands when you get added, so the clipboard is the
// only hands option
///////////////////////////////////////////////////////////////////////////////
// function GiveTo(Pawn Other)
// {
// 	local P2Player p2p;

// 	Super.GiveTo(Other);

// 	// Check to invalidate the hands
// 	if(P2Pawn(Other).bPlayer)
// 	{
// 		p2p = P2Player(Other.Controller);

// 		if(P2AmmoInv(AmmoType) != None
// 			&& P2AmmoInv(AmmoType).bReadyForUse)
// 			p2p.SetWeaponUseability(false, p2p.MyPawn.HandsClass);
// 	}
// }

///////////////////////////////////////////////////////////////////////////////
// Turn off the clipboard as being the basic hands
///////////////////////////////////////////////////////////////////////////////
// function SwapBackToHands()
// {
// 	local P2Player p2p;

// 	if(!bSwappedBack)
// 	{
// 		bSwappedBack=true;

// 		// Now remove it completely from your inventory.
// 		if (P2AmmoInv(AmmoType).bReadyForUse
// 			&& Instigator != None)
// 		{
// 			p2p = P2Player(Instigator.Controller);
// 			p2p.SetWeaponUseability(true, p2p.MyPawn.HandsClass);
// 			if(p2p != None)
// 			{
// 				// Turn clipboard off
// 				//log(self@"Set Ready For Use False");
// 				SetReadyForUse(false);
// 				// Switch to them
// 				//log(self@"Goto State DownWeapon");
// 				GotoState('DownWeaponRemove');
// 				//log(self@p2p@"Switch To Hands True");				
// 				//p2p.SwitchToThisWeapon(class'HandsWeapon'.Default.InventoryGroup,class'HandsWeapon'.Default.GroupOffset);
// 				//p2p.SwitchToHands(true);
// 				//p2p.ConsoleCommand("SwitchToHands true");
// 			}
// 		}
// 	}
// }

///////////////////////////////////////////////////////////////////////////////
// Just to make sure (on day warps this can get called instead of the normal process)
// always swap back to your hands
///////////////////////////////////////////////////////////////////////////////
// function Destroyed()
// {
// 	SwapBackToHands();

// 	Super.Destroyed();
// }

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Normal fire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	function AnimEnd(int Channel)
	{
		local P2Player p2p;

		if(bAltFiring)
		{
			bAltFiring=false;

			// p2p = P2Player(Instigator.Controller);

			// if(p2p != None
			// 	&& AskingState == CB_GOT_SIG)
			// {
			// 	p2p.DudeTakeDonationMoney(PendingMoney, bMoneyGoesToCharity);
			// 	PendingMoney=0;
			// }
		}

		Super.AnimEnd(Channel);
	}
}

/*
///////////////////////////////////////////////////////////////////////////////
// Finish a sequence
///////////////////////////////////////////////////////////////////////////////
function Finish()
{
	local bool bOldSwappedBack;

	bOldSwappedBack = bSwappedBack;

	if(AmmoType.AmmoAmount == AmmoType.MaxAmmo)
	{
		// Send the clipboard weapon to a state that will put it down, then
		// remove it forever from your inventory
		SwapBackToHands();
//		GotoState('EmptyDownWeapon');
	}
	//else

	if(bOldSwappedBack==bSwappedBack)
		Super.Finish();
}
*/

///////////////////////////////////////////////////	////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// EmptyDownWeapon
// For grenades, thrown things, napalm launcher, where he must put away
// and empty or non-existant weapon (like he's got nothing in his hands)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// state DownWeaponRemove extends DownWeapon
// {
// 	simulated function AnimEnd(int Channel)
// 	{
// 		P2Player(Instigator.Controller).SwitchToThisWeapon(class'HandsWeapon'.Default.InventoryGroup,class'HandsWeapon'.Default.GroupOffset);
// 		Super.AnimEnd(Channel);
// 		GotoState('');
// 	}

// 	function EndState()
// 	{
// 		P2Player(Instigator.Controller).SwitchToThisWeapon(class'HandsWeapon'.Default.InventoryGroup,class'HandsWeapon'.Default.GroupOffset);
// 		//SwapBackToHands();
// 	}

// }

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	bUsesAltFire=true
	ItemName="Landlord Clipboard"
	AmmoName=class'ClipboardAmmoInv'
	PickupClass=class'ClipboardPickup'
	AttachmentClass=class'ClipboardAttachment'

	// JWB 10/04/13 - Quick fix for widescreen users.
	// DisplayFOV=60

	bCanThrow=false

	//Mesh=Mesh'FP_Weapons.FP_Dude_Clipboard'
	Mesh=Mesh'MP_Weapons.MP_LS_Clipboard'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Texture'SjoboModTex.landlord_clipboard_none_selected'
	Skins[2]=Texture'Timb.Misc.Invisible_timb'
	Skins[3]=Texture'Timb.Misc.Invisible_timb'
	Skins[4]=Texture'Timb.Misc.Invisible_timb'

	ClipboardTextures[0]=Texture'SjoboModTex.landlord_clipboard_none_selected'
	ClipboardTextures[1]=Texture'SjoboModTex.landlord_clipboard_cancel'
	ClipboardTextures[2]=Texture'SjoboModTex.landlord_clipboard_offer_housing'
	ClipboardTextures[3]=Texture'SjoboModTex.landlord_clipboard_offer_work'
	ClipboardTextures[4]=Texture'SjoboModTex.landlord_clipboard_show_housing'
	ClipboardTextures[5]=Texture'SjoboModTex.landlord_clipboard_show_work'

	NameTextures[0]=FinalBlend'WeaponSkins.signature_1_neg'
	NameTextures[1]=FinalBlend'WeaponSkins.signature_2_neg'
	NameTextures[2]=FinalBlend'WeaponSkins.signature_3_neg'

	FirstPersonMeshSuffix="Clipboard"

    bDrawMuzzleFlash=false

	//shakemag=100.000000
	//shaketime=0.200000
	//shakevert=(X=0.0,Y=0.0,Z=4.00000)
	ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0

	//FireSound=Sound'WeaponSounds.pistol'
	CombatRating=0.6
	AIRating=0.0
	AutoSwitchPriority=1
	InventoryGroup=0
	GroupOffset=4
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.0
	ViolenceRank=0
	bBumpStartsFight=false
	bArrestableWeapon=true

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 0.7
	WeaponSpeedShoot1Rand=0.5
	WeaponSpeedShoot2  = 1.0
	AimError=0

	TraceDist=215.0
	WritingSound=Sound'MiscSounds.Map.CheckMark'

	bAllowHints=true
	bShowHints=true
	HudHint1="Press %KEY_Fire% to do what the clipboard says"
	HudHint2="Press %KEY_AltFire% to change action"
	HudHint3=""

	DropWeaponHint1="They've seen your clipboard!"
	DropWeaponHint2="Press %KEY_ThrowWeapon% to drop it."

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	ThirdPersonRelativeLocation=(X=6,Z=5)
	ThirdPersonRelativeRotation=(Yaw=-1600,Roll=-16384)
	PlayerViewOffset=(X=2,Y=0,Z=-8)
	}
