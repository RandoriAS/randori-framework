package robotlegs.flexo {
public interface ICommandMap {
	function map( signal:Class ):ICommandEntry;
	function has( signal:Class ):Boolean;
	function unmap( signal:Class ):void;
	function unmapAll():void;

	function detain( command:ICommand ):void;
	function release( command:ICommand ):void;

	function setupMapping( entry:ICommandEntry ):void;
}
}