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
import guice.binding.IBinding;
import guice.binding.Scope;
import guice.reflection.TypeDefinitionFactory;

import randori.signal.SimpleSignal;

public class CommandMap implements ICommandMap {

	private var binder:IBinder;
	private var factory:TypeDefinitionFactory;
	private var injector:IInjector;
	private var bound:Array;
	private var detained:Array;

	public function signal( signalInterface:Class ):ICommandEntry {

		var binding:IBinding = binder.getBinding( factory.getDefinitionForType( signalInterface ) );
		if ( binding ) {
			var commandEntry:* = binding as ICommandEntry;
			if ( commandEntry.provider && commandEntry.provider.to ) {
				//Assume is it our CommandEntry
				//Want to refactor this so its just a wrap of one binding on another someday
				return commandEntry.provider;
			}
		} else {
			//Make this guy a context sigleton if no one else cares
			binding = binder.bind( signalInterface ).inScope( Scope.Context).to( SimpleSignal );
		}

		return setupMapping( signalInterface, new CommandEntry( this, binding, injector ) );
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

	private function setupMapping( signalInterface:Class, provider:ICommandEntry ):ICommandEntry {

		bound.push( signalInterface );
		//First ensure this Signal remains a singleton
		//We actually should check if the binder has this entry and its a singleton
		//Else we could be screwing with someone else's binding
		binder.bind( signalInterface ).toProviderInstance( provider );

		return provider;
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
import guice.binding.IBinding;
import guice.resolver.CircularDependencyMap;

import randori.signal.SimpleSignal;

import robotlegs.flexo.command.ICommandEntry;
import robotlegs.flexo.command.ICommandMap;

class CommandEntry implements ICommandEntry {
	private var signal:SimpleSignal;
	private var binding:IBinding;
	private var commandMap:ICommandMap;
	private var injector:IInjector;
	private var list:Vector.<Class>;

	public function get():* {

		if ( !signal ) {
			signal = binding.provide( injector );
			signal.add( executeCommand );
		}

		return signal;
	}

	public function to( commandClass:Class ):void {
		this.list.push( commandClass );
	}

	private function executeCommand( ...args ):void {
		for ( var i:int=0; i<list.length; i++ ) {
			//How does it get its payload... that is the question for life
			var command:* = injector.getInstance( list[ i ] );
			//calls execute and passes any args from the signal
			command.execute.apply( command, args );
		}
	}

	public function CommandEntry( commandMap:ICommandMap, binding:IBinding, injector:IInjector ) {
		this.commandMap = commandMap;
		this.binding = binding;
		this.injector = injector;
		this.list = new Vector.<Class>();
	}
}
