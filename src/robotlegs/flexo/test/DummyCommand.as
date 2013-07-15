package robotlegs.flexo.test {
import randori.webkit.page.Window;

/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/10/13
 * Time: 2:04 PM
 * To change this template use File | Settings | File Templates.
 */
public class DummyCommand {

	public function execute( val1:String, val2:String ):void {
		Window.alert("Yo Ho ho " + val1 + val2 )
	}

	public function DummyCommand() {
	}
}
}