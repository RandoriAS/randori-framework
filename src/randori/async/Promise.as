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
package randori.async {
	import randori.webkit.page.Window;

	public class Promise {
		public static const PENDING:int = 0;
		public static const REJECTED:int = 1;
		public static const FULLFILLED:int = 2;
		
		private var thenContracts:Array ;
		private var state:int = PENDING;
		
		public var value:*;
		public var reason:Object;
		
		private function isFunction( obj:* ):Boolean {
			return !!(obj && obj.constructor && obj.call && obj.apply);
		}

		//3.2.1 Both onFulfilled and onRejected are optional arguments
		public function then(onFulfilled:Function = null, onRejected:Function = null):Promise {
			var promise:Promise = new Promise();
			
			//3.2.1.1
			if (!isFunction(onFulfilled)) {
				onFulfilled = null;
			}
			
			//3.2.1.2
			if (!isFunction(onRejected)) {
				onRejected = null;
			}
			
			//3.2.5
			var thenContract:ThenContract = new ThenContract(onFulfilled, onRejected, promise);
			thenContracts.push( thenContract );
			
			var that:Promise = this;
			
			if (state == FULLFILLED) {
				//3.2.4
				Window.setTimeout( function():void {
					that.fullfill(value);
				}, 1);
			} else if (state == REJECTED) {
				//3.2.4
				Window.setTimeout( function():void {
					that.internalReject(reason);
				}, 1);
			}
			
			//3.2.6
			return promise;
		}
		
		public function resolve(response:*):void {
			//3.2.2 & 3.2.2.3
			if (state == PENDING) {
				
				//3.1.2.2
				this.value = response;
				
				fullfill(response);                    
			}
		}

		private function fullfill(response:*):void {
			
			//3.1.1.1
			state = FULLFILLED;
			
			//3.2.2.2
			while (thenContracts.length > 0) {
				var thenContract:ThenContract = thenContracts.shift();
				
				if (thenContract.fullfilledHandler != null) {
					
					try {
						//3.2.2.1 & 3.2.5.1
						var callBackResult:* = thenContract.fullfilledHandler( response );
						
						if ( callBackResult && callBackResult.then != null) {
							//3.2.6.3
							var returnedPromise:Promise = callBackResult;
							returnedPromise.then(
								function(innerResponse:*):void {
									//3.2.6.3.2
									thenContract.promise.resolve(innerResponse);
								},
								function(innerReason:Object):void {
									//3.2.6.3.3
									thenContract.promise.reject(innerReason);
								}
							);
						} else {
							//3.2.6.1
							thenContract.promise.resolve( callBackResult );
						} 
					} catch ( error:Error ) {
						//3.2.6.2
						thenContract.promise.reject( error );
					}
				} else {
					//3.2.6.4
					thenContract.promise.resolve(response);
				}
			}
		}

		public function reject(reason:Object):void {
			
			//3.2.3.3
			if (state == PENDING) {
				
				//3.1.3.2
				this.reason = reason;
				
				internalReject(reason);
			}
		}
		
		private function internalReject( reason:Object ):void {
			//3.1.1.1
			state = REJECTED;
			
			//3.2.3.2
			while (thenContracts.length > 0) {
				var thenContract:ThenContract = thenContracts.shift();
				
				if (thenContract.rejectedHandler != null) {
					try {
						
						//3.2.3.1 & 3.2.5.2
						var callBackResult:* = thenContract.rejectedHandler(reason);
						
						if (callBackResult && callBackResult.then != null) {
							//3.2.6.3
							var returnedPromise:Promise = callBackResult;
							returnedPromise.then(
								function(innerResponse:*):void {
									//3.2.6.3.2
									thenContract.promise.resolve(innerResponse);
								},
								function(innerReason:Object):void {
									//3.2.6.3.3
									thenContract.promise.reject(innerReason);
								}
							);
						} else {
							//3.2.6.1
							thenContract.promise.resolve(callBackResult);
						} 
					} catch (error:Error) {
						//3.2.6.2
						thenContract.promise.reject(error);
					}
				} else {
					//3.2.6.5
					thenContract.promise.reject(reason);
				}
			}
		}
		
		
		public function Promise() {
			this.thenContracts = new Array();
		}
	}
}
import randori.async.Promise;

[JavaScript(export="false",name="Object",mode="json")]
class ThenContract {
	public var fullfilledHandler:Function;
	public var rejectedHandler:Function;
	public var promise:Promise;
	
	public function ThenContract( fullfilledHandler:Function, rejectedHandler:Function, promise:Promise ) {
		this.fullfilledHandler = fullfilledHandler;
		this.rejectedHandler = rejectedHandler;
		this.promise = promise;
	}
}