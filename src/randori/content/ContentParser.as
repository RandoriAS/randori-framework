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
	public class ContentParser {
		public function parse( content:String ):String {
			//We need to get rid of the body element and maybe choose to do away with other things like script
			var bodyRegex:RegExp = new RegExp("(</?)body", "gi");
			var sanitizedContent:String = content.replace(bodyRegex,"$1div");
			return sanitizedContent;
		}
		
		public function ContentParser() {
		}
	}
}