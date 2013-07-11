package robotlegs.flexo.test {
import randori.signal.SimpleSignal;

/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/9/13
 * Time: 7:15 PM
 * To change this template use File | Settings | File Templates.
 */
public class OtherSignal extends SimpleSignal {

	public function dispatch( blah:String, blah2:String ):void {
		dispatchArgs( blah, blah2 );
	}

	public function OtherSignal() {
	}
}
}