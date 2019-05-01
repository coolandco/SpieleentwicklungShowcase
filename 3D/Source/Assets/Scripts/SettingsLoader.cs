using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class SettingsLoader { // not a mono behaviour // persists between scenes

    //Singelton
    public static SettingsLoader instance;
    private SettingsLoader() { }
    public static SettingsLoader Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new SettingsLoader();
            }
            return instance;
        }
    }

    //instatiate stuff
    private Settings jsonObject;
    private bool settingsLoaded = false;

    public class Settings
    {
        [System.Serializable]
        public class mySetting
        {
            public string text;
            public float value;
        }
        public mySetting[] mySettings;
    }



    //called from MainMenuScript
    public IEnumerator Start()
    {
        string file;

        if (Application.isEditor)
            file = Path.Combine(Application.dataPath, "../ExternalData/data.json");
        else
            file = Path.Combine(Application.dataPath, "ExternalData/data.json");


        if (Application.isEditor)
            file = "file://" + file;

        WWW www = new WWW(file);

        yield return www;

        //Now we have the settings

        if (www.text != null)
        {
            jsonObject = JsonUtility.FromJson<Settings>(www.text);

            Debug.Log("settingsLoaded = true");
            //now settings are loaded
            settingsLoaded = true;

        }

    }

    public bool isSettingsLoaded()
    {
        return settingsLoaded;
    }


    public void getSetting(string variableName, ref float toSet)
    {

        if (!settingsLoaded)
            return;


        foreach (Settings.mySetting sett in jsonObject.mySettings)
        {
            
            //find the setting and return it;
            if (sett.text.Equals(variableName))
            {
                toSet = sett.value;
                return;
            }

        }

        //didnt find setting
        return;
    }
}
