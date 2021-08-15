//#############################################################################
// WeaponBase exists to keep weapon classes more clean
//#############################################################################
class WeaponBase extends P2Weapon
	abstract;


//#############################################################################
// Shared Helper Methods
//#############################################################################

/////////////////////////////////////////////////////////////////////////////////////////
// GetTargetAliveNPC - Gets target in front of weapon which is alive of a pawn type
/////////////////////////////////////////////////////////////////////////////////////////
function Actor GetTargetAlive(float accuracy, float yOffset, float zOffset)
{
	local Pawn pawn;
	pawn = Pawn(GetTarget(accuracy, yOffset, zOffset));
	if(pawn != None && pawn.Health == 0){
		return None;
	}
    return pawn;
}

/////////////////////////////////////////////////////////////////////////////////////////
// GetTarget - Gets target in front of weapon (only alive targets)
/////////////////////////////////////////////////////////////////////////////////////////
function Actor GetTarget(float accuracy, float yOffset, float zOffset)
{
    local Vector hitNormal, startTrace, endTrace, X, Y, Z;
	local Actor other;
    
    GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	startTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, startTrace, 2*AimError);
	endTrace = startTrace + (yOffset + accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (zOffset + accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	endTrace += (TraceDist * X);
    
    other = Trace(LastHitLocation,hitNormal,endTrace,startTrace,true);
    return other;
}