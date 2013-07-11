package robotlegs.flexo {
import guice.IInjector;
import guice.binding.IBinder;
import guice.reflection.TypeDefinitionFactory;

/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/9/13
 * Time: 5:51 PM
 * To change this template use File | Settings | File Templates.
 */
public class CommandMap implements ICommandMap {

	private var binder:IBinder;
	private var factory:TypeDefinitionFactory;
	private var injector:IInjector;

	public function map( signal:Class ):ICommandEntry {
		return new CommandEntry( this, signal, injector );
	}

	public function has( signal:Class ):Boolean {
		return true;
	}

	public function unmap( signal:Class ):void {

	}

	public function unmapAll():void {

	}

	public function detain( command:ICommand ):void {

	}

	public function release( command:ICommand ):void {

	}

	public function setupMapping( provider:ICommandEntry ):void {
		//First ensure this Signal remains a singleton
		//We actually should check if the binder has this entry and its a singleton
		//Else we could be screwing with someone else's binding
		binder.bind( provider.signalClass ).toProviderInstance( provider );
	}

	public function CommandMap( injector:IInjector, binder:IBinder, factory:TypeDefinitionFactory ) {
		this.injector = injector;
		this.binder = binder;
		this.factory = factory;
	}
}
}

import guice.IInjector;
import guice.resolver.CircularDependencyMap;

import randori.signal.SimpleSignal;

import robotlegs.flexo.ICommandEntry;
import robotlegs.flexo.ICommandMap;

class CommandEntry implements ICommandEntry {
	private var signal:SimpleSignal;
	private var commandClass:Class;
	private var _signalClass:Class;
	private var commandMap:ICommandMap;
	private var injector:IInjector;

	public function get():* {

		if ( !signal ) {
			signal = injector.buildClass( _signalClass, new CircularDependencyMap() );
			signal.add( executeCommand );
		}

		return signal;
	}

	public function get signalClass():Class {
		return _signalClass;
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

	public function CommandEntry( commandMap:ICommandMap, signal:Class, injector:IInjector ) {
		this.commandMap = commandMap;
		this._signalClass = signal;
		this.injector = injector;
	}
}
