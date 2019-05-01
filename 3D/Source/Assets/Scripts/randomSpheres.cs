using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class randomSpheres : sphereRules
{
    static float maxSight;

    [SerializeField]
    private TextMesh massText;

    private Vector3 direction;
    private float speed;

    public static float maxSpeed = 5f;
    public static float minSpeed = 2f;


    public void Start()
    {
        //first call start of superclass
        base.Start();

        //calc it now
        maxSight = sphereRules.maxPlayingField / 2;

        //we put ourselfe in the list
        gameManager.sphereList.Add(this);

        //a random Direction
        direction = new Vector3(Random.value, Random.value, Random.value).normalized;

        //choose a speed in a valid range
        do
        {
            speed = Random.value * maxSpeed;

        } while (speed < minSpeed);
    }


    // Update is called once per frame
    public void Update()
    {

        //Regulate speed, the bigger the slower
        this.transform.Translate(direction * speed * base.speedMultiplier * Time.deltaTime);// move the sphere


        //now check constraints and do mirror movement
        if (transform.position.x > maxPlayingField || transform.position.x < 0)
        {
            direction = new Vector3(-direction.x, direction.y, direction.z);
        }
        if (transform.position.y > maxPlayingField || transform.position.y < 0)
        {
            direction = new Vector3(direction.x, -direction.y, direction.z);
        }
        if (transform.position.z > maxPlayingField || transform.position.z < 0)
        {
            direction = new Vector3(direction.x, direction.y, -direction.z);
        }

        //current mass text
        //if smaller than 1, sof floating point values
        if (this.getVolume() < 1)
            massText.text = this.getVolume().ToString();
        else
            massText.text = ((int)getVolume()).ToString();

        float distance = Vector3.Distance(gameManager.mySphere.transform.position, this.transform.position);

        float alpha = maxSight / distance;
        if (alpha > 1)//not bigger than 1
            alpha = 1;

        massText.color = new Color(massText.color.r, massText.color.g, massText.color.b, alpha);

        //let the mass look to mySphere
        massText.gameObject.transform.parent.LookAt(gameManager.mySphere.transform, gameManager.mySphere.transform.up);




        //color stuff
        float colorOffset = gameManager.mySphere.getVolume() - this.getVolume();

        if (colorOffset < 0)
        {
            GetComponent<Renderer>().material.color = Color.red;
        }
        else
        {

            GetComponent<Renderer>().material.color = Color.green;
        }



    }

    public void OnDestroy()
    {
        gameManager.sphereList.Remove(this);
    }
}
