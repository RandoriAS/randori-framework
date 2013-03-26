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
package randori.styles {
	public class StyleExtensionMapEntry {
		
		private var hashMap:Object; 
		
		public function addExtensionType( extensionType:String, extensionValue:String ):void {
			hashMap[extensionType] = extensionValue;
		}

		public function hasExtensionType( extensionType:String):Object {
			return (hashMap[extensionType] != null);
		}

		public function getExtensionValue(extensionType:String):String {
			return hashMap[extensionType];
		}

		public function clone():StyleExtensionMapEntry {
			var newEntry:StyleExtensionMapEntry = new StyleExtensionMapEntry();
			
			mergeTo( newEntry );
			
			return newEntry;
		}
		
		public function mergeTo( entry:StyleExtensionMapEntry ):void {
			for each (var extensionType:String in hashMap) {
				entry.addExtensionType(extensionType, hashMap[extensionType]);
			}
		}

		public function StyleExtensionMapEntry() {
			this.hashMap = new Object();
		}
	}
}