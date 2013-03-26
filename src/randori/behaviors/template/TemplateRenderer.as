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
package randori.behaviors.template {
	import randori.behaviors.AbstractBehavior;
	import randori.dom.DomWalker;
	import randori.jquery.JQuery;
	import randori.template.TemplateBuilder;
	
	public class TemplateRenderer extends AbstractBehavior {
		private var domWalker:DomWalker;
		private var templateBuilder:TemplateBuilder;
		
		protected var _data:Object;

		public function get data():Object {
			return _data;
		}

		public function set data(value:Object):void {
			if (value == _data) 
				return;

			_data = value;
			renderMessage();
		}
		
		override protected function onPreRegister():void {
			super.onPreRegister();
			
			templateBuilder.captureAndEmptyTemplateContents(decoratedNode);
		}

		protected function renderMessage():void {
			//If the first part of the newNode is text and not an actual node, jQuery loses it during an append
			//So this is the only method I have been able to figure out that actually keeps those first text nodes
			//which is really important during templating
			var newNode:JQuery = templateBuilder.renderTemplateClone(data);
			decoratedNode.html2(newNode.html());
			domWalker.walkDomChildren(decoratedElement, this);
		}
		
		override protected function onDeregister():void {
			this.data = null;
			decoratedNode.empty();
		}
		
		public function TemplateRenderer( domWalker:DomWalker, templateBuilder:TemplateBuilder) {
			super();
			this.domWalker = domWalker;
			this.templateBuilder = templateBuilder;
		}

	}
}