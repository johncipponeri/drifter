package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.weapon.FlxWeapon;

class Player extends FlxSprite
{
	// # of lives left
	public var lives:Int;
	// Current weapon
	public var gun:FlxWeapon;

	public function new()
	{
		// Center player on the bottom
		super(FlxG.width / 2 - 50, FlxG.height - 100, "assets/images/player_base.png");

		// 3 starting lives
		lives = 3;

		// Create default weapon
		gun = new FlxWeapon("gun", this);
		gun.makeImageBullet(50, "assets/images/laser_green.png");
		gun.setFireRate(200);
		gun.setBulletSpeed(200);
		// Center bullet origin
		gun.setBulletOffset(width / 2 - 4, 0);
	}

	override public function update():Void
	{
		super.update();

		// Reset velocity to prevent automatic movement
		velocity.x = 0;

		// Poll input
		if (FlxG.keys.anyPressed(["A", "LEFT"]))
			velocity.x -= 200;
		else if (FlxG.keys.anyPressed(["D", "RIGHT"]))
			velocity.x += 200;

		// Shoot straight up from center of ship
		if (FlxG.keys.anyJustPressed(["SPACE"]))
		{
			FlxG.sound.play("assets/sounds/shoot.wav");
			gun.fireAtPosition(Std.int(x + width / 2) - 1, 0);
		}
	}
}