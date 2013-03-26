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
	import randori.dom.DomWalker;
	import randori.jquery.JQuery;
	import randori.jquery.JQueryStatic;
	import randori.signal.SimpleSignal;
	import randori.webkit.dom.DomEvent;

	public class List extends SimpleList {
		
		protected var _selectedItem:Object;
		protected var _selectedIndex:int;
		
		public var listChanged:SimpleSignal;

		public function get selectedItem():Object {
			return _data[_selectedIndex];
		}
		
		public function set selectedItem(value:Object):void {
			if (_data == null) {
				return;
			}
			
			for (var i:int = 0; i < _data.length; i++) {
				if (value == _data[i]) {
					selectedIndex = i;
					break;
				}
			}
		}

		public function get selectedIndex():int {
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void {
			_selectedIndex = value;
			decoratedNode.children().removeClass("selected");
			if ( _data && _data.length >=  value ) {
				if (value > -1 && value < decoratedNode.children().length) {
					decoratedNode.children().eq(value).addClass("selected");
	
					listChanged.dispatch(value, data[value]);
				}
			}
		}

		override protected function onRegister():void {
			super.onRegister();
			
			//adds a listener to the root element
			//fires click whenever a .listItem is clicked
			decoratedNode.delegate(".randoriListItem", "click", onItemClick);
		}
		
		override public function renderList():void {
			super.renderList();
			selectedIndex = 0;
		}

		protected function onItemClick(e:DomEvent):void {
			var targetJq:JQuery = JQueryStatic.J(e.currentTarget);
			var index:int = targetJq.index();
			selectedIndex = index;
		}

		public function List( walker:DomWalker ) {
			super( walker );
			
			listChanged = new SimpleSignal();
		}

	}
}