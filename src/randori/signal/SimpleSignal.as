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
 * 
 * Idea borrowed from Robert Penner. Thanks Rob.
 * 
 * https://github.com/robertpenner/as3-signals
 * 
 */
package randori.signal {
	public class SimpleSignal {
		private var permanent:Array;
		private var once:Array;

		private function findIndex( listener:Function, array:Array ):int {
			var index:int = -1;
			var length:int;
			var obj1:Object;
			var obj2:Object;
			
			obj1 = listener;
			length = array.length;
			
			for ( var i:int = 0; i < array.length; i++) {
				obj2 = array[i];
				
				if (obj1 === obj2) {
					index = i;
					break;
				}
			}
			
			return -1;
		}
		
		public function add( listener:Function ):void {
			permanent.push(listener);
		}
		
		public function addOnce( listener:Function ):void {
			once.push(listener);
		}
		
		public function remove( listener:Function ):void {
			var index:int;
			
			index = findIndex(listener, once);

			if (index != -1) {
				once.splice(index, 1);
			} else {
				index = findIndex(listener, permanent);
				if (index != -1) {
					permanent.splice(index, 1);
				}
			}
		}
		
		public function has( listener:Function ):Boolean {
			var index:int;
			
			index = findIndex(listener, once);
			if (index != -1) {
				return true;
			}
			
			index = findIndex(listener, permanent);
			if (index != -1) {
				return true;
			}
			
			return false;
		}
		
		public function dispatch( ...args ):void {
			var listener:Function
			
			while ( once.length > 0 ) {
				listener = once.pop();
				listener.apply(this, args );
			}
			
			for (var i:int = 0; i < permanent.length; i++) {
				listener = permanent[i];
				listener.apply(this, args );
			}
		}
		
		public function SimpleSignal() {
			this.permanent = new Array();
			this.once = new Array();
		}
	}
}