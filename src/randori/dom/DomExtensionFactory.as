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
package randori.dom {
	import guice.ChildInjector;
	import guice.GuiceJs;
	import guice.GuiceModule;
	import guice.InjectionClassBuilder;
	import guice.reflection.TypeDefinition;
	import guice.resolver.ClassResolver;

	import randori.behaviors.AbstractBehavior;
	import randori.content.ContentLoader;
	import randori.jquery.JQueryStatic;
	import randori.webkit.html.HTMLElement;

	public class DomExtensionFactory {
		private var contentLoader:ContentLoader;
		private var classResolver:ClassResolver;
		private var externalBehaviorFactory:ExternalBehaviorFactory;

		public function buildBehavior(classBuilder:InjectionClassBuilder, element:HTMLElement, behaviorClassName:String):AbstractBehavior {
			var behavior:AbstractBehavior = null;

			var resolution:TypeDefinition = classResolver.resolveClassName(behaviorClassName);

			if (resolution.builtIn) {
				/** If we have a type which was not created via Randori, we send it out to get created. In this way
				 * we dont worry about injection data and we allow for any crazy creation mechanism the client can
				 * consider **/
				behavior = externalBehaviorFactory.createExternalBehavior(element, behaviorClassName, resolution.type);
			} else {
				behavior = classBuilder.buildClass(behaviorClassName) as AbstractBehavior;
				behavior.provideDecoratedElement(element);
			}

			return behavior;
		}

		public function buildNewContent(element:HTMLElement, fragmentURL:String):void {
			JQueryStatic.J(element).append(contentLoader.synchronousFragmentLoad(fragmentURL));
		}

		public function buildChildClassBuilder(classBuilder:InjectionClassBuilder, element:HTMLElement, contextClassName:String):InjectionClassBuilder {
			var module:GuiceModule = classBuilder.buildClass(contextClassName) as GuiceModule;
			var injector:ChildInjector = classBuilder.buildClass("guice.ChildInjector") as ChildInjector;

			//This is a problem, refactor me
			var guiceJs:GuiceJs = new GuiceJs();
			guiceJs.configureInjector(injector, module);

			//Setup a new InjectionClassBuilder
			return injector.getInstance(InjectionClassBuilder) as InjectionClassBuilder;
		}


		public function DomExtensionFactory(contentLoader:ContentLoader, classResolver:ClassResolver, externalBehaviorFactory:ExternalBehaviorFactory) {
			this.contentLoader = contentLoader;
			this.classResolver = classResolver;
			this.externalBehaviorFactory = externalBehaviorFactory;
		}
	}
}
