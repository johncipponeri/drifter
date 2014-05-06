package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;

class MenuState extends FlxState
{
	// Parallax Background
	private var background:FlxBackdrop;
	// Logo Text
	private var logoText:FlxText;
	// Buttons
	private var btnPlay:FlxButton;

	// Play Button Click Event
	private function onClickPlay()
	{
		FlxG.switchState(new PlayState());
	}

	// Initialize State
	override public function create():Void
	{
		super.create();

		// Initialize Parallax Background
		background = new FlxBackdrop("assets/images/background.png");
		background.velocity.set(100, 100);

		// Initialize Logo Text
		logoText = new FlxText(0, 20, FlxG.width, "DRIFTER");
		logoText.setFormat(null, 48, FlxColor.WHITE, "center");
		logoText.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.BLACK, 2);

		// Create Play Button
		btnPlay = new FlxButton(FlxG.width / 2, FlxG.height / 2, "PLAY!", onClickPlay);
		btnPlay.x -= btnPlay.width / 2;

		// Add elements to State
		add(background);
		add(logoText);
		add(btnPlay);

		// Play Background Music
		FlxG.sound.playMusic("assets/music/background.wav", 0.35);
	}
	
	// Destroy State
	override public function destroy():Void
	{
		logoText = null;
		btnPlay = null;

		super.destroy();
	}
}