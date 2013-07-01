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
    import randori.jquery.Event;
    import guice.loader.URLRewriterBase;

import randori.service.httpRequest.HttpRequestHeader;
import randori.webkit.xml.XMLHttpRequest;
    import randori.webkit.xml.XMLHttpRequestProgressEvent;

	public class AbstractService {

        [Inject]
        public var urlRewriter:URLRewriterBase;

        protected var xmlHttpRequest:XMLHttpRequest;

        protected function createUri(protocol:String, host:String, port:String, path:String):String {
            var uri:String = "";

            if (( protocol != null ) && ( host != null )) {
                uri += ( protocol + "://" + host );
            }

            if (port != null) {
                uri = uri + ":" + port;
            }

            uri = uri + "/" + path;
            return uri;
        }

        protected function modifyHeaders( request:XMLHttpRequest ):void {

        }

        private function attachHeaders(request:XMLHttpRequest, httpRequestHeaders:Array):void {
            httpRequestHeaders.forEach(function (requestHeader:HttpRequestHeader):void {
                request.setRequestHeader(requestHeader.header, requestHeader.value);
            });
        }

        protected function sendRequest(httpRequestMethod:String, uri:String, data:String= "", httpRequestHeaders:Array = null):Promise {
            var promise:Promise = new Promise();
            var request:XMLHttpRequest = xmlHttpRequest;

            uri = urlRewriter.rewriteURL(uri);

            request.open(httpRequestMethod, uri, true);

            if(httpRequestHeaders) {
                attachHeaders(request, httpRequestHeaders);
            }

            request.onreadystatechange = function(evt:DomEvent):void {
                if (request.readyState == XMLHttpRequest.DONE) {
                    if (request.status >= 200 && request.status <=299) {
                        promise.resolve(request.responseText);
                    } else {
                        promise.reject(request.statusText);
                    }
                }
            };

            request.send(data);

            return promise;
        }

        protected function sendRequestFull(httpRequestMethod:String, protocol:String, host:String, port:String, path:String, data:String="", httpRequestHeaders:Array = null):Promise {
            return sendRequest(httpRequestMethod, createUri(protocol, host, port, path), data,  httpRequestHeaders);
        }

        public function AbstractService(xmlHttpRequest:XMLHttpRequest) {
            this.xmlHttpRequest = xmlHttpRequest;
        }
	}
}