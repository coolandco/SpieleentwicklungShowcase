using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class controllableSphere : sphereRules {


    public static float maxTransSpeed = 10;
    public static float maxRotSpeed = 200;

    [SerializeField]
    private AudioSource audioSource;
    private float audioTargetVolume = 0; //second

    gameManager gameManager;

    //public Camera myCamera;

    private float horiz = 0;
    private float vert = 0;
    private float rotX = 0;
    private float rotY = 0;




    // Use this for initialization
    public void Start () {
        base.Start();

        //gives this sphere to the game manager
        SendMessageUpwards("setMySphere", this, SendMessageOptions.RequireReceiver);

        //gameManager.mySphere = this;

        //we have only one sound for the sphere
        //fade it in and out
        audioSource.volume = 0.5f;
        audioSource.Play();


        StartCoroutine("audioFader");
    }

    public void setGameManager(gameManager gameManager)
    {
        this.gameManager = gameManager;
    }

    // Update is called once per frame
    public void Update() {

        horiz = Input.GetAxis("Horizontal");
        vert = Input.GetAxis("Vertical");

        rotY = Input.GetAxis("Mouse X");
        rotX = -(Input.GetAxis("Mouse Y"));






        this.transform.Rotate(0, rotY * maxRotSpeed * Time.deltaTime , 0);//, Space.World --> put this in for less fun ;)
        this.transform.Rotate(rotX * maxRotSpeed * Time.deltaTime, 0, 0);

        //this.transform.Rotate(Vector3.up * maxRotSpeed * horiz * Time.deltaTime);
        //this.transform.Rotate(Vector3.up * maxRotSpeed * horiz * Time.deltaTime);

        bool sideways = true;
        bool forwd = true;

        //check Boundaries
        if (this.transform.position.x > maxPlayingField)
        {
            this.transform.position = new Vector3(maxPlayingField, this.transform.position.y, this.transform.position.z);
            sideways = false;
        }
        if (this.transform.position.y > maxPlayingField)
        {
            this.transform.position = new Vector3(this.transform.position.x, maxPlayingField, this.transform.position.z);
        }
        if (this.transform.position.z > maxPlayingField)
        {
            this.transform.position = new Vector3(this.transform.position.x, this.transform.position.y, maxPlayingField);
            forwd = false;
        }

        if (this.transform.position.x < 0)
        {
            this.transform.position = new Vector3(0, this.transform.position.y, this.transform.position.z);
            sideways = false;
        }
        if (this.transform.position.y < 0)
        {
            this.transform.position = new Vector3(this.transform.position.x, 0, this.transform.position.z);
        }
        if (this.transform.position.z < 0)
        {
            this.transform.position = new Vector3(this.transform.position.x, this.transform.position.y, 0);
            forwd = false;
        }


        //only translate if not at boundary
        if(forwd)
            this.transform.Translate(Vector3.forward * maxTransSpeed * vert * base.speedMultiplier * Time.deltaTime);

        //Debug.Log(base.speedMultiplier);

        if(sideways)
            this.transform.Translate(Vector3.right * maxTransSpeed * horiz * base.speedMultiplier * Time.deltaTime);

    }

    public void OnTriggerStay(Collider other)
    {
        base.OnTriggerStay(other);

        sphereRules otherSphere = other.gameObject.GetComponent<sphereRules>();
        if (otherSphere == null)
        {//check if we hit another sphere
            return;
        }

        //we want a pitch between 0 and 2 
        //get percentage of this volume and that volume
        //Debug.Log((this.getVolume() / sphereRules.wholeVolume) + (otherSphere.getVolume() / sphereRules.wholeVolume));
        float pichtemp = 2 - (this.getVolume() / sphereRules.wholeVolume) + (otherSphere.getVolume() / sphereRules.wholeVolume);
        if (float.IsNaN(pichtemp))
            audioSource.pitch = 0;
        else
            audioSource.pitch = pichtemp;


        //if we are still in a collission and the audio is not playing, then play
        if (audioTargetVolume != 1)
        {
            audioTargetVolume = 1;
        }
    }


    public IEnumerator audioFader()
    {
        //every frame
        while (true) {
            //float startVolume = audioSource.volume;
            if (audioTargetVolume == 1f)
            {
                audioTargetVolume -= 0.000001f;//decrement just a little and check again if someone set it to 1 again (bc of a collission)
                yield return new WaitForSeconds(0.1f);
                //restart loop
                //continue;
            }

            //decrement target volume over time
            //if someone wants to have it up, he should 
            //set it to 1 every frame
            audioTargetVolume -= Time.deltaTime / 0.2f; 

            //we want to fade the audio in and out
            //decide of we have to increment or decrement the audiosource.volume:
            if (audioSource.volume > audioTargetVolume)
            {
                audioSource.volume -= Time.deltaTime / 0.2f;
                
                if (audioSource.volume < audioTargetVolume)
                {
                    Debug.Log("Volume: " + audioSource.volume + "Target Volume: " + audioTargetVolume);
                    //if bigger now
                    audioSource.volume = audioTargetVolume;
                }
            }
            else
            {
                audioSource.volume += Time.deltaTime / 0.2f;
                if (audioSource.volume > audioTargetVolume)
                {
                    //if smaller now
                    audioSource.volume = audioTargetVolume;
                }
            }

            yield return null;

        }
    }


    //we dont want to get destroyed
    //we just want to tell the game manager that the game is over
    protected override void gotEaten()
    {
        Debug.Log("overritten goteaten");
       // SendMessageUpwards("gameEnd", gameManager.ENDREASON.gotEaten, SendMessageOptions.RequireReceiver);
        //tell the gameManager
        gameManager.gameEnd(gameManager.ENDREASON.gotEaten);
    }
}
