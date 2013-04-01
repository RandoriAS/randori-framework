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
package randori.startup {
	import guice.GuiceJs;
	import guice.Injector;
import guice.loader.SynchronousClassLoader;

import randori.dom.DomWalker;
import randori.service.url.URLCacheBuster;
import guice.loader.URLRewriterBase;
import randori.utilities.PolyFill;
import randori.webkit.dom.Node;
import randori.webkit.xml.XMLHttpRequest;

public class RandoriBootstrap {
		private var rootNode:Node;
		
		public function launch( debugMode:Boolean=false, dynamicClassBaseUrl:String = "generated/" ):void {

            //We are going to do a few convenience things here
            //first, build a default console object for IE
            PolyFill.fillConsoleForIE();

            /**This part is due for a refactor coming by .2.5**/
            var urlRewriter:URLRewriterBase;

            if ( debugMode ) {
                urlRewriter = new URLCacheBuster();
            } else {
                urlRewriter = new URLRewriterBase();
            }

            var loader:SynchronousClassLoader =
                    new SynchronousClassLoader(new XMLHttpRequest(), urlRewriter, dynamicClassBaseUrl );

            //Create the injector that will be used in the application
			var guiceJs:GuiceJs = new GuiceJs( loader );
			var injector:Injector = guiceJs.createInjector(new RandoriModule( urlRewriter ));
			
			var domWalker:DomWalker = injector.getInstance(DomWalker) as DomWalker;
			domWalker.walkDomFragment(rootNode);
		}

		public function RandoriBootstrap( rootNode:Node ) {
			this.rootNode = rootNode;
		}
	}
}