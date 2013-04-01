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
 * 
 * Idea borrowed from Robert Penner. Thanks Rob.
 * 
 * https://github.com/robertpenner/as3-signals
 * 
 */
package randori.startup {
	import guice.GuiceModule;
	import guice.binding.Binder;
	import guice.binding.Scope;
	
	import randori.i18n.AbstractTranslator;
	import randori.i18n.NoOpTranslator;
import randori.service.url.URLRewriterBase;
import randori.styles.StyleExtensionMap;

	public class RandoriModule extends GuiceModule {
        private var urlRewriter:URLRewriterBase;
		
		override public function configure(binder:Binder):void {
			//make the StyleExtensionMap a Singleton
			binder.bind(StyleExtensionMap).inScope(Scope.Singleton).to(StyleExtensionMap);
			
			//Setup a NoOp translator as the default
			binder.bind( AbstractTranslator ).to( NoOpTranslator );

            binder.bind( URLRewriterBase).toInstance( urlRewriter );
		}

		public function RandoriModule( urlRewriter:URLRewriterBase ) {
            this.urlRewriter = urlRewriter;
		}
	}
}