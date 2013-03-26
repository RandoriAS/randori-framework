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
package randori.behaviors {
	import randori.behaviors.list.DataRendererProvider;
	import randori.dom.DomWalker;
	import randori.jquery.JQuery;
	import randori.jquery.JQueryStatic;
	import randori.template.TemplateBuilder;

	public class SimpleList extends AbstractBehavior {
		private var domWalker:DomWalker;
		
		[View(required = "false")]
		public var template:JQuery;
		
		[Inject]
		public var templateBuilder:TemplateBuilder;

		protected var _renderFunction:Function;
		public function get renderFunction():Function {
			return _renderFunction;
		}

		public function set renderFunction(value:Function):void {
			_renderFunction = value;
		}
		
		protected var _data:Array;
		public function get data():Array {
			return _data;
		}
		
		public function set data(value:Array):void {
			_data = value;
			renderList();
		}

		public function renderList():void {
			var row:JQuery;
			var div:JQuery = JQueryStatic.J("<div></div>");
			if ((data == null) || (data.length == 0)) {
				showNoResults();
				return;
			}
			
			if ((!templateBuilder.validTemplate) && renderFunction == null) return;
			
			if (templateBuilder.validTemplate) {
				for (var i:int = 0; i < data.length; i++) {
					var drp:DataRendererProvider = new DataRendererProvider( data[ i ] );
					row = templateBuilder.renderTemplateClone(data[i]).children();
					domWalker.walkDomFragment(row[0], drp);
					row.addClass("randoriListItem");
					div.append(row);
				}
			} else if (renderFunction != null) {
				for (var j:int = 0; j < data.length; j++) {
					row = renderFunction(j, data[j]);
					domWalker.walkDomFragment(row[0], this);
					row.addClass("randoriListItem");
					div.append(row);
				}
			}
			
			decoratedNode.empty();
			decoratedNode.append(div.children());
		}

		override protected function onPreRegister():void {
			super.onPreRegister();
			
			templateBuilder.captureAndEmptyTemplateContents(decoratedNode);
		}
		
		override protected function onRegister():void {
			//adds a listener to the root element
			//fires click whenever a .listItem is clicked
			renderList();
		}
		
		override protected function onDeregister():void {
			this.data = null;
			decoratedNode.empty();
		}

		public function showLoading():void {
			var output:String = "<div style=\"height:100%; width:100%;\"><div style=\"text-align:center;width:100%;top:60%;position:absolute\">Loading...</div></div>";
			
			decoratedNode.html2(output);
		}
		
		private function showNoResults(visible:Boolean = true):void {
			var output:String = "<div style=\"height:100%; width:100%;\"><div style=\"text-align:center;width:100%;top:60%;position:absolute\">No Items Found</div></div>";
			
			decoratedNode.html2(output);
		}

		
		public function SimpleList( domWalker:DomWalker ) {
			super();
			
			this.domWalker = domWalker;
		}
	}
}