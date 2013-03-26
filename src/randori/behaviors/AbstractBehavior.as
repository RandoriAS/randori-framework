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
	import guice.reflection.InjectionPoint;
	import guice.reflection.TypeDefinition;

	import randori.jquery.JQuery;
	import randori.jquery.JQueryStatic;
	import randori.webkit.html.HTMLElement;
	import randori.webkit.page.Window;

	public class AbstractBehavior {
		protected var viewElementIDMap:Object;
		protected var viableInjectionPoints:Object;
		protected var decoratedElement:HTMLElement;
		protected var decoratedNode:JQuery;
		protected var injectedPoints:Array;

		//This highlights the need for some type of decorator more than an extension methodology for something becoming a behavior
		public function hide():void {
			decoratedNode.hide();
		}

		public function show():void {
			decoratedNode.show();
		}

		protected function getViewElementByID(id:String):Object {
			return viewElementIDMap[id];
		}

		//Its possible we want to do some things before our children are parsed..
		//This helps facilitate us being a black box
		protected function onPreRegister():void {
			//setup our injection point requirements
			if (this.viableInjectionPoints == null) {
				this.viableInjectionPoints = getBehaviorInjectionPoints();
			}
		}

		protected function onRegister():void {

		}

		protected function onDeregister():void {

		}

		public function injectPotentialNode(id:String, node:Object):void {

			//by default dont inject if we dont have an id... we would have no way to reference it 
			//if we ever want to throw an error because of a duplicate id injection, this is the place to do it
			//right now first one in wins
			if ((id != null) && (viableInjectionPoints != null) && (viableInjectionPoints[id] != null)) {
				delete(viableInjectionPoints[id]);
				var instance:* = this;
				instance[id] = node;
				injectedPoints.push(id);
			}
		}

		public function provideDecoratedElement(element:HTMLElement):void {
			this.decoratedElement = element;

			this.decoratedNode = JQueryStatic.J(decoratedElement);
			onPreRegister();
		}

		public function verifyAndRegister():void {
			for each (var id:String in viableInjectionPoints) {
				if (viableInjectionPoints[id] == "req") {
					var instance:* = this;
					var typeDefinition:TypeDefinition = new TypeDefinition(instance.constructor);

					//Revisit me when we resolve window approach
					Window.alert(typeDefinition.getClassName() + " requires a [View] element with the id of " + id + " but it could not be found");
					throw new Error(typeDefinition.getClassName() + " requires a [View] element with the id of " + id + " but it could not be found");
					return;
				}

				delete viableInjectionPoints[id];
			}

			this.viableInjectionPoints = null;
			onRegister();
		}

		public function removeAndCleanup():void {
			var instance:* = this;
			var injection:*;

			onDeregister();

			for (var i:int = 0; i < injectedPoints.length; i++) {
				injection = instance[injectedPoints[i]];
				if ((injection != null) && (injection.removeAndCleanup != null)) {
					injection.removeAndCleanup();
				}
			}

			injectedPoints = new Array();
		}

		private function getBehaviorInjectionPoints():Object {
			var instance:* = this;

			var map:Object = new Object();
			var typeDefinition:TypeDefinition = new TypeDefinition(instance.constructor);

			var viewPoints:Vector.<InjectionPoint> = typeDefinition.getViewFields();

			for (var i:int = 0; i < viewPoints.length; i++) {
				if (viewPoints[i].r == 0) {
					map[viewPoints[i].n] = "opt";
				} else {
					map[viewPoints[i].n] = "req";
				}
			}

			return map;
		}

		public function AbstractBehavior() {
			injectedPoints = new Array();
		}
	}
}
