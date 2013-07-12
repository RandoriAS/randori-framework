package robotlegs.flexo.test {
import randori.signal.ISignal;

/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/9/13
 * Time: 7:15 PM
 * To change this template use File | Settings | File Templates.
 */

[Signal]
public interface ISecondSignal extends ISignal  {
	function dispatch( arg1:int, arg2:String ):void;
}
}