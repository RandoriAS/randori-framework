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
	public class StyleExtensionMap {
		private var hashMap:Object;

		public function addCSSEntry(cssSelector:String, extensionType:String, extensionValue:String ):void {
			var attributes:StyleExtensionMapEntry = hashMap[cssSelector];
			
			if (attributes == null) {
				attributes = new StyleExtensionMapEntry();
				hashMap[cssSelector] = attributes;
			}
			
			attributes.addExtensionType(extensionType, extensionValue);
		}
		
		public function hasBehaviorEntry(cssSelector:String):Boolean {
			return (hashMap[cssSelector] != null);
		}
		
		public function getExtensionEntry(cssSelector:String):StyleExtensionMapEntry {
			return hashMap[cssSelector];
		}
		
		public function getAllRandoriSelectorEntries():Vector.<String> {
			var allEntries:Vector.<String> = new Vector.<String>();
			
			for each (var cssSelector:String in hashMap) {
				allEntries.push(cssSelector);
			}
			
			return allEntries;
		}
		
		public function StyleExtensionMap() {
			this.hashMap = new Object();
		}
	}
}