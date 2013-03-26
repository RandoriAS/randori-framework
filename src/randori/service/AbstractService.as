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
package randori.service {
	
	import randori.async.Promise;
	import randori.webkit.dom.DomEvent;
	import randori.webkit.xml.XMLHttpRequest;

	public class AbstractService {
		protected var xmlHttpRequest:XMLHttpRequest;
		
		protected function createUri( protocol:String, host:String, port:String, path:String ):String {
			var uri:String = "";
			
			if ( ( protocol != null ) && ( host != null ) ) {
				uri += ( protocol + "://" + host );    
			}
			
			if ( port != null ) {
				uri = uri + ":" + port;
			}
			
			uri = uri + "/" + path;
			return uri;
		}
		
		protected function modifyHeaders( request:XMLHttpRequest ):void {
			
		}

		protected function sendRequest(verb:String, uri:String):Promise {
			var promise:Promise = new Promise();
			
			xmlHttpRequest.open(verb, uri, true);
			//xmlHttpRequest.withCredentials = true;
			xmlHttpRequest.onreadystatechange = function(evt:DomEvent):void {
				var request:XMLHttpRequest = evt.target as XMLHttpRequest;
				
				if (request.readyState == XMLHttpRequest.DONE) {
					if (request.status == 200) {
						promise.resolve(request.responseText);
					} else {
						promise.reject(request.statusText);
					}
				}
			};
			
			modifyHeaders(xmlHttpRequest);
			
			xmlHttpRequest.send();
			
			return promise;
		}

		protected function sendRequestFull( verb:String, protocol:String, host:String, port:String, path:String ):Promise {
			return sendRequest( verb, createUri( protocol, host, port, path ) );
		}

		public function AbstractService( xmlHttpRequest:XMLHttpRequest ) {
			this.xmlHttpRequest = xmlHttpRequest;
		}
	}
}