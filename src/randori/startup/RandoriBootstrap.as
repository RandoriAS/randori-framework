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
import guice.IInjector;
import guice.loader.SynchronousClassLoader;
import guice.loader.URLRewriterBase;
import guice.reflection.TypeDefinition;
import guice.reflection.TypeDefinitionFactory;

import randori.dom.DomWalker;
import randori.service.url.URLCacheBuster;
import randori.utilities.PolyFill;
import randori.webkit.dom.Node;
import randori.webkit.xml.XMLHttpRequest;

public class RandoriBootstrap {
	private var rootNode:Node;

	public function launch( debugMode:Boolean=false, dynamicClassBaseUrl:String = "generated/" ):void {

		//We are going to do a few convenience things here
		//first, build a default console object for IE
		PolyFill.fillConsoleForIE();
		PolyFill.fillIndexOf();

		/**This part is due for a refactor coming by .2.5**/
		var urlRewriter:URLRewriterBase;

		if ( debugMode ) {
			urlRewriter = new URLCacheBuster();
		} else {
			urlRewriter = new URLRewriterBase();
		}

		if ( dynamicClassBaseUrl == null ) {
			dynamicClassBaseUrl = "generated/";
		}

		var loader:SynchronousClassLoader =
				new SynchronousClassLoader(new XMLHttpRequest(), urlRewriter, dynamicClassBaseUrl );

		//Create the injector that will be used in the application
		var guiceJs:GuiceJs = new GuiceJs( loader );

		var factory:TypeDefinitionFactory = new TypeDefinitionFactory();
		var td:TypeDefinition = factory.getDefinitionForType( RandoriModule );
		var classDependencies:Vector.<String> = td.getRuntimeDependencies();

		for ( var i:int=0; i<classDependencies.length; i++) {
			//this will either find the definition or force a proxy to be created for each
			factory.getDefinitionForName( classDependencies[i] );
		}

		var module:* = new RandoriModule( urlRewriter );
		var injector:IInjector = guiceJs.createInjector(new RandoriModule( urlRewriter ));

		var domWalker:DomWalker = injector.getInstance(DomWalker) as DomWalker;
		domWalker.walkDomFragment(rootNode);
	}

	public function RandoriBootstrap( rootNode:Node ) {
		this.rootNode = rootNode;
	}
}
}