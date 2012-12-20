package  {
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import com.bit101.components.PushButton;
	import com.bit101.components.Label;
	import com.bit101.components.RadioButton;
	import com.bit101.components.VBox;
	import com.bit101.components.HUISlider;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;

	[SWF(width="640", height="480", frameRate="60", backgroundColor="#222222")]
	public class AudioWaveforms extends Sprite {
		private static const SINE : String = "SINE";
		private static const SQUARE : String = "SQUARE";
		private static const SAWTOOTH : String = "SAWTOOTH";
		private static const TRIANGLE : String = "TRIANGLE";
		private static const NOISE : String = "NOISE";
		private const PIx2 : Number = Math.PI * 2;
		private var _phase : int;
		private var _hz : Number = 200;
		private var _waveform : String = SINE;
		private var _hzSlider : HUISlider;

		public function AudioWaveforms() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;

			init();
		}

		private function init() : void {
			
			var vBox: VBox = new VBox(this, 20, 20);
			
			new Label(vBox, 0, 0, "FREQUENCY:");
			_hzSlider = new HUISlider(vBox, 0, 0, "Hz", updateHz);
			_hzSlider.setSliderParams(0, 1000, _hz);
			_hzSlider.labelPrecision = 0;
			_hzSlider.width = 400;
			new Label(vBox, 0, 0, "WAVEFORM:");
			new RadioButton(vBox, 0, 0, SINE, true, updateWaveform);
			new RadioButton(vBox, 0, 0, SQUARE, false, updateWaveform);
			new RadioButton(vBox, 0, 0, SAWTOOTH, false, updateWaveform);
			new RadioButton(vBox, 0, 0, TRIANGLE, false, updateWaveform);
			new RadioButton(vBox, 0, 0, NOISE, false, updateWaveform);
			new Label(vBox, 0, 0, "ON/OFF:");
			new PushButton(vBox, 0, 0, "Off", updateOnff);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			
			_phase = 0;

			var sound : Sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound.play();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event : Event) : void {
//			_hz+=10;
		}

		private function updateOnff(event: Event) : void {
			var b: PushButton = event.target as PushButton;
			var isOn: Boolean = b.label == "Off";
			isOn ? SoundMixer.soundTransform = new SoundTransform(0) : SoundMixer.soundTransform = new SoundTransform(1);
			isOn ? b.label = "On" : b.label = "Off";
		}

		private function updateHz(event: Event = null) : void {
			_hz = Math.round(_hzSlider.value);
		}

		private function updateWaveform(event: Event) : void {
			_waveform = (event.target as RadioButton).label;
		}

		private function onKey(event : KeyboardEvent) : void {
			switch(event.keyCode){
				case Keyboard.LEFT:
					_hzSlider.value --;
					break;
				case Keyboard.RIGHT:
					_hzSlider.value ++;
					break;
				default:
			}
			updateHz();
		}

		private function onSampleData(event : SampleDataEvent) : void {
//			trace("AudioTest.onSampleData()");
			var rate : Number = 44100;
//			var samples : uint = 4096;
//			var samples : uint = 2048;
			var samples : uint = 8192;
			for (var i : int = 0; i < samples; ++i) {
				_phase = i + event.position;
				var phase : Number = _phase / rate;
				var theta : Number = phase * _hz;
				
				var sampleL : Number;
				var sampleR : Number;
				
				var sine: Number = Math.sin(theta * PIx2);
				var square: Number = sgn(sine);
				var sawtooth: Number = theta - Math.floor( theta + 0.5 );
//				var sawtooth: Number = 1 * ( theta - Math.floor(theta) ) - 1;
				var triangle: Number = Math.abs(4 * (theta - Math.floor(theta + 0.5))) - 1.0;
				var noiseL: Number = -1 + Math.random() * 2;
				var noiseR: Number = -1 + Math.random() * 2;
				
				switch(_waveform){
					case SINE:
						sampleL = sine;
						sampleR = sine;
						break;
					case SQUARE:
						sampleL = square;
						sampleR = square;
						break;
					case SAWTOOTH:
						sampleL = sawtooth;
						sampleR = sawtooth;
						break;
					case TRIANGLE:
						sampleL = triangle;
						sampleR = triangle;
						break;
					case NOISE:
						sampleL = noiseL;
						sampleR = noiseR;
						break;
					default:
				}

//				var amplitude : Number = 0.75;
//				sampleL *= amplitude;
//				sampleR *= amplitude;
				
				/*
				 * square(t) = sgn(sin(2πt))
				 * sawtooth(t) = t - floor(t + 1/2)
				 * triangle(t) = abs(sawtooth(t))
				 */

				// left
				event.data.writeFloat(sampleL);
				// right
				event.data.writeFloat(sampleR);

				_phase++;
			}
		}
		
		private function sgn(x: Number) : Number {
			return x == 0 ? 0 : x < 0 ? -1 : 1;
		}
	}
}
