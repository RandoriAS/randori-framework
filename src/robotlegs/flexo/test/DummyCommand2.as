package robotlegs.flexo.test {
import randori.webkit.page.Window;

/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/10/13
 * Time: 2:04 PM
 * To change this template use File | Settings | File Templates.
 */
public class DummyCommand2 {

	public function execute( val1:int, val2:String ):void {
		Window.alert("Roland " + val1 + val2 )
	}

	public function DummyCommand2() {
	}
}
}