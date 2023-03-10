import Toybox.System;
import Toybox.Application;
import Toybox.WatchUi;

(:glance)const cTempItem = 1;
(:glance)var rgTemp = new [cTempItem];

(:glance)
class State
{
    static var timeout; //in milliseconds
    var fDbg=true;
    var fBtry=true;
    var fWhiteBG=true;
    var timer = new WatchUi.Timer.Timer();

    //-------------------------------------------
    function initialize()
    {
        //System.println("init: setEnableSensors");
        Sensor.setEnabledSensors([Sensor.SENSOR_TEMPERATURE]);
        Sensor.enableSensorEvents(method(:onSensorEvents));
        //Syastem.println("init: done setEnableSensors");

        for (var i = 0; i < cTempItem; ++i) {rgTemp[i] = new TempItem(i);}
        updateSettings(); //this actually initializes the tempe's

        //System.println(dbgStr());
        checkTimeout(false);
        System.println(dbgStr());
        
        timer.start(method(:onTimerTic),5000,true);
    }
    //---------------------------------
    function getTemp(i) {return(rgTemp[i].temp);}
    function getLbl(i) {return(rgTemp[i].lbl);}
    
    //---------------------------------
    function dbgStr()
    {
        //return( Lang.format("$1$, $2$, $3$", [rgTemp[0].toStr(),rgTemp[1].toStr(),rgTemp[2].toStr()]));
        //return( Lang.format("debStr $1$, $2$, $3$", [rgTemp[0].toStr(),rgTemp[0].toStr(),rgTemp[0].toStr()]));
        return( Lang.format("debStr $1$", [rgTemp[0].toStr()]));

    }
    //---------------------------------
    function checkTimeout(fClear)
    {
        var tmOut = System.getTimer() - timeout;
        for (var i = 0; i < cTempItem; ++i) 
        {
            rgTemp[i].checkTimeout(fClear,tmOut);
        }
    }
    //-----------------------------------------------
    function clearCache(){checkTimeout(true);}
    //---------------------------------
    function onTimerTic() //every second
    {
        System.println(strTimeOfDay(true) + "onTimerTic");
        
        checkTimeout(false);
        /*
        if ((Toybox has :SensorHistory) && (Hist has :getTemperatureHistory))
        {        
            var tempIter = Hist.getTemperatureHistory({:period => 1});
            var tempInt = tempIter.next().data;
            for (var i = 0; i < cTempItem; ++i) {rgTemp[i].updateTemp(tempInt,-1);}          
        }
        */
        for (var i = 0; i < cTempItem; ++i) {rgTemp[i].updateTempeTemp();}          
    
        WatchUi.requestUpdate();
    }

    //---------------------------------
    function done()
    {
        System.println("done: close sensor");
        for (var i = 0; i < cTempItem; ++i) {rgTemp[i].releaseTempe();}          
    }           
    
    //---------------------------------
    //this is for the paired tempe
    function onSensorEvents(sinfo) //
    {
        if (sinfo != null)
        {
            if ((sinfo has :temperature) && (sinfo.temperature != null)) 
            {
                for (var i = 0; i < cTempItem; ++i) {rgTemp[i].updateTemp(sinfo.temperature,-2);}          
                System.println("paired temp: " + sinfo.temperature); //this hsould never be called
            }
        }
    }
    //-----------------------------------------------
    function updateSettings()
    {
        timeout = getProp("Timeout",1200) * 1000;
        fDbg = getProp("Dbg",false);
        fBtry = getProp("Btry",true);
        fWhiteBG = getProp("WhiteBG",true); //white background
        //fDbg=true;
        System.println("timeout: " + timeout);
        rgTemp[0].updateSettings(0,"Tempe1");
        //rgTemp[1].updateSettings(-2,"Tempe1");
        //rgTemp[2].updateSettings(0,"Tempe2");
        
        for (var i = 0; i < cTempItem; ++i) {rgTemp[i].releaseTempe();}   //delete any Tempe objects   
        for (var i = 0; i < cTempItem; ++i) {rgTemp[i].initTempe(false);} //init all specified ID's    
        for (var i = 0; i < cTempItem; ++i) {rgTemp[i].initTempe(true);}  //init all Zero ID's
        

        WatchUi.requestUpdate();
    }
    
}





(:glance)
class TempItem
{
    var i; //0 - 2
    var id; //-1=internal, -2=paired, 0=any unpaired
    var lbl;
    var tmLast;  //time the last temperature was recorded
    var temp;    //most recent temperature - null if none
    var tempe; //the tempe object, null if internal or paired
    var tempMin; //min temp on Tempe
    var tempMax; //max temp on Tempe
    var batStatus; // battery status on Tempe

    
    //---------------------------------
    function initialize(i_)
    {
        i = i_;
        //System.println("Testing i_ " + i_);             

        tmLast = Application.Storage.getValue("tmTemp"+i);
        temp = Application.Storage.getValue("Temp"+i);
        System.println("TempItem initialize() tmLast " + tmLast);
        System.println("TempItem initialize() Temp " + temp);

        tempMin = Application.Storage.getValue("MinTemp"+i);
        tempMax = Application.Storage.getValue("MaxTemp"+i);
        System.println("TempItem initialize() TempMin " + tempMin);
        System.println("TempItem initialize() TempMax " + tempMax);

        //Application.Storage.setValue("StatusBattery"+i, 6);
        batStatus = Application.Storage.getValue("StatusBattery"+i);
        System.println("TempItem initialize() StatusBattery " + batStatus);

    }

    //---------------------------------
    function updateSettings(defID, defLbl)
    {
        id = getProp("T"+i+"ID",defID);
        lbl = getProp("T"+i+"Label",defLbl);
        System.println("Update Settings: " + toStr());
    }

    //---------------------------------
    function fExpiring()
    {
        if (tmLast == null) {return(false);} //it's expired!
        
        
        var pct = (System.getTimer() - tmLast).toFloat() / State.timeout;
        //System.println(Lang.format("$1$: tmOut %: $2$",[i,pct]));
        return(pct > 0.50);     
    }
        
    //---------------------------------
    function toStr()
    {
        return(Lang.format("$1$: $2$,$3$,$4$,$5$",[i,id,lbl,numStr(temp), durStr(tmLast)]));
    }
    //---------------------------------
    function getID()
    {
        if ((id == 0) && (tempe == null)) {return("ex");}
        return ((id == 0) ? tempe.antid : id);
    }
    //---------------------------------
    function releaseTempe()
    {
        if (tempe != null)
        {
            tempe.closeSensor();
            tempe=null;
        }
    }
    //---------------------------------
    function initTempe(fIfZero)
    {
        if (id >= 0)
        {
            //this check allows us to first open all non-zero ID's first, so zero's don't find them first
            if (fIfZero == (id == 0))
            {
                try
                {
                    //tempe = null;
                    tempe=new TempeWidgetSensor(id);  
                } catch (ex)
                {
                    System.println("Exception in TempeWidgetSensor(" + id + "): " + ex.getErrorMessage());
                    tempe = null;
                }
                    
            }
        }
    }
    //---------------------------------
    function checkTimeout(fClear,tmOut)
    {    
        //if (true)
        if (fClear || ((tmLast != null) && (tmLast < tmOut)))
        {
            tmLast = null;
            temp = null;
            tempMin = null;
            tempMax = null;
            //batStatus = 6;
            Application.Storage.setValue("Temp"+i,temp);
            Application.Storage.setValue("MinTemp"+i,tempMin);
            Application.Storage.setValue("MaxTemp"+i,tempMax);
            Application.Storage.setValue("tmTemp"+i,tmLast);
            Application.Storage.setValue("StatusBattery"+i, batStatus);
        }
    }
    //---------------------------------
    function updateTempeTemp()
    {
        if ((tempe != null) && (tempe.tmTemp != null))
        {
            temp = tempe.iTemp;
            tempMin = tempe.minTemp;
            tempMax = tempe.maxTemp;
            tmLast = tempe.tmTemp;
            batStatus = tempe.batteryStatus;
            Application.Storage.setValue("Temp"+i,temp);
            Application.Storage.setValue("MinTemp"+i,tempMin);
            Application.Storage.setValue("MaxTemp"+i,tempMax);
            Application.Storage.setValue("tmTemp"+i,tmLast);
            Application.Storage.setValue("StatusBattery"+i, batStatus);
            System.println("UpdateTempeTemp: " + toStr());
            System.println("UpdateTempeTemp: temp " + temp);
            System.println("UpdateTempeTemp: tempMin " + (Application.Storage.getValue("MinTemp"+i)));
            System.println("UpdateTempeTemp: tempMax " + tempMax);
            System.println("UpdateTempeTemp: tmLast " + tmLast);
            System.println("UpdateTempeTemp: batStatus " + batStatus);
        }
    }
    //---------------------------------
    function updateTemp(tempIn,idSet)
    {
        if (id == idSet) //-1 or -2
        {
            if (tempIn != null)
            {
                
                temp = tempIn;
                tmLast = System.getTimer();
                Application.Storage.setValue("Temp"+i,temp);
                Application.Storage.setValue("tmTemp"+i,tmLast);
            }
            System.println("UpdateTemp: " + toStr());
        }
    }
}        
