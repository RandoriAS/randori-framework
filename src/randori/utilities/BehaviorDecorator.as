/***
 * Copyright 2012 LTN Consulting, Inc. /dba Digital Primates®
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
package randori.utilities {
	import randori.webkit.html.HTMLElement;

	public class BehaviorDecorator {
		
		/* Decorates an arbitrary object to create a behavior */
		public function decorateObject( behavior:* ):void {
			var futureBehavior:FutureBehavior  = behavior;
			
			futureBehavior.verifyAndRegister = verifyAndRegister;
			futureBehavior.provideDecoratedElement = provideDecoratedElement;
			futureBehavior.injectPotentialNode = injectPotentialNode;
			futureBehavior.removeAndCleanup = removeAndCleanup;
		}
		
		private static function verifyAndRegister():void {
		}
		
		private static function removeAndCleanup():void {
		}
		
		private static function provideDecoratedElement(element:HTMLElement ):void {
			
		}
		
		private static function injectPotentialNode( id:String, node:Object ):void {
		}

		public function BehaviorDecorator() {
		}
	}
}

[JavaScript(export="false")]
class FutureBehavior {
	public var verifyAndRegister:Function;
	public var removeAndCleanup:Function;
	public var provideDecoratedElement:Function;
	public var injectPotentialNode:Function;
}
