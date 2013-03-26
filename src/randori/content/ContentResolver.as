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
package randori.content {
	import randori.styles.StyleExtensionMap;
	import randori.webkit.html.HTMLElement;

	public class ContentResolver {
		
		private var map:StyleExtensionMap;
		
		public function resolveContent(element:HTMLElement):void {
			var content:String = element.getAttribute("data-content");
			
			//Clean up any of our properties embedded in the DOM
			element.removeAttribute("data-content");
			
			if (content == null) {
				//content = map.getExtensionValue("content");
			}
			
			//load the content
		}
		
		public function ContentResolver( map:StyleExtensionMap ) {
			this.map = map;
		}
	}
}