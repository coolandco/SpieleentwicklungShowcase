using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class setInMiddleOfPlayingField : MonoBehaviour {

	// Use this for initialization
	void Start () {
        //position half of playing field
        float myPosition = sphereRules.maxPlayingField / 2f;
        gameObject.transform.position = new Vector3(myPosition, myPosition, myPosition);
    }

}
