package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var curBeat:Int = 0;
	private var curStep:Int = 0;
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;
	
	private var sequencer:FlxTypedGroup<FlxSpriteButton>;
	private var notes:Array<Dynamic> = [];
	private var sprCurBeat:FlxSprite;
	
	private var curEggs:Int = 0;
	private var curFlour:Float = 0;
	
	private var eggsNeeded:Int = 0;
	private var flourNeeded:Float = 0;
	
	private var barsLeft:Int = 0;
	
	private var txtIngreds:FlxText;
	
	override public function create():Void
	{
		initSequence();
		
		eggsNeeded = FlxG.random.int(5, 10);
		flourNeeded = FlxG.random.int(4, 10);
		
		txtIngreds = new FlxText(10, 200, 0, "", 24);
		add(txtIngreds);
		
		barsLeft = 8;
		
		super.create();
	}
	
	private function initSequence():Void
	{
		sequencer = new FlxTypedGroup<FlxSpriteButton>();
		add(sequencer);
		
		for (r in 0...2)
		{
			notes.push([]);
			for (i in 0...16)
			{
				
				notes[r].push(false);
				var seqBtn:FlxSpriteButton = new FlxSpriteButton((35 * i) + 20, (35 * r) + 50, null, function()
				{
					notes[r][i] = !notes[r][i];
					
				});
				seqBtn.makeGraphic(30, 30, FlxColor.WHITE);
				seqBtn.ID = i + (16 * r);
				sequencer.add(seqBtn);
				
				var section = i % 8;
				if (section < 4)
					seqBtn.color = FlxColor.RED;
			}
		}
		
		sprCurBeat = new FlxSprite().makeGraphic(30, 30, FlxColor.GREEN);
		sprCurBeat.scrollFactor.set();
		add(sprCurBeat);
		
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		txtIngreds.text = "";
		txtIngreds.text += curEggs + "/" + eggsNeeded + " eggs";
		txtIngreds.text += "\n";
		txtIngreds.text += curFlour + "/" + flourNeeded + " flour";
		txtIngreds.text += "\n\n" + barsLeft;
		
		if (FlxG.keys.justPressed.UP)
		{
			
			Conductor.changeBPM(1);
			FlxG.log.add("BPM " + Conductor.bpm);
			
		}
		
		if (barsLeft <= 0)
		{
			newOrder();
		}
		
		if (FlxG.keys.justPressed.SPACE)
		{
			newOrder();
		}
		
		sequencer.forEach(function(spr:FlxSpriteButton)
		{
			if (notes[Std.int(spr.ID / 16)][spr.ID % 16])
				spr.alpha = 1;
			else
				spr.alpha = 0.5;
		});
		
		sprCurBeat.setPosition((35 * curStep) + 20, 50 - 35);
		
		Conductor.songPosition += FlxG.elapsed;
		
		FlxG.watch.addQuick("songPos", Conductor.songPosition);
		FlxG.watch.addQuick("crotchet: ", Conductor.crochet);
		
		if (Conductor.songPosition > lastBeat)
		{
			lastBeat += Conductor.crochet;
			curBeat += 1;
		}
		
		if (Conductor.songPosition > lastStep + Conductor.steps)
		{
			lastStep += Conductor.steps;
			curStep += 1;
			
			if (notes[0][curStep])
			{
				hitKick(curStep % 4);
			}
			
			if (notes[1][curStep])
			{
				hitHiHat(curStep % 8);
			}
		}
		
		if (curStep == 16)
		{
			curBeat = 0;
			lastBeat = 0;
			curStep = 0;
			lastStep = 0;
			Conductor.songPosition = 0;
			
			barsLeft -= 1;
			
			if (notes[0][0])
			{
				hitKick(0);
			}
			
			if (notes[1][0])
			{
				hitHiHat(0);
			}
			
		}
		
	}
	
	private function newOrder():Void
	{
		eggsNeeded = FlxG.random.int(4, 14) * 4;
		flourNeeded = FlxG.random.int(8, 16) * 4;
		curEggs = 0;
		curFlour = 0;
		
		barsLeft = 8;
		
		Conductor.changeBPM(FlxG.random.int(1, 7));
	}
	
	private function hitHiHat(val:Int):Void
	{
		curFlour += 1;
		
		FlxG.sound.play(AssetPaths.hihat__mp3);
	}
	
	private function hitKick(val:Int):Void
	{
		curEggs += 1;
		
		FlxG.sound.play(AssetPaths.kick__mp3);
	}
}
