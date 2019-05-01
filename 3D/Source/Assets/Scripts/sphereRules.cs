using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class sphereRules : MonoBehaviour ,IEquatable<sphereRules>, IComparable<sphereRules>
{

    //constants for the game
    public static float maxPlayingField = 40f;
    public static float snapValue = 0.2f;
    public static float massTransferDivisor = 5;


    //used during the game
    protected static float wholeVolume = 0;




    //a value between 0 and 1
    //1 is normal speed
    protected float speedMultiplier = 1;


    //my Radius
    private float scaleRadius;
    private float realRadius;
    private float volume;


    // Use this for initialization
    protected void Start()
    {
        // get any scale value
        //make sure the scale is the same
        setRealRadius(transform.localScale.x / 2);

        //put the volume in the hole volume
        wholeVolume += getVolume();

    }

    //===============================================================
    //the volume/radius getter/setter are inverted methodes
    //I tried to do have as little work for cpu as possible

    //because the scale of an object is not the radius
    public void setRealRadius(float realRadius)
    {
        this.scaleRadius = realRadius * 2f;
        this.realRadius = realRadius;

        //recalculate volume
        this.volume = (4f / 3f) * Mathf.PI * Mathf.Pow(getRealRadius(), 3); //formula for volume of a sphere

        refreshView();
    }

    public float getRealRadius()
    {
        return realRadius;
    }

    public float getVolume()
    {
        return volume;
    }

    public void setVolume(float volume)
    {
        this.volume = volume;

        //recalculate radius
        this.realRadius = Mathf.Pow(3f * (volume / (4f * Mathf.PI)), 1f/3f);
        this.scaleRadius = realRadius * 2;

        refreshView();
    }

    private void refreshView()
    {
        if (float.IsNaN(realRadius))
            gotEaten();//to small, so destroy
        else
            transform.localScale = new Vector3(this.scaleRadius, this.scaleRadius, this.scaleRadius);
    }

    //===============================================================

    //we check every frame if another sphere is touching
    public void OnTriggerStay(Collider other)
    {

        sphereRules otherSphere = other.gameObject.GetComponent<sphereRules>();
        if (otherSphere == null)
        {//check if we hit another sphere
            return;
        }

        //if this sphere is bigger than the other
        if (otherSphere.getRealRadius() < this.getRealRadius())
        {
            //distance between us and other sphere
            float distance = Vector3.Distance(otherSphere.transform.position, this.transform.position);


            //überlappung in unity units
            float überlappung = Math.Abs(distance - (otherSphere.getRealRadius() + this.getRealRadius()));

            // if (otherSphere == gameManager.mySphere)
            //   Debug.Log(überlappung);

            //calculate the amount of volume we transfere to the other sphere
            float transfer =  überlappung / sphereRules.massTransferDivisor;

            //transfer
            //überlappung is an unrelated value to volume
            this.setVolume(this.getVolume() + transfer);
            otherSphere.setVolume(otherSphere.getVolume() - transfer);


            //we changed the volume, so refresh the speed
            this.volumeChanged();
            otherSphere.volumeChanged();

        }

    }

    public void volumeChanged() {

        //destroy sphere if to small
        if (this.getRealRadius() < snapValue)
        {
            this.gotEaten();
        }

        //Regulate speed, generate a percentage between 0 and 1
        float percentOfWhole = this.getVolume() / sphereRules.wholeVolume;

        //the bigger we are, the slower we get
        speedMultiplier = 1 - (percentOfWhole * 1f);

       // if (Random.value < 0.05)
        //    Debug.Log(percentOfHole);
    }

    //can be overritten
    //will be called if we got eaten by another sphere, or if we are to small
    protected virtual void gotEaten()
    {
        GameObject.Destroy(this.gameObject);
    }

    public bool Equals(sphereRules other)
    {
        //if this is the same instance then other, then it is the same
        if (this == other)
            return true;
        else
            return false;
    }

    public int CompareTo(sphereRules other)
    {
        //compare the radius
        if (this.getRealRadius() > other.getRealRadius())
            return -1;
        else if (this.getRealRadius() == other.getRealRadius())
            return 0;
        else
            return 1;
    }

    public static float getWholeVolume()
    {
        return wholeVolume;
    }

    public static void resetWholeVolume()
    {
        wholeVolume = 0;
    }
}
