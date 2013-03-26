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
	import randori.timer.Timer;
	import randori.webkit.dom.Node;

	public class LocalizationProvider {
		
		private var internationalKey:RegExp = new RegExp("\\[(labels|messages|reference)\\.\\w+\\]", "g");
		
		private var translator:AbstractTranslator;
		private var pendingTranslations:Object;
		private var timer:Timer;
		
		private function getElementLocalizationComponents( textNode:Node ):Array {
			var textContent:String = textNode.nodeValue;
			var i18nResult:Array = textContent.match(internationalKey);
			
			return i18nResult;
		}
		
		public function translateKeysSynchronously( domain:String, keys:Vector.<String> ):Vector.<Translation> {
			return translator.synchronousTranslate( domain, keys );
		}

		public function investigateTextNode(textNode:Node):void {
			//We have a list of matches within the text node which tell us what we need to get
			//further we have the original node, which we need to preserve as there may be only parts getting translated
			//even though this is bad form <div>[labels.monkey] is a type of [labels.animal]</div> we still need to support it
			var result:Array = getElementLocalizationComponents(textNode);
			
			if (result != null) {
				for ( var i:int=0; i<result.length;i++) {
					requestTranslation( result[ i ], textNode );
				}
				
				scheduleTranslation();
			}
		}
		
		private function requestTranslation( expression:String, textNode:Node ):void {
			var pendingTranslation:Vector.<Node> = pendingTranslations[expression];
			
			if (pendingTranslation == null) {
				pendingTranslation = new Vector.<Node>();
				pendingTranslations[expression] = pendingTranslation;
			}
			
			pendingTranslation.push(textNode);
		}
		
		private function scheduleTranslation():void {
			//We want to batch a page or so at a time, we instead of sending requests 
			//immediately we defer until 10ms pass where we don't have a request
			timer.reset();
			timer.start();
		}

		private function sendTranslationRequest( timer:Timer ):void {
			var domainLabels:Object = new Object();
			
			var keyValuePair:RegExp = new RegExp("\\[(labels|messages|reference)\\.(\\w+)\\]");
			var result:Array;
			
			var domain:String;
			var key:String;
			
			//The translation translator works on domains, so we need to break up the available items we have and make appropriate requests to the translator
			for each (var expression:String in pendingTranslations) {
				result = expression.match(keyValuePair);
				domain = result[1];
				key = result[ 2 ];
				
				if (domainLabels[domain] == null ) {
					domainLabels[domain] = new Vector.<String>();
				}
				
				domainLabels[domain].push( key );
			}
			
			for each ( var domainEntry:String in domainLabels ) {
				translator.translate(domainEntry, domainLabels[domainEntry]);
			}
		}

		private function provideTranslation( domain:String, translations:Vector.<Translation> ):void {
			var expression:String;
			var nodes:Vector.<Node>;
			
			for ( var i:int=translations.length-1; i>=0;i--) {
				expression = "[" + domain + "." + translations[ i ].key + "]";
				
				nodes = pendingTranslations[expression];
				
				if ( nodes != null ) {
					for (var j:int = 0; j < nodes.length; j++) {
						applyTranslation(nodes[j], expression, translations[i].value);
					}
				}
				
				delete( pendingTranslations[ expression ] );
			}
		}
		
		private function applyTranslation( node:Node, expression:String, translation:String ):void {
			var currentValue:String = node.nodeValue;
			var newValue:String = currentValue.replace(expression, translation);
			node.nodeValue = newValue;
		}
		
		public function LocalizationProvider( translator:AbstractTranslator ) {
			this.translator = translator;
			//translator.translationResult += provideTranslation;
			
			timer = new Timer( 10, 1 );
			timer.timerComplete.add( sendTranslationRequest );
			
			pendingTranslations = new Object();
		}

	}
}