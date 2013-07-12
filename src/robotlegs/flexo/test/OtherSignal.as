package robotlegs.flexo.test {
import randori.signal.SimpleSignal;

/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/9/13
 * Time: 7:15 PM
 * To change this template use File | Settings | File Templates.
 */
[JavaScript(export="false",name="randori.signal.SimpleSignal")]
public class OtherSignal extends SimpleSignal {

	[JavaScriptMethod(name="dispatchArgs")]
	public function dispatch1( blah:String, blah2:String ):void {
		dispatch( blah, blah2 );
	}

	public function OtherSignal() {
	}
}
}