//#############################################################################
// Helps the Dude making or breaking his own landlord business
//#############################################################################
class LandlordClipboardWeapon extends WeaponBase;


//#############################################################################
// Enums
//#############################################################################
enum LandlordClipboardState
{
	LCB_NONE_SELECTED,
	LCB_CANCEL,
	LCB_OFFER_HOUSING,
	LCB_OFFER_WORK,
	LCB_SHOW_HOUSING,
	LCB_SHOW_WORK
};


//#############################################################################
// Properties
//#############################################################################
var Texture ClipboardTextures[6];	// Textures of clipboard
var LandlordClipboardState ClipboardState;
var Texture NameTextures[3];		// Textures of names to be written on the clipboard
var Sound   WritingSound;			// Sound for when things are signed
var NPC Target;
var NPCController TargetController;	
var name SuggestedTag;


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
// PlayFiring - Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	PlayAnim('Gesture', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// PlayAltFiring - Play anim to grab money
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	PlayAnim('GetSignature', WeaponSpeedShoot1, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// PlayIdleAnim - TBD
///////////////////////////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	Super.PlayIdleAnim();		
}

///////////////////////////////////////////////////////////////////////////////
// TraceFire - Overriden Normal Fire
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float accuracy, float yOffset, float zOffset )
{
	local PlayerController player;
	player = PlayerController(Instigator.Controller);
	if(player != None)
	{
		switch(ClipboardState){
			case LCB_NONE_SELECTED:
				TraceFireNoneSelected(player, accuracy, yOffset, zOffset);
				break;
			case LCB_OFFER_HOUSING:
				TraceFireOfferHousing(player);
				break;
			case LCB_SHOW_HOUSING:
				TraceFireShowHousing(player);
				break;
			case LCB_CANCEL:
				TraceFireCancel(player);
				break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// TraceFireNoneSelected - When dude has nobody selected
///////////////////////////////////////////////////////////////////////////////
function TraceFireNoneSelected(PlayerController player, float accuracy, float yOffset, float zOffset)
{
	if(Target != None){
		if(Target.Health == 0 || !Target.IsInState('ReactToLandlordSpeaking')){
			Target = None;
		}
		if(Target != None){
			return;
		}
	}
	Target = NPC(GetTargetAlive(Accuracy,YOffset,ZOffset));
	if(Target != None){
		TargetController = NPCController(target.Controller);
		TargetController.InterestPawn = FPSPawn(Instigator);
		TargetController.GotoStateSave('ReactToLandlordSpeaking');
	}
}

///////////////////////////////////////////////////////////////////////////////
// TraceFireOfferHousing - When dude is offering living quarter
///////////////////////////////////////////////////////////////////////////////
function TraceFireOfferHousing(PlayerController player)
{
	SetClipboardState(LCB_SHOW_HOUSING);
	TargetController.GotoStateSave('FollowLandlordToPotentialHousing');
}

///////////////////////////////////////////////////////////////////////////////
// TraceFireShowHousing - When dude is showing a living quarter
///////////////////////////////////////////////////////////////////////////////
function TraceFireShowHousing(PlayerController player)
{
	local NPC npc;
	local HomeNode selectedHomeNode, homeNode;
	local float lowestDistance, distance;
	local PlayerLandlordHUD hud;

	// Scan for the closest HomeNode within 300 units
	foreach RadiusActors(class'HomeNode', homeNode, 600, Instigator.Location)
	{
		distance = VSize(Instigator.Location - homeNode.Location);
		if(homeNode.Tag == '')
			continue;
		if(selectedHomeNode != None && distance > lowestDistance)
			continue;
		selectedHomeNode = homeNode;
		lowestDistance = distance;
	}

	if(selectedHomeNode == None){
		hud = PlayerLandlordHUD(player.MyHUD);
		hud.DisplayMessage("You need to be close to a living quarter");
		return;
	}

	// Check if HomeNode already has an occupant or rentée
	foreach DynamicActors(class'NPC', npc){
		if(npc.NPCHomeTag == selectedHomeNode.Tag || npc.HomeTag == selectedHomeNode.Tag){
			hud = PlayerLandlordHUD(player.MyHUD);
			hud.DisplayMessage("This living quarter is already occupied");
			return;
		}
	}

	if(VSize(Instigator.Location - Target.Location) > 300){
		hud = PlayerLandlordHUD(player.MyHUD);
		hud.DisplayMessage("Wait for POI to arrive first");
		return;
	}

	SuggestedTag = selectedHomeNode.Tag;
	TargetController.GotoStateSave('DecideOnHousing');
}

///////////////////////////////////////////////////////////////////////////////
// TraceFireCancel - When dude no longer wants to interact with the POI
///////////////////////////////////////////////////////////////////////////////
function TraceFireCancel(PlayerController player)
{
	Target = None;
	TargetController = None;
	SetClipboardState(LCB_NONE_SELECTED);
	TargetController.GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
// AltFire - Overriden Alternate Fire
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	local PlayerLandlordController player;
	player = PlayerLandlordController(Instigator.Controller);
	if(player == None)
		return;
	
	switch(ClipboardState){
		case LCB_NONE_SELECTED:
			AltFireNoneSelected(player);
			break;
		case LCB_OFFER_HOUSING:
			if(Target.NPCWorkTag == '')
				SetClipboardState(LCB_OFFER_WORK);
			else
				SetClipboardState(LCB_CANCEL);
			break;
		case LCB_OFFER_WORK:
			SetClipboardState(LCB_CANCEL);
			break;
		case LCB_CANCEL:
			if(Target.HomeTag == '' && Target.NPCHomeTag == '')
				SetClipboardState(LCB_OFFER_HOUSING);
			else if(Target.NPCWorkTag == '')
				SetClipboardState(LCB_OFFER_WORK);
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// AltFireNoneSelected - When no dude is selected or pointed at
///////////////////////////////////////////////////////////////////////////////
function AltFireNoneSelected(PlayerLandlordController player)
{
	local PlayerLandlordHUD hud;
	hud = PlayerLandlordHUD(player.MyHUD);
	hud.DisplayMessage("You need to point at someone first");
}


//#############################################################################
// Events / Externally Invoked Actions
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// Notify_PetitionSigned - When animation reach point of writing
// invoked by NPCController->SignHousingContract
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_PetitionSigned()
{
	local PlayerLandlordController player;
	player = PlayerLandlordController(Instigator.Controller);
	if(player == None)
		return;

	Instigator.PlayOwnedSound(WritingSound, SLOT_Misc, 1.0, , , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

	TargetController.SetHome(SuggestedTag);
	TargetController.GoToHome();
	TargetController.GotoStateSave('Thinking');

	MoneyInv(player.MustGetOrCreateItem(class'Inventory.MoneyInv')).Amount += 20;
}

////////////////////////////////////////////////////////////////////////////////////////
// TargetGivesAttention - Called once pointed dude has given the landlord attention
////////////////////////////////////////////////////////////////////////////////////////
function TargetGivesAttention()
{
	if(Target.HomeTag == '' && Target.NPCHomeTag == '')
		SetClipboardState(LCB_OFFER_HOUSING);
	else if(Target.NPCWorkTag == '')
		SetClipboardState(LCB_OFFER_WORK);
	else
		SetClipboardState(LCB_CANCEL);
}

///////////////////////////////////////////////////////////////////////////////
// SetClipboardState - Sets the skin and state of the clipboard
///////////////////////////////////////////////////////////////////////////////
function SetClipboardState(LandlordClipboardState newState)
{
	ClipboardState = newState;
	Skins[1] = ClipboardTextures[int(ClipboardState)];
}


//#############################################################################
// States
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// NormalFire - TBD
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


//#############################################################################
// Default Properties
//#############################################################################
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


//#############################################################################
// Use Cases
//#############################################################################

///////////////////////////////////////////////////////////////////////////////
// CASE: Offer Housing to an NPC in front of player
///////////////////////////////////////////////////////////////////////////////
// ────────────────────────────────────────┬───────────────────────────────────
//                 LandlordClipboardWeapon │ NPCController
// ────────────────────────────────────────┼───────────────────────────────────
//                                         │
//                 TraceFireNoneSelected ──┼─────────────┐
//                                         │             │
//                                         │             ▼
//                 TraceFireOfferHousing ◄─┼── ReactToLandlordSpeaking
//                           │             │
//                           │             │
//                           ├─────────────┼─► FollowLandlordToPotentialHousing
//                           │             │        ▲        │          ▲
//                           ▼             │        │        │          │
//                  TraceFireShowHousing   │   WalkToTarget ◄┘          │
//                           │             │                            │
//                           │             │                         No │
//                           └─────────────┼─► DecideOnHousing ─────────┘
//                                         │         │
//                                         │         │ Yes
//                                         │         │
//                 Notify_PetitionSigned ◄─┼─────────┘
//                                         │
//                                         │