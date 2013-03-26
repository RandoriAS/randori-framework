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
	import randori.data.HashMap;
	import randori.webkit.dom.NodeList;
	import randori.webkit.html.HTMLElement;
	import randori.webkit.html.HTMLLinkElement;
	import randori.webkit.page.Window;
	import randori.webkit.xml.XMLHttpRequest;

	public class StyleExtensionManager {
		
		private var map:StyleExtensionMap;
		
		private function findChildNodesForSelector( elements:Vector.<HTMLElement>, selectorArray:Array):Vector.<HTMLElement> {
			var selector:String = selectorArray.shift();

			//We need to actually abstract this so we can deal with IE and Opera returning a collection instead of a NodeList

			var newElements:Vector.<HTMLElement> = new Vector.<HTMLElement>();

			var element:HTMLElement;
			var nodes:NodeList;
			var j:int=0;

			if ( selector.substr( 0, 1 ) == "." ) {
				var className:String = selector.substring( 1 );
				//Lets assume this is a class selector
				while ( elements.length > 0 ) {
					element = elements.pop();
					//Check this element first
					if ( element.classList.contains( className ) ) {
						newElements.push( element );
					}
					
					//now its descendants
					nodes = element.getElementsByClassName( className );
					for ( j=0; j<nodes.length; j++) {
						newElements.push( nodes[ j ] );
					}
				}
			} else {
				//invalid but going to assume type for now
				while (elements.length > 0) {
					element = elements.pop();
					nodes = element.getElementsByTagName(selector);
					
					for (j = 0; j < nodes.length; j++) {
						newElements.push( nodes[j] );
					}
				}
			}
			
			//Only recurse if there is another selector
			if (selectorArray.length > 0) {
				newElements = findChildNodesForSelector(newElements, selectorArray);
			}
			
			return newElements;
		}
		
		private function findChildNodesForCompoundSelector( element:HTMLElement, selector:String ):Vector.<HTMLElement> {
			//lets start with simple ones
			var selectors:Array = selector.split( " " );
			
			var ar:Vector.<HTMLElement> = new Vector.<HTMLElement>();
			ar.push(element);
			var elements:Vector.<HTMLElement> = findChildNodesForSelector( ar, selectors );
			
			return elements;
		}

		public function getExtensionsForFragment(element:HTMLElement):HashMap {
			var hashmap:HashMap = new HashMap();
			//We need to loop over all of the relevant entries in the map that define some behavior
			var allEntries:Vector.<String> = map.getAllRandoriSelectorEntries();
			
			for ( var i:int=0; i<allEntries.length; i++) {
				var implementingNodes:Vector.<HTMLElement> = findChildNodesForCompoundSelector(element, allEntries[i]);
				
				var extensionEntry:StyleExtensionMapEntry;

				//For each of those entries, we need to see if we have any elements in this DOM fragment that implement any of those classes
				for ( var j:int=0; j<implementingNodes.length; j++) {
					
					var implementingElement:HTMLElement = implementingNodes[ j ];
					var value:* = hashmap.get( implementingElement );
					
					if ( value == null ) {
						//Get the needed entry
						extensionEntry = map.getExtensionEntry(allEntries[i]);
						
						//give us a copy so we can screw with it at will
						hashmap.put(implementingElement, extensionEntry.clone());
					} else {
						//We already have data for this node, so we need to merge the new data into the existing one
						extensionEntry = map.getExtensionEntry(allEntries[i]);
						
						extensionEntry.mergeTo( value as StyleExtensionMapEntry );
					}
				}
			}
			
			//return the hashmap which can be queried and applied to the Dom
			return hashmap;
		}

		public function parsingNeeded(link:HTMLLinkElement):Boolean {
			return ( link.rel == "stylesheet/randori" );
		}

		private function resetLinkAndReturnURL(link:HTMLLinkElement):String {
			
			//reset it and let the browser handle it now, we have the url we need
			//we will grab it next. So long as we are caching files, it will be retrieved synchronoulsy from the cache
			link.rel = "stylesheet";
			
			return link.href;
		}
		
		private function resolveSheet(url:String):void {
			var sheetRequest:XMLHttpRequest = new XMLHttpRequest();
			var behaviorSheet:String = "";
			var prefix:String;
			
			sheetRequest.open("GET", url, false);
			sheetRequest.send();
			
			if (sheetRequest.status == 404) {
				throw new Error("Cannot Find StyleSheet " + url);
			}
			
			var lastSlash:int = url.lastIndexOf("/");
			prefix = url.substring(0, lastSlash);
			
			parseAndPersistBehaviors(sheetRequest.responseText);
		}

		private function parseAndPersistBehaviors(sheet:String):void {
			var classSelector:String;
			var randoriVendorItemsResult:Array;
			var randoriVendorItemInfoResult:Array;
			var CSSClassSelectorNameResult:Array;
			/*
			* This regular expression then grabs all of the class selectors
			* \.[\w\W]*?\}
			* 
			* This expression finds an -randori vendor prefix styles in the current cssSelector and returns 2 groups, the first
			* is the type, the second is the value
			* 
			* \s?-randori-([\w\W]+?)\s?:\s?["']?([\w\W]+?)["']?;
			* 
			*/
			
			var allClassSelectors:RegExp = new RegExp("^[\\w\\W]*?\\}", "gm");
			
			const RANDORI_VENDOR_ITEM_EXPRESSION:String = "\\s?-randori-([\\w\\W]+?)\\s?:\\s?[\"\']?([\\w\\W]+?)[\"\']?;";
			//These two are the same save for the global flag. The global flag seems to disable all capturing groups immediately
			var anyVendorItems:RegExp = new RegExp(RANDORI_VENDOR_ITEM_EXPRESSION, "g");

			//This is the same as the one in findRelevant classes save for the the global flag... which is really important
			//The global flag seems to disable all capturing groups immediately
			var eachVendorItem:RegExp = new RegExp(RANDORI_VENDOR_ITEM_EXPRESSION);

			var classSelectorName:RegExp = new RegExp("^(.+?)\\s+?{", "m");
			var CSSClassSelectorName:String;
			var randoriVendorItemStr:String;
			
			var selectors:Array = sheet.match(allClassSelectors);

			if (selectors != null ) {
				for (var i:int = 0; i < selectors.length; i++) {
					classSelector = selectors[i];
					
					randoriVendorItemsResult = classSelector.match(anyVendorItems);
					if (randoriVendorItemsResult != null) {
						
						CSSClassSelectorNameResult = classSelector.match(classSelectorName);
						CSSClassSelectorName = CSSClassSelectorNameResult[1];
						
						for (var j:int = 0; j < randoriVendorItemsResult.length; j++) {
							randoriVendorItemStr = randoriVendorItemsResult[j];
							randoriVendorItemInfoResult = randoriVendorItemStr.match(eachVendorItem);
							map.addCSSEntry(CSSClassSelectorName, randoriVendorItemInfoResult[1], randoriVendorItemInfoResult[2]);
							if (Window.console != null) {
								Window.console.log(CSSClassSelectorName + " specifies a " + randoriVendorItemInfoResult[1] + " implemented by class " + randoriVendorItemInfoResult[2]);
							}
						}
					}
				}
			}

		}


		public function parseAndReleaseLinkElement(element:HTMLLinkElement):void {
			// TODO Auto Generated method stub
			resolveSheet(resetLinkAndReturnURL(element));
		}

		public function StyleExtensionManager( map:StyleExtensionMap ) {
			this.map = map;
		}

	}
}