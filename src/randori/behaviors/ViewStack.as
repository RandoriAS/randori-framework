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
import randori.async.Promise;
import randori.behaviors.viewStack.MediatorCapturer;
import randori.behaviors.viewStack.ViewChangeAnimator;
import randori.content.ContentLoader;
import randori.content.ContentParser;
import randori.dom.DomWalker;
import randori.jquery.JQuery;
import randori.jquery.JQueryStatic;
import randori.webkit.html.HTMLDivElement;

public class ViewStack extends AbstractBehavior {

	private var contentLoader:ContentLoader;
	private var contentParser:ContentParser;
	private var viewChangeAnimator:ViewChangeAnimator;
	private var domWalker:DomWalker;

	private var _currentView:JQuery;
	private var viewFragmentStack:Vector.<JQuery>;
	private var mediators:Object;

	public function get currentViewUrl():String {
		return ( (_currentView != null)?( _currentView.data3("url") as String ):null );
	}

	public function hasView( url:String ):Boolean {
		var fragment:JQuery = decoratedNode.find("[data-url='" + url + "']");

		return ((fragment != null) && fragment.length>0);
	}

	public function pushView( url:String ):Promise {
		var promise:Promise;

		var stack:ViewStack = this;
		var div:HTMLDivElement = new HTMLDivElement();
		var fragment:JQuery = JQueryStatic.J(div);
		fragment.hide();
		fragment.css3("width", "100%");
		fragment.css3("height", "100%");
		fragment.css3("position", "absolute");
		fragment.css3("top", "0");
		fragment.css3("left", "0");
		fragment.data( "url", url ) ;

		var that:ViewStack = this;
		promise = contentLoader.asynchronousLoad(url).then(
			function(result:String):AbstractMediator {
				var content:String = that.contentParser.parse(result);
				var viewStackID:Number = new Date().getTime();

				fragment.html2(content);
				fragment.attr2( "data-url", url );
				fragment.attr2( "data-viewstackid", viewStackID );
				that.decoratedNode.append(div);

				var mediatorCapturer:MediatorCapturer = new MediatorCapturer();
				that.domWalker.walkDomFragment(div, mediatorCapturer);

				that.viewFragmentStack.push(fragment);
				var mediator:AbstractMediator = mediatorCapturer.mediator;
				that.mediators[ viewStackID ] = mediator;

				that.showView(that._currentView, fragment);
				that._currentView = fragment;

				return mediator;
			}
		);

		return promise;
	}


	public function popView():void {
		var oldView:JQuery = viewFragmentStack.pop();
		if (oldView != null ) {
			oldView.remove();
			var viewStackID:String = oldView.data3( "viewstackid" ) as String;
			var mediator:AbstractMediator = mediators[ viewStackID ];

			if (mediator != null ) {
				mediator.removeAndCleanup();
				delete mediators[ viewStackID ];
			}

		}

		if ( viewFragmentStack.length > 0 ) {
			_currentView = viewFragmentStack[ viewFragmentStack.length - 1 ];
			if ( _currentView != null ) {
				_currentView.show();
			}
		} else {
			_currentView = null;
		}
	}

	public function empty():void {
		//Pop all views
		while ( viewFragmentStack.length > 0 ) {
			var oldView:JQuery = viewFragmentStack.pop();
			if (oldView != null ) {
				oldView.remove();
				var viewStackID:String = oldView.data3( "viewstackid" ) as String;
				var mediator:AbstractMediator = mediators[ viewStackID ];

				if (mediator != null ) {
					mediator.removeAndCleanup();
					delete mediators[ viewStackID ];
				}
			}
		}

		_currentView = null;
	}

	public function selectView( url:String ):void {

		var fragment:JQuery;

		if ( currentViewUrl != url ) {
			var foundIndex:int = -1;
			for ( var i:int = 0; i<viewFragmentStack.length; i++ ) {
				fragment = viewFragmentStack[i];
				if ( fragment.data3( "url" ) == url ) {
					//found the one
					foundIndex = i;
					break;
				}
			}

			if ( foundIndex > -1 ) {
				//remove it from the viewFragmentStack
				fragment = ( viewFragmentStack.splice( foundIndex, 1 ) )[0];

				//move it to the top of the dom children
				fragment.detach();
				decoratedNode.append( fragment );

				//move it to the top of the vector
				viewFragmentStack.push( fragment );

				showView( _currentView, fragment );

				_currentView = fragment;
			} else {
				throw new Error("Unknown View");
			}
		}
	}

	private function showView( oldFragment:JQuery, newFragment:JQuery ):void  {
		if (oldFragment != null) {
			oldFragment.hide();
		}

		if (newFragment != null) {
			newFragment.show();
		}
	}

	private function transitionViews(arrivingView:JQuery, departingView:JQuery, data:Object = null):JQuery {
		return null;
	}

	override protected function onRegister():void {
		mediators = new Object();

		//We may eventually want to look for existing elements and hold onto them... not today
		decoratedNode.empty();
	}

	override protected function onDeregister():void  {
		mediators = new Object();

		decoratedNode.empty();
	}

	public function ViewStack( contentLoader:ContentLoader, contentParser:ContentParser, domWalker:DomWalker, viewChangeAnimator:ViewChangeAnimator ) {
		super();

		this.contentLoader = contentLoader;
		this.contentParser = contentParser;
		this.viewChangeAnimator = viewChangeAnimator;
		this.domWalker = domWalker;

		viewFragmentStack = new Vector.<JQuery>();
	}
}
}