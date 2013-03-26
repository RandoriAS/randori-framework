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
package randori.template {
	import randori.jquery.JQuery;
	import randori.jquery.JQueryStatic;

	public class TemplateBuilder {
		private var templateAsString:String;
		
		public var validTemplate:Boolean = false;

		//We need to both parse it and remove it... if we dont then any behaviors setup on the template
		//will be created on the older nodes by the DomWalker. That is a problem
		
		//Also, be really careful. IF you replace a node in the DOM while you are walking the DOM, it will no longer know its Siblings... joy
		public function captureAndEmptyTemplateContents(rootTemplateNode:JQuery):void {
			templateAsString = rootTemplateNode.html();
			rootTemplateNode.empty();
			validTemplate = true;
		}
		
		private function returnFieldName( token:String ):String {
			return token.substr( 1, token.length - 2 );
		}

		public function renderTemplateClone(data:Object ):JQuery {
			var token:String;
			var field:String;
			var dereferencedValue:*;

			var keyRegex:RegExp = new RegExp("\\{[\\w\\W]+?\\}", "g");
			var foundKeys:Array = templateAsString.match(keyRegex);
			var output:String = templateAsString;
			
			if (foundKeys != null) {
				for ( var j:int = 0; j < foundKeys.length; j++ ) {
					
					token = foundKeys[ j ];
					field = returnFieldName( token );
					
					if (field.indexOf(".") != -1) {
						dereferencedValue = resolveComplexName(data, field);
					} else if (field != "*") {
						dereferencedValue = data[field];
					} else {
						dereferencedValue = data;
					}
					
					output = output.replace(token, dereferencedValue);
				}
			}
			
			var fragmentJquery:JQuery = JQueryStatic.J("<div></div>");
			fragmentJquery.append(output);
			
			return fragmentJquery;
		}

		private function resolveComplexName(root:Object, name:String):Object {
			var nextLevel:Object = root;
			
			var path:Array = name.split(".");
			for (var i:int = 0; i < path.length; i++) {
				nextLevel = nextLevel[path[i]];
				if (nextLevel == null) {
					return null;
				}
			}
			
			return nextLevel;
		}

		
		public function TemplateBuilder() {
		}
	}
}