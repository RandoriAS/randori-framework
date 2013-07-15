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
package robotlegs.flexo.command {
import guice.IInjector;
import guice.binding.IBinder;
import guice.reflection.TypeDefinitionFactory;

public class CommandMap implements ICommandMap {

	private var binder:IBinder;
	private var factory:TypeDefinitionFactory;
	private var injector:IInjector;
	private var bound:Array;
	private var detained:Array;

	public function signal( signalInterface:Class ):ICommandEntry {
		return new CommandEntry( this, signalInterface, injector );
	}

	public function has( signalInterface:Class ):Boolean {
		return bound.indexOf( signalInterface ) >= 0;
	}

	public function unmap( signalInterface:Class ):void {
		var location:int = bound.indexOf( signalInterface );

		binder.unbind( signalInterface );

		if ( location >= 0 ) {
			bound.splice( location, 1 );
		}
	}

	public function unmapAll():void {

		for ( var i:int=0; i<bound.length; i++ ) {
			binder.unbind( bound[ i ] );
		}

		bound = [];
	}

	public function detain( command:ICommand ):void {
		detained.push( command );
	}

	public function release( command:ICommand ):void {
		var location:int = detained.indexOf( command );

		if ( location >= 0 ) {
			detained.splice( location, 1 );
		}
	}

	public function setupMapping( provider:ICommandEntry ):void {
		bound.push( provider.signalInterface );
		//First ensure this Signal remains a singleton
		//We actually should check if the binder has this entry and its a singleton
		//Else we could be screwing with someone else's binding
		binder.bind( provider.signalInterface ).toProviderInstance( provider );
	}

	public function CommandMap( injector:IInjector, binder:IBinder, factory:TypeDefinitionFactory ) {
		this.injector = injector;
		this.binder = binder;
		this.factory = factory;

		this.bound = new Array();
		this.detained = new Array();
	}
}
}

import guice.IInjector;
import guice.resolver.CircularDependencyMap;

import randori.signal.SimpleSignal;

import robotlegs.flexo.command.ICommandEntry;
import robotlegs.flexo.command.ICommandMap;

class CommandEntry implements ICommandEntry {
	private var signal:SimpleSignal;
	private var commandClass:Class;
	private var _signalInterface:Class;
	private var commandMap:ICommandMap;
	private var injector:IInjector;

	public function get():* {

		if ( !signal ) {
			signal = injector.buildClass( SimpleSignal, new CircularDependencyMap() );
			signal.add( executeCommand );
		}

		return signal;
	}

	public function get signalInterface():Class {
		return _signalInterface;
	}

	public function to( commandClass:Class ):void {
		this.commandClass = commandClass;
		commandMap.setupMapping( this );
	}

	private function executeCommand( ...args ):void {
		//How does it get its payload... that is the question for life
		var command:* = injector.getInstance( commandClass );
		//calls execute and passes any args from the signal
		command.execute.apply( command, args );
	}

	public function CommandEntry( commandMap:ICommandMap, signalInterface:Class, injector:IInjector ) {
		this.commandMap = commandMap;
		this._signalInterface = signalInterface;
		this.injector = injector;
	}
}
