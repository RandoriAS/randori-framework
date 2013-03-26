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
	
	import randori.dom.DomWalker;
	import randori.webkit.dom.Node;

	public class RandoriBootstrap {
		private var rootNode:Node;
		
		public function launch():void {
			//Create the injector that will be used in the application
			var guiceJs:GuiceJs = new GuiceJs();
			var injector:Injector = guiceJs.createInjector(new RandoriModule());
			
			var domWalker:DomWalker = injector.getInstance(DomWalker) as DomWalker;
			domWalker.walkDomFragment(rootNode);
		}

		public function RandoriBootstrap( rootNode:Node ) {
			this.rootNode = rootNode;
		}
	}
}