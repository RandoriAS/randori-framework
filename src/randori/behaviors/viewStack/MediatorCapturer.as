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
package randori.behaviors.viewStack {
	import randori.behaviors.AbstractBehavior;
	import randori.behaviors.AbstractMediator;
	
	public class MediatorCapturer extends AbstractBehavior {
		
		private var _mediator:AbstractMediator;
		
		public function get mediator():AbstractMediator {
			return _mediator;
		}
		
		override protected function onDeregister():void {
			_mediator = null;
		}
		
		override public function injectPotentialNode(id:String, node:Object ):void {
			//Ugly hack for the moment, figure out a better way to handle by checking the identity... somehow... of this class
			var behavior:* = node;
			if (_mediator == null && behavior.setViewData != null) {
				_mediator = behavior;
			}
		}


		public function MediatorCapturer() {
			super();
		}
	}
}