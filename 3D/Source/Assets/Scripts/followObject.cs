using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class followObject : MonoBehaviour {

    /// <summary>
    /// required
    /// </summary>
    public GameObject objectToFollow;


    private Vector3 offset;

	// Use this for initialization
	void Start () {

         offset = this.transform.position - objectToFollow.transform.position;
	}

    // Update is called once per frame
    void Update () {

        this.transform.position = objectToFollow.transform.position + offset;

	}
}
