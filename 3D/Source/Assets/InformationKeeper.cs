using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InformationKeeper : MonoBehaviour {

    private string endmessage = "";

    // Use this for initialization
    void Start () {
        DontDestroyOnLoad(this.gameObject);
    }
	
	// Update is called once per frame
	void Update () {
		
	}

    public void setEndmessage(string endmsg)
    {
        endmessage = endmsg;
    }

    public string getEndmessage()
    {
        //destroys this on the next frame or so, because menu has endessage
        GameObject.Destroy(this.gameObject);

        return endmessage;
    }
}
