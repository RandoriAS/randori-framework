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
package randori.i18n {
	import randori.signal.SimpleSignal;
	import randori.webkit.page.Window;

	public class NoOpTranslator extends AbstractTranslator {
		public override function synchronousTranslate( domain:String, keys:Vector.<String> ):Vector.<Translation> {
			if (Window.console != null) {
				Window.console.log("Requested to translate: " + domain + " " + keys);
			}
			return new Vector.<Translation>();
		}
		
		public override function translate(domain:String, keys:Vector.<String>):void {
			if (Window.console != null) {
				Window.console.log("Requested to translate: " + domain + " " + keys);
			}
		}

		public function NoOpTranslator( translationResult:SimpleSignal ) {
			super( translationResult );
		}
	}
}