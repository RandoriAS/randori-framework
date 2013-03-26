/***
 * Copyright 2013 LTN Consulting, Inc. /dba Digital Primates®
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 
 * @author Michael Labriola <labriola@digitalprimates.net>
 */
package randori.timer {
	import randori.signal.SimpleSignal;
	import randori.webkit.page.Window;

	public class Timer {
		public var timerTick:SimpleSignal;
		public var timerComplete:SimpleSignal;
		
		private var _delay:int;
		private var _repeatCount:int;
		private var _currentCount:int;
		
		private var intervalID:int;

		public function get delay():int {
			return _delay;
		}
		
		public function get repeatCount():int {
			return _repeatCount;
		}

		public function get currentCount():int {
			return _currentCount;
		}

		protected function onTimerTick():void {
			_currentCount++;
			
			timerTick.dispatch(this, _currentCount);
			
			if (_currentCount == _repeatCount) {
				timerComplete.dispatch( this );
			}
			
			stop();
		}
		
		public function start():void {
			if ( intervalID != -1 ) {
				stop();
			}

			intervalID = Window.setInterval(onTimerTick, delay);
		}
		
		public function stop():void {
			if ( intervalID != -1 ) {
				Window.clearInterval( intervalID );
			}
			
			intervalID = -1;
		}
		
		public function reset():void {
			_currentCount = 0;
			stop();
		}

		public function Timer( delay:int, repeatCount:int=0) {
			_delay = delay;
			_repeatCount = repeatCount;
			_currentCount = 0;		
			intervalID = -1;
			
			//discuss injecting these
			timerTick = new SimpleSignal();
			timerComplete = new SimpleSignal();
		}
	}
}