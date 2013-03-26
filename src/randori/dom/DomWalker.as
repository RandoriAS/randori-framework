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
	import guice.InjectionClassBuilder;

	import randori.behaviors.AbstractBehavior;
	import randori.data.HashMap;
	import randori.i18n.LocalizationProvider;
	import randori.jquery.JQueryStatic;
	import randori.styles.StyleExtensionManager;
	import randori.webkit.dom.Node;
	import randori.webkit.html.HTMLElement;
	import randori.webkit.html.HTMLLinkElement;

	public class DomWalker {
		private var domExtensionFactory:DomExtensionFactory;
		private var classBuilder:InjectionClassBuilder;
		private var elementDescriptorFactory:ElementDescriptorFactory;
		private var styleExtensionManager:StyleExtensionManager;
		private var localizationProvider:LocalizationProvider;

		private var extensionsToBeApplied:HashMap;
		//An entry element is the first real element we foind in this particular DomWalker instance
		private var entryElement:HTMLElement;

		private function investigateLinkElement(element:HTMLLinkElement):void {
			if (styleExtensionManager.parsingNeeded(element)) {
				styleExtensionManager.parseAndReleaseLinkElement(element);
				//we must rebuild our stylemanager cache if we find a style sheet in this walk. Do so from our entryElement
				extensionsToBeApplied = styleExtensionManager.getExtensionsForFragment(entryElement);
			}
		}

		private function investigateDomElement(element:HTMLElement, parentBehavior:AbstractBehavior):void {
			var currentBehavior:AbstractBehavior = parentBehavior;
			var domWalker:DomWalker = this;

			var id:String = element.getAttribute("id");

			if (id != null) {
				//we have a reference to the element now, so remove the id so we dont have to deal with conflicts and clashes
				element.removeAttribute("id");
			}

			var elementDescriptor:ElementDescriptor = elementDescriptorFactory.describeElement(element, extensionsToBeApplied);

			if (elementDescriptor.context != null) {
				//change the class builder for everything under this point in the DOM
				classBuilder = domExtensionFactory.buildChildClassBuilder(classBuilder, element, elementDescriptor.context);
				//change the domWalker for everything under this point in the DOM
				domWalker = classBuilder.buildClass("randori.dom.DomWalker") as DomWalker;
			}

			if (elementDescriptor.behavior != null) {
				//build a context for this behavior IF it turns out that this particular element defines one
				currentBehavior = domExtensionFactory.buildBehavior(classBuilder, element, elementDescriptor.behavior);

				//we have a new behavior, this effectively causes us to use a new context for the nodes below it
				//Make sure we add ourselves to our parent though
				if (parentBehavior != null) {
					parentBehavior.injectPotentialNode(id, currentBehavior);
				}

			} else {
				if (id != null && currentBehavior != null) {
					currentBehavior.injectPotentialNode(id, JQueryStatic.J(element));
				}
			}

			if (elementDescriptor.fragment != null) {
				//build a context for this behavior IF it turns out that this particular element defines one
				domExtensionFactory.buildNewContent(element, elementDescriptor.fragment);
				//change the domWalker for everything under this point in the DOM
				domWalker = classBuilder.buildClass("randori.dom.DomWalker") as DomWalker;
			}

			domWalker.walkChildren(element, currentBehavior);

			//Now that we have figured out all of the items under this dom element, setup the behavior
			if (currentBehavior != null && currentBehavior != parentBehavior) {
				currentBehavior.verifyAndRegister();
			}
		}

		private function investigateNode(node:Node, parentBehavior:AbstractBehavior):void {

			if (node.nodeType == Node.ELEMENT_NODE) {

				if (extensionsToBeApplied == null) {
					//We build our extension cache from the first element we find
					entryElement = node as HTMLElement;
					extensionsToBeApplied = styleExtensionManager.getExtensionsForFragment(entryElement);
				}

				//Just an optimization, need to create constants for all of these things.... removed as kendo uses script nodes for templates node.nodeName == "SCRIPT" || 
				if (node.nodeName == "META") {
					return;
				}

				if (node.nodeName == "LINK") {
					investigateLinkElement(node as HTMLLinkElement);
				} else {
					investigateDomElement(node as HTMLElement, parentBehavior);
				}

			} else if (node.nodeType == Node.TEXT_NODE) {
				//This is a text node, check to see if it needs internationalization
				localizationProvider.investigateTextNode(node);
			} else {
				walkChildren(node, parentBehavior);
			}
		}

		private function walkChildren(parentNode:Node, parentBehavior:AbstractBehavior=null):void {
			var node:Node = parentNode.firstChild;

			if (extensionsToBeApplied == null && (parentNode.nodeType == Node.ELEMENT_NODE)) {
				//We build our extension cache from the first element we find
				entryElement = parentNode as HTMLElement;
				extensionsToBeApplied = styleExtensionManager.getExtensionsForFragment(entryElement);
			}

			while (node != null) {
				investigateNode(node, parentBehavior);
				node = node.nextSibling;
			}
		}

		public function walkDomChildren(parentNode:Node, parentBehavior:AbstractBehavior=null):void {
			//The fact that we have two entry point into here walkChildren and walkDomFragment continues to screw us
			walkChildren(parentNode, parentBehavior);

			//free this for GC when we are done, it has references to a lot of DOM elements
			this.extensionsToBeApplied = null;
		}

		public function walkDomFragment(node:Node, parentBehavior:AbstractBehavior=null):void {

			investigateNode(node, parentBehavior);

			//free this for GC when we are done, it has references to a lot of DOM elements
			this.extensionsToBeApplied = null;
		}

		public function DomWalker(domExtensionFactory:DomExtensionFactory, classBuilder:InjectionClassBuilder, elementDescriptorFactory:ElementDescriptorFactory, styleExtensionManager:StyleExtensionManager, localizationProvider:LocalizationProvider) {
			this.domExtensionFactory = domExtensionFactory;
			this.classBuilder = classBuilder;
			this.elementDescriptorFactory = elementDescriptorFactory;
			this.styleExtensionManager = styleExtensionManager;
			this.localizationProvider = localizationProvider;
		}
	}
}
