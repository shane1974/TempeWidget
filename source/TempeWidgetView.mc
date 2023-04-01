import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.SensorHistory;
import Toybox.AntPlus;


class TempeWidgetView extends WatchUi.View {

    var state;

    var screenNum = 0;
    
    var background_color = Graphics.COLOR_BLACK;
    var width_screen, height_screen;

    var batt_width_rect = 40; // original 20
    var batt_height_rect = 20; // original 10
    var batt_width_rect_small = 4; //original 2
    var batt_height_rect_small = 10; //original 5
    var batt_x, batt_y, batt_x_small, batt_y_small;

    var deviceSettings = System.getDeviceSettings();

    var screenS = deviceSettings.screenShape;

   // System.println("Screen Shape : " + screenS.toString());

    function initialize() {
        System.println("Full: View.initialize");
        System.println("Screen Shape : " + screenS.toString());
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


        var clrFore = ClrWhite;
        var cOffsetTitle=-30;
        var i = screenNum;

        dc.clear();

        var xCenter = dc.getWidth()/2;
        var yLine = dc.getHeight()/6; // was /5 before adding battery
        var y = yLine + yLine/2 + 22;

        dc.setColor(Graphics.COLOR_WHITE, -1);


        //dc.drawText(xCenter+cOffsetTitle,15,Graphics.FONT_LARGE, "Tempe" + screenNum, Graphics.TEXT_JUSTIFY_CENTER);

        //dc.drawText(xCenter+cOffsetTitle,15,Graphics.FONT_LARGE, (rgTemp[i].lbl), Graphics.TEXT_JUSTIFY_CENTER);


        if (state.fDbg) 
        {
            dc.setColor(ClrDkGray,ClrTrans);
            dc.drawText(xCenter,y-32,F0, rgTemp[i].getID(), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(clrFore,ClrTrans);
        }


            
        if ( self has :getSubscreen)
        {
            var a = getSubscreen();
            var x2 = a.x + a.width/2;
            var y2 = a.y + a.height/2;
            System.println("subscreen: " + x2 + ","+y2 + "," + a.toString());

            //dc.drawText(xCenter,y,Graphics.FONT_LARGE, "Temp : " + strTemp(rgTemp[i].temp), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

            dc.drawText(xCenter+cOffsetTitle,15,Graphics.FONT_LARGE, (rgTemp[i].lbl), Graphics.TEXT_JUSTIFY_CENTER);
            //dc.drawText(a.x-8,y,Graphics.FONT_LARGE, "Temp : ", Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(x2, y2,Graphics.FONT_LARGE, strTempGlance(rgTemp[i].temp), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            
        }
        else
        {
            dc.drawText(xCenter,15,Graphics.FONT_LARGE, (rgTemp[i].lbl), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(xCenter,y,Graphics.FONT_LARGE, "Temp : " + strTemp(rgTemp[i].temp), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            System.println("NO subscreen: ");
        }


        y += yLine;

        if(rgTemp[i].tempMin != null)
        {
            dc.drawText(xCenter,y,Graphics.FONT_LARGE,  "Min : " + strTemp(rgTemp[i].tempMin), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            y += yLine;
        }

        if(rgTemp[i].tempMax != null)
        {
            dc.drawText(xCenter,y,Graphics.FONT_LARGE,  "Max : " + strTemp(rgTemp[i].tempMax), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            y += yLine - 5;
        }

        drawDots(dc, clrFore, i);

        //var batteryStatus = 3;
        var batteryStatus = strBatt(rgTemp[i].batStatus);


        //System.println("batteryStatus : " + batteryStatus);


        width_screen = dc.getWidth();
        height_screen = dc.getHeight();

        //get battery icon position
        batt_x = xCenter - (batt_width_rect /2);
        batt_y = y;
        batt_x_small = batt_x + batt_width_rect;
        batt_y_small = batt_y + ((batt_height_rect - batt_height_rect_small) / 2);

        if (state.fBtry) 
        {
            drawBattery(dc, batteryStatus, clrFore, Graphics.COLOR_DK_RED, Graphics.COLOR_DK_GREEN);
        }

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function drawBattery(dc, batteryStatus, primaryColor, lowBatteryColor, fullBatteryColor)
    {

        var battery = batteryStatus;
        //System.println("drawBattery battery : " + batteryStatus);
        //if(battery == null) {battery = 6;}

        // BATT_STATUS_NEW = 1, BATT_STATUS_GOOD = 2, BATT_STATUS_OK = 3, BATT_STATUS_LOW = 4, BATT_STATUS_CRITICAL = 5 

        if(battery == 4)
        {
            primaryColor = lowBatteryColor;
        }
        else if(battery == 0)
        {
            primaryColor = Graphics.COLOR_TRANSPARENT;
        } 

        //System.println("drawBattery primaryColor : " + primaryColor.toString());


        dc.setColor(primaryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(batt_x, batt_y, batt_width_rect, batt_height_rect);
        dc.setColor(background_color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(batt_x_small-1, batt_y_small+1, batt_x_small-1, batt_y_small + batt_height_rect_small-1);

        dc.setColor(primaryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(batt_x_small, batt_y_small, batt_width_rect_small, batt_height_rect_small);
        dc.setColor(background_color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(batt_x_small, batt_y_small+1, batt_x_small, batt_y_small + batt_height_rect_small-1);

        dc.setColor(primaryColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(batt_x, batt_y, (batt_width_rect * (6 - battery) / 5), batt_height_rect);
        if(battery == 3)
        {
            dc.fillRectangle(batt_x_small, batt_y_small, batt_width_rect_small, batt_height_rect_small);
        }
    }

    function drawDots(dc, primaryColor, i)
    {
        dc.drawCircle(dc.getWidth()/20, dc.getHeight()/2, 3);
        dc.drawCircle(dc.getWidth()/20, dc.getHeight()/2 - 9, 3);
        dc.drawCircle(dc.getWidth()/20, dc.getHeight()/2 + 9, 3);

        if(i == 0)
        {
            dc.fillCircle(dc.getWidth()/20, dc.getHeight()/2 - 9, 3);
        } else if ( i == 1)
        {
            dc.fillCircle(dc.getWidth()/20, dc.getHeight()/2, 3);
        } else if ( i == 2)
        {
            dc.fillCircle(dc.getWidth()/20, dc.getHeight()/2 + 9, 3);
        }

    }

}
