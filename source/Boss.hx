package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.addons.weapon.FlxWeapon;

class Boss extends FlxSprite
{
	// Boss weapon
	public var gun:FlxWeapon;
	// Position to fight from
	private var finalY:Int;
	// Difficulty multiplier
	public var multiplier:Int;
	// Shoot Timer
	private var shootTimer:FlxTimer;

	public function new(xPos:Int, yPos:Int, FinalY:Int)
	{
		// Apply position
		super(xPos, yPos, "assets/images/enemy_ship.png");

		// Each boss has 5 health
		health = 5;

		// Apply final position
		finalY = FinalY;

		// Default multiplier
		multiplier = 1;

		// Shoot timer
		shootTimer = new FlxTimer();

		// Create boss weapon
		gun = new FlxWeapon("bossGun", this);
		gun.makeImageBullet(50, "assets/images/laser_red.png");
		gun.setFireRate(200);
		gun.setBulletSpeed(200);
		// Center bullet origin
		gun.setBulletOffset(width / 2 - 4, 0);

		// Start shoot timer
		shootTimer.start(FlxRandom.floatRanged(1, 3 - (multiplier - 1)));
	}

	override public function update():Void
	{
		super.update();

		// Reset y speed
		velocity.y = 0;

		// Move towards final position
		if (y < finalY) 
		{
			velocity.y = 100;
			return;
		}

		// Move left and right
		if (x <= 0) 
			velocity.x += multiplier * 100;
		else if (x >= FlxG.width - 100) 
			velocity.x -= multiplier * 100;

		// Shoot
		if (shootTimer.finished)
		{
			gun.fireAtPosition(Std.int(x + width / 2) - 1, FlxG.height);
			shootTimer.reset(FlxRandom.floatRanged(1, 3 - (multiplier - 1)));
		}
	}
}