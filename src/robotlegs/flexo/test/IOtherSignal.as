package robotlegs.flexo.test {
import randori.signal.ISignal;

/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/9/13
 * Time: 7:15 PM
 * To change this template use File | Settings | File Templates.
 */

public interface IOtherSignal extends ISignal  {
	function dispatch( blah:String, blah2:String ):void;
}
}