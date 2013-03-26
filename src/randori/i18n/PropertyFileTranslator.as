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
	import randori.webkit.dom.DomEvent;
	import randori.webkit.page.Window;
	import randori.webkit.xml.XMLHttpRequest;

	public class PropertyFileTranslator extends AbstractTranslator {
		
		private var url:String;
		
		private var keyValuePairs:Object;
		private var forceReload:Boolean;
		private var fileLoaded:Boolean = false;
		
		override public function synchronousTranslate(domain:String, keys:Vector.<String>):Vector.<Translation> {
			if (!fileLoaded) {
				makeSynchronousRequest( url );
			}
			
			return provideTranslations(domain, keys);			
		}
		
		override public function translate(domain:String, keys:Vector.<String>):void {
			if (!fileLoaded) {
				makeAsynchronousRequest(url, function():void {
					//The data is back, translate
					var translations:Vector.<Translation> = provideTranslations(domain, keys);
					
					translationResult.dispatch(domain, translations); 
				} );
			} else {
				//We already have the file, so just translate
				var translations:Vector.<Translation> = provideTranslations(domain, keys);
				
				translationResult.dispatch(domain, translations);
			}			
		}
		
		private function provideTranslations(domain:String, keys:Vector.<String>):Vector.<Translation> {
			var translations:Vector.<Translation> = new Vector.<Translation>();
			var translation:Translation;
			
			for (var i:int = 0; i < keys.length; i++) {
				translation = new Translation();
				translation.key = keys[i];
				translation.value = keyValuePairs[keys[i]];
				translations.push(translation);
			}
			
			return translations;
		}
		
		private function makeSynchronousRequest(url:String):void {
			var request:XMLHttpRequest = new XMLHttpRequest();
			
			if (forceReload) {
				//just bust the cache for now
				url = url + "?rnd=" + Math.random();
			}
			
			request.open("GET", url, false);
			request.send();
			
			if (request.status == 404) {
				Window.alert("Required Content " + url + " cannot be loaded.");
				throw new Error("Cannot continue, missing required property file " + url);
			}
			
			parseResult(request.responseText);
		}

		private function makeAsynchronousRequest( url:String, fileLoaded:Function ):void {
			var request:XMLHttpRequest = new XMLHttpRequest();
			
			if (forceReload) {
				//just bust the cache for now
				url = url + "?rnd=" + Math.random();
			}
			
			request.open("GET", url, true);
			request.onreadystatechange = function( evt:DomEvent ):void {
				if ( request.readyState == 4 && request.status == 200 ) {
					parseResult( request.responseText );
					fileLoaded();
				} else if ( request.readyState >= 3 && request.status == 404 ) {
					Window.alert( "Required Content " + url + " cannot be loaded." );
					throw new Error( "Cannot continue, missing required property file " + url );
				}
			};
			
			request.send();
		}
		
		private function parseResult( responseText:String ):void {
			//get each line
			var eachLine:RegExp = new RegExp("[\\w\\W]+?[\\n\\r]+", "g");
			var eachLineResult:Array = responseText.match( eachLine );
			
			this.fileLoaded = true;
			
			if (eachLineResult != null) {
				for ( var i:int=0;i<eachLineResult.length;i++) {
					parseLine( eachLineResult[ i ] );
				}
			}
		}
		
		private function parseLine(line:String):void {
			
			if ( line.length == 0 ) {
				//empty line, bail
				return;
			}
			
			var isComment:RegExp = new RegExp("^[#!]");
			var isCommentResult:Array = line.match(isComment);
			
			if ( isCommentResult != null ) {
				//its a comment, bail
				return;
			}
			
			var tokenize:RegExp = new RegExp("^(\\w+)\\s?=\\s?([\\w\\W]+?)[\\n\\r]+");
			var tokenizeResult:Array = line.match(tokenize);
			var key:String;
			var strValue:String;
			var value:*;
			
			if ( tokenizeResult != null && tokenizeResult.length == 3) {
				key = tokenizeResult[ 1 ];
				value = tokenizeResult[ 2 ];
				
				strValue = value;
				if (strValue.indexOf( "," ) != -1 ) {
					//this is an array, tokenize it
					value = strValue.split( ',' );
				}
				
				keyValuePairs[ key ] = value;
			}
		}

		
		public function PropertyFileTranslator( translationResult:SimpleSignal, url:String, forceReload:Boolean = false) {
			super( translationResult );
			this.url = url;
			this.forceReload = forceReload;
			keyValuePairs = new Object();
		}
	}
}