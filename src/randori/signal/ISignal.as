/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/11/13
 * Time: 4:31 PM
 * To change this template use File | Settings | File Templates.
 */
package randori.signal {
public interface ISignal {
	function add(listener:Function):void;

	function addOnce(listener:Function):void;

	function remove(listener:Function):void;

	function has(listener:Function):Boolean;
}
}
