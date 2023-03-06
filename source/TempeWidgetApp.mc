import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TempeWidgetApp extends Application.AppBase {

    var view;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    (:glance)function getGlanceView() 
    {
        System.println("getGlanceView");
        view = new TempeWidgetGlanceView();
        return [ view ];
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new TempeWidgetView() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as TempeWidgetApp {
    return Application.getApp() as TempeWidgetApp;
}