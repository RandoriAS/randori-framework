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
	import randori.data.HashMap;
	import randori.styles.StyleExtensionManager;
	import randori.styles.StyleExtensionMapEntry;
	import randori.webkit.html.HTMLElement;

	public class ElementDescriptorFactory {
		private var styleExtensionManager:StyleExtensionManager;

		public function describeElement(element:HTMLElement, possibleExtensions:HashMap ):ElementDescriptor {
			//This is purely an efficiency gain. By making a merged map for this one element, we stop everyone from cycling through 
			//every class on an element to pull out their own piece of data
			var entry:StyleExtensionMapEntry = possibleExtensions.get(element);
			var descriptor:ElementDescriptor = new ElementDescriptor (
					element.getAttribute("data-context"),
					element.hasAttribute("data-mediator") ? element.getAttribute("data-mediator") : element.getAttribute("data-behavior"),
					element.getAttribute("data-fragment"),
					element.getAttribute( "data-formatter" ),
					element.getAttribute( "data-validator" )
			);
			
			if ( entry != null ) {
				if (descriptor.context == null) {
					descriptor.context = entry.getExtensionValue("context");
				} 
				
				if (descriptor.behavior == null) {
					//mediator and behavior are really the same thing and hence mutually exclusive
					descriptor.behavior = entry.hasExtensionType("mediator")?entry.getExtensionValue("mediator"):entry.getExtensionValue("behavior");
				} 
				
				if (descriptor.fragment == null) {
					descriptor.fragment = entry.getExtensionValue("fragment");
				} 
				
				if (descriptor.formatter == null) {
					descriptor.formatter = entry.getExtensionValue("formatter");
				} 
				
				if (descriptor.validator == null) {
					descriptor.validator = entry.getExtensionValue("validator");
				} 
			}
			
			return descriptor;
		}
		
		public function ElementDescriptorFactory( styleExtensionManager:StyleExtensionManager ) {
			this.styleExtensionManager = styleExtensionManager;
		}
	}
}