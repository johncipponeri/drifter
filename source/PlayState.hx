package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.ui.FlxBar;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.weapon.FlxBullet;
import flixel.effects.particles.FlxEmitterExt;
import flixel.effects.particles.FlxParticle;

class PlayState extends FlxState
{
	/* HUD Elements */
	// Score
	private var score:Int;
	private var scoreText:FlxText;
	// Game Over
	private var gameover:Bool;
	private var gameoverText:FlxText;
	// Player Lives
	private var lives:Array<FlxSprite>;

	/* In-Game Elements */
	// Parallax Background
	private var background:FlxBackdrop;
	// Player
	private var player:Player;
	// Spawns
	private var spawns:FlxTypedGroup<FlxSprite>;
	private var maxSpawnTime:Float;
	private var spawnTimer:FlxTimer;
	// Boss
	private var bosses:FlxTypedGroup<Boss>;
	private var bossSpawned:Bool;
	private var killCounter:Int;
	// Boss Joint Health bar
	private var bossHealthText:FlxText;
	private var bossHealth:FlxBar;
	// Explosion Effect
	private var explosionEmitter:FlxEmitterExt;
	private var redPixel:FlxParticle;

	/* State Initialization */
	override public function create():Void
	{
		super.create();

		// Hide mouse
		FlxG.mouse.visible = false;

		// Score
		score = 0;
		scoreText = new FlxText(10, 10, FlxG.width, "SCORE: 0", 12);
		scoreText.setBorderStyle(FlxText.BORDER_SHADOW);
		
		// Parallax Background
		background = new FlxBackdrop("assets/images/background.png");
		background.velocity.set(100, 100);

		// Player
		player = new Player();

		// Spawns
		spawns = new FlxTypedGroup<FlxSprite>();
		maxSpawnTime = 3;
		spawnTimer = new FlxTimer();

		// Boss
		bosses = new FlxTypedGroup<Boss>();
		bossSpawned = false;
		killCounter = 0;

		// Boss Health Text
		bossHealthText = new FlxText(0, 0, 0, "BOSS FIGHT!");
		bossHealthText.setPosition(FlxG.width / 2 - bossHealthText.fieldWidth * 1.25, 7);
		bossHealthText.setFormat(null, 20, FlxColor.WHITE, "center", FlxText.BORDER_SHADOW, FlxColor.BLACK);
		// Boss health bar
		bossHealth = new FlxBar(FlxG.width * 0.125, 37, FlxBar.FILL_LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 12, true);
		bossHealth.health = 15;
		bossHealth.setRange(0, 15);
		bossHealth.setParent(bossHealth, "health");

		// Explosion Effect
		explosionEmitter = new FlxEmitterExt(0, 0, 200);

		// Add elements to the State
		add(background);
		add(scoreText);
		add(player);
		add(spawns);
		add(player.gun.group);
		add(explosionEmitter);

		// Add Player Lives
		lives = new Array<FlxSprite>();
		for (life in 0...player.lives)
		{
			lives[life] = new FlxSprite(40 * life + 10, FlxG.height - 40, "assets/images/life.png");
			add(lives[life]);
		}

		// Add Particles
		for (i in 0...Std.int(explosionEmitter.maxSize / 2))
		{
			redPixel = new FlxParticle();
			redPixel.makeGraphic(3, 3, FlxColor.RED);
			redPixel.visible = false;
			explosionEmitter.add(redPixel);
			redPixel = new FlxParticle();
			redPixel.makeGraphic(2, 2, FlxColor.YELLOW);
			redPixel.visible = false;
			explosionEmitter.add(redPixel);
		}

		// Start Spawning
		spawnTimer.start(FlxRandom.floatRanged(1, maxSpawnTime));
	}

	/* Spawns new enemy */
	private function spawn():Void
	{
		// Generate new Spawn (Small asterid by default)
		var spawn:FlxSprite = new FlxSprite(FlxRandom.intRanged(10, 500), -100, "assets/images/asteroid_small.png");
		spawn.velocity.y = 100;

		// 25% Chance of another spawn besides default
		if (FlxRandom.chanceRoll(25))
			if (!bossSpawned) spawn.loadGraphic("assets/images/enemy_ship.png");
		else if (FlxRandom.chanceRoll(25))
			spawn.loadGraphic("assets/images/asteroid.png");
		else if (FlxRandom.chanceRoll(25))
			if (!bossSpawned) spawn.loadGraphic("assets/images/enemy_ufo.png");

		// Add the spawn to the State
		spawns.add(spawn);
	}

	/* Start boss fight */
	private function spawnBoss():Void
	{
		// Stop spawning enemy ships
		bossSpawned = true;
		// Start boss music
		FlxG.sound.playMusic("assets/music/bossfight.wav");
		// Slow down asteroid spawns
		maxSpawnTime = 3;
		// Create bosses
		bosses.add(new Boss(0, -100, 50));
		bosses.add(new Boss(FlxG.width - 100, -100, 125));
		bosses.add(new Boss(0, -100, 200));
		// Add bosses to State
		add(bosses);
		bosses.forEach(addBossWeapon);
		// Add boss health bar and text to State
		add(bossHealthText);
		add(bossHealth);
	}

	/* Add boss weapon to game */
	private function addBossWeapon(boss:Boss):Void
	{
		add(boss.gun.group);
	}

	/* Check if player shot a boss */
	private function hurtBoss(laser:FlxObject, boss:Boss):Void
	{
		// Play Explosion
		FlxG.sound.play("assets/sounds/explosion.wav");
		// Dipose of laser
		laser.kill();
		// Decrease boss health bar
		bossHealth.hurt(1);
		// Kill/Hurt boss
		if (boss.health - 1 == 0)
		{
			// Dispose of boss
			bosses.remove(boss);
			boss.destroy();

			// Are all bosses dead?
			if (bosses.countLiving() > 0)
			{
				// Show explosion
				explosionEmitter.setPosition(boss.x, boss.y);
				explosionEmitter.start(true, 0.6);
				// Nope, make bosses meaner!
				for(boss in bosses)
					boss.multiplier += 1;
			} else {
				// You win!
				setGameover("YOU WON!");
			}
		} else {
			// Boring, decrease health
			boss.health -= 1;
		}
	}

	/* Check of boss shot the player */
	private function bossShotPlayer(boss:Boss):Void
	{
		FlxG.overlap(player, boss.gun.group, hurtPlayer);
	}

	/* Hurt/Destroy an Enemy */
	private function hurtSpawn(laser:FlxObject, spawn:FlxObject):Void
	{
		// Play Explosion
		FlxG.sound.play("assets/sounds/explosion.wav");
		// Show Explosion
		explosionEmitter.setPosition(spawn.x, spawn.y);
		explosionEmitter.start(true, 0.6);
		// Dispose of enemy and laser
		spawn.destroy();
		laser.kill();
		// Increase score
		score += 500;
		// Increment kill count
		killCounter += 1;
	}

	/* Respawn/Kill the Player */
	private function hurtPlayer(player:Player, enemy:FlxObject):Void
	{
		// Check if player is flickering (invulnerable)
		if (FlxFlicker.isFlickering(player)) return;

		// Play Explosion
		FlxG.sound.play("assets/sounds/explosion.wav");
		// Show Explosion
		explosionEmitter.setPosition(enemy.x, enemy.y);
		explosionEmitter.start(true, 0.6);

		// Check if player is out of lives
		if (--player.lives == 0)
			setGameover("YOU LOST!");

		// Deplete number of lives left and kill attacker
		lives[player.lives].kill();

		// Reset players position
		player.setPosition(FlxG.width / 2 - 50, FlxG.height - 100);

		// Flicker player sprite
		FlxFlicker.flicker(player, 3, 0.05);

		// Check if laser or enemy crash
		if (Std.is(enemy, FlxBullet))
		{
			enemy = cast(enemy, FlxBullet);
			enemy.kill();
		} else
			enemy.destroy();
	}

	/* Check if Spawn is passed Player */
	private function checkSpawnBounds(spawn:FlxSprite):Void
	{
		if (spawn.y > FlxG.height)
		{
			FlxG.sound.play("assets/sounds/explosion.wav");
			spawns.remove(spawn);
			spawn.destroy();
			if ((score -= 1000) < 0) score = 0;
		}
	}

	/* Pause Game / Set Game Over Screen */
	private function setGameover(text:String):Void
	{
		// Show mouse for restart
		FlxG.mouse.visible = true;
		// Set this to "pause" game
		gameover = true;
		// Play normal music
		FlxG.sound.playMusic("assets/music/background.wav");
		// Format GameOver text
		gameoverText = new FlxText(0, 0, 0, text + "\n(click to play again)");
		gameoverText.setPosition(FlxG.width / 2 - gameoverText.fieldWidth * 1.25, FlxG.height / 3);
		gameoverText.setFormat(null, 20, FlxColor.WHITE, "center", FlxText.BORDER_SHADOW, FlxColor.BLACK);
		add(gameoverText);
	}
	
	/* Called when State is destroyed */
	override public function destroy():Void
	{
		// Nullify all objects for an easier clean-up
		spawnTimer = null;
		spawns = null;
		background = null;
		player = null;
		lives = null;
		gameoverText = null;
		bosses = null;
		explosionEmitter = null;
		redPixel = null;
		bossHealth = null;

		super.kill();
	}

	/* Called Every Frame */
	override public function update():Void
	{
		// Check if game over and if so do not update the game
		if (gameover)
		{
			// If mouse clicked, restart
			if (FlxG.mouse.pressed)
				FlxG.resetState();
			
			return;
		}

		super.update();

		// Check if time for a new spawn
		if (spawnTimer.finished)
		{
			if (maxSpawnTime > 1) maxSpawnTime -= 0.1;			
			spawn();
			spawnTimer.reset(FlxRandom.floatRanged(1, maxSpawnTime));
		}

		// Check for a game over
		spawns.forEach(checkSpawnBounds);

		// Check for boss, 30 kills required
		if (!bossSpawned && killCounter > 30)
			spawnBoss();

		// Boss collision detection
		FlxG.overlap(player.gun.group, bosses, hurtBoss);
		bosses.forEach(bossShotPlayer);

		// Basic collision detection
		FlxG.overlap(player, spawns, hurtPlayer);
		FlxG.overlap(player.gun.group, spawns, hurtSpawn);

		// Update score
		score += 1;
		scoreText.text = "SCORE: " + score;
	}	
}