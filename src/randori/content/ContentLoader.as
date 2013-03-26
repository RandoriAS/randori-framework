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
	import randori.async.Promise;
	import randori.service.AbstractService;
	import randori.webkit.xml.XMLHttpRequest;

	public class ContentLoader extends AbstractService {
		
		private var contentCache:ContentCache;
		
		public function synchronousFragmentLoad(fragmentURL:String):String {
			//We need to check to see if we already have this content. If we do not, then we need to load it now and insert it into the DOM
			
			var cachedContent:String = contentCache.getCachedHtmlForUri(fragmentURL);
			if (cachedContent != null) {
				return cachedContent;
			}
			
			//Else load it now
			xmlHttpRequest.open( "GET", fragmentURL, false );
			xmlHttpRequest.send();
			
			if ( xmlHttpRequest.status == 404 )
			{
				throw new Error("Cannot continue, missing required content " + fragmentURL);
			}
			
			return xmlHttpRequest.responseText;
		}

		public function asynchronousLoad(fragmentURL:String):Promise {
			return sendRequest( "GET", fragmentURL ).then( 
				function( value:Object ):Object {
					return value;
				} );
		}
		
		public function ContentLoader( contentCache:ContentCache, xmlHttpRequest:XMLHttpRequest ) {
			this.contentCache = contentCache;
			super( xmlHttpRequest );
		}
	}
}