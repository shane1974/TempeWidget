import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;




(:glance)
class TempeWidgetGlanceView extends WatchUi.GlanceView {

    var state;

    function initialize() {
        GlanceView.initialize();
        System.println("Glance: glanceViewInit");
        state = new State();
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {

        var F0 = Graphics.FONT_TINY;
        var F1 = Graphics.FONT_SMALL;
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var centerXinc = dc.getWidth() / 3;
        var centerX = centerXinc / 2; 
        var centerY = dc.getHeight() / 2;
        var valueY = centerY - dc.getFontHeight(F1);
        
        // have removed to loop from here, and set i =2 so picks up tempe
        //var i = 0;

        for (var i = 0; i < cTempItem; ++i) 
        {
            dc.setColor(ClrWhite, ClrTrans);
            dc.drawText(centerX, valueY, F1, strTempGlance(rgTemp[i].temp), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(ClrLtGray, ClrTrans);
            dc.drawText(centerX, centerY, F0, "Temp", Graphics.TEXT_JUSTIFY_CENTER);
            System.println("TempWidgetView Glance temp " + strTempGlance(rgTemp[i].temp));

            centerX += centerXinc;

            dc.setColor(ClrWhite, ClrTrans);
            dc.drawText(centerX, valueY, F1, strTempGlance(rgTemp[i].tempMin), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(ClrLtGray, ClrTrans);
            dc.drawText(centerX, centerY, F0, "Min", Graphics.TEXT_JUSTIFY_CENTER);
            System.println("TempWidgetView Glance tempMin " + strTempGlance(rgTemp[i].tempMin));

            centerX += centerXinc;

            dc.setColor(ClrWhite, ClrTrans);
            dc.drawText(centerX, valueY, F1, strTempGlance(rgTemp[i].tempMax), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(ClrLtGray, ClrTrans);
            dc.drawText(centerX, centerY, F0, "Max", Graphics.TEXT_JUSTIFY_CENTER);
            System.println("TempWidgetView Glance tempMax " + strTempGlance(rgTemp[i].tempMax));
        }

    }

} 

class TempeWidgetDelegate extends WatchUi.BehaviorDelegate
{
    //-------------------------------------------
    function initialize() 
    {
        BehaviorDelegate.initialize();
        System.println("Glance: Delegate - Init");
    }
    //---------------------------------
    function onBack()
    {
        System.exit(); //should never be needed - but fixed a bug on some device
        return(false); //True isn't working on Instinct 9.12
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
}



class TempeWidgetView extends WatchUi.View {

    var state;

    function initialize() {
        System.println("Full: View.initialize");
        View.initialize();
        state = new State();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        System.println("Full: onUpdate");
        var clrBack = state.fWhiteBG ? ClrWhite : ClrBlack;
        var clrFore = state.fWhiteBG ? ClrBlack : ClrWhite;
        dc.setColor(clrFore, clrBack);
        dc.clear();
        var cOffsetTitle=0;
        
        var xCenter = dc.getWidth()/2;
        var yLine = dc.getHeight()/5;
        var y = yLine + yLine/2;
        
        // changed this from i = 0 to i = 2 as only want the tempe data
        //for (var i = 2; i < cTempItem; ++i) 
        for (var i = 0; i < cTempItem; ++i) 
        {
            dc.setColor(rgTemp[i].fExpiring() ? ClrYellow : clrFore,ClrTrans);
            if ((i == 0) && (self has :getSubscreen))
            {
                var a = getSubscreen();
                var x2 = a.x + a.width/2;
                var y2 = a.y + a.height/2;
                //System.println("subscreen: " + x2 + ","+y2);
                dc.drawText(a.x-8,y,Graphics.FONT_LARGE, rgTemp[i].lbl+":", Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
                dc.drawText(x2, y2,Graphics.FONT_LARGE, strTempGlance(rgTemp[i].temp), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                cOffsetTitle = -15;
            }
            else
            {
                dc.drawText(xCenter,y,Graphics.FONT_LARGE, "Temp : " + strTemp(rgTemp[i].temp), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                y += yLine;
                dc.drawText(xCenter,y,Graphics.FONT_LARGE,  "Min : " + strTemp(rgTemp[i].tempMin), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                y += yLine;
                dc.drawText(xCenter,y,Graphics.FONT_LARGE,  "Max : " + strTemp(rgTemp[i].tempMax), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }

            if (state.fDbg) 
            {
                dc.setColor(ClrDkGray,ClrTrans);
                dc.drawText(xCenter,y+10,F2, rgTemp[i].getID(), Graphics.TEXT_JUSTIFY_CENTER);
            }
            y += yLine;
        }


        dc.drawText(xCenter+cOffsetTitle,0,Graphics.FONT_LARGE, "Tempe", Graphics.TEXT_JUSTIFY_CENTER);


    }



    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
