/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/9/13
 * Time: 5:55 PM
 * To change this template use File | Settings | File Templates.
 */
package robotlegs.flexo {
import guice.binding.provider.IProvider;

public interface ICommandEntry extends IProvider {
	function get signalClass():Class;
	function to( commandClass:Class ):void;
}
}
