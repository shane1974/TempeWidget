import Toybox.Lang;
import Toybox.WatchUi;

class TempeWidgetDelegate extends WatchUi.BehaviorDelegate {

    var mainView = 0;

    function initialize(view) 
    {
        mainView = view;
        BehaviorDelegate.initialize();
        System.println("Glance: Delegate - Init");
    }
    //---------------------------------
    function onBack()
    {
        System.exit(); //should never be needed - but fixed a bug on some device
        return(false); 
    }
    //---------------------------------
    function onSwipe(swipeEvent)
    {
        var dir = swipeEvent.getDirection();
        switch (dir)
        {
        case WatchUi.SWIPE_RIGHT:
            System.exit();
            return(false);
        default:
            break;
        }
        return(false);
    }

    function onNextPage() {
        return nextScreen();
    }

    function onPreviousPage() {
        return nextScreen();
    }

    function onSelect() {
        return nextScreen();
    }

    function onMenu() {
        //WatchUi.pushView(new Rez.Menus.MainMenu(), new TempeWidgetMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    function nextScreen() 
    {

        if(mainView.screenNum < (cTempItem - 1)){
            mainView.screenNum++;
        }else{
            mainView.screenNum = 0;
        }


        //mainView.screenNum = mainView.screenNum == 0 ? 1 : 0;
        WatchUi.requestUpdate();
        return true;
    }

}