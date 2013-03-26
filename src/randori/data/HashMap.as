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
package randori.data {

	public class HashMap {
		private var entries:Object;

		private function getEntry(key:Object):Entry {
			var keyAsString:String = key as String;
			var entry:* = entries[keyAsString];
			var returnEntry:Entry = null;
			
			if (entry != undefined) {
				if (entry is Array) {
					for ( var i:int = 0; i < entry.length; i++ ) {
						if ( entry[ i ].key == key ) {
							returnEntry = entry[i];
							break;
						}
					}
				} else if (entry.key == key) {
					returnEntry = entry;
				} 
			}
			
			return returnEntry;
		}
		
		public function get(key:Object):* {
			var entry:Entry = getEntry( key );
			
			return entry != null ? entry.value : null;
		}
		
		public function put( key:Object, value:* ):void {
			var keyAsString:String = key as String;
			var entryLocation:* = entries[keyAsString];
			
			if (entryLocation == null ) {
				//Doesnt exist, add it
				entries[keyAsString] = new Entry( key, value);
			} else {
				//there is already an entry location.... so
				var entry:* = getEntry(key);
				
				//Do we have a matching entry.. if so, update the value
				if (entry != undefined ) {
					entry.value = value;
				} else if ( entryLocation is Array ) {
					//Add this one to the location
					entryLocation.push( new Entry(key, value) );
				} else {
					//Convert this location to an array
					var ar:Array = new Array();
					ar[0] = entryLocation;
					ar[1] = new Entry( key, value );
					entries[keyAsString] = ar;
				}
			}
		}
		
		
		public function HashMap() {
			this.entries = new Object();
		}
	}
}

[JavaScript(export="false",name="Object",mode="json")]
class Entry {
	public var key:Object;
	public var value:*;
	
	public function Entry( key:Object, value:* ) {
		this.key = key;
		this.value = value;
	}
}