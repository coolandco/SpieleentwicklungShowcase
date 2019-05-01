using System.Collections;
using System.Collections.Generic;
using System.Linq.Expressions;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class gameManager : MonoBehaviour {

    public static float amountOfSpheres = 350;
    public static float maxRadius = 2f;//radius between 0 and maxRadius for random spheres

    public enum ENDREASON { won,cantWin,gotEaten,exit };
    public static string ENDMESSAGE_WON = "Congratulations, you are the biggest Sphere. You won.";
    public static string ENDMESSAGE_LOST_GOTEATEN = "Oh, you got eaten by a bigger Sphere. You lost.";
    public static string ENDMESSAGE_LOST_CANTWIN = "You can't win anymore. The other spheres are all bigger than you. You lost.";

    //private string endmessage = "";


    public static List<sphereRules> sphereList = new List<sphereRules>(); // we want that one sorted from the smallest to the biggest
    public static controllableSphere mySphere;

    [SerializeField]
    private Text massText;

    [SerializeField]
    private Slider massSlider;

    [SerializeField]
    private AudioSource backgroundMusic;

    [SerializeField]
    private InformationKeeper infKeeper;

    //if a game goal is up for longer than 10 sec, you have won or lost
    private float timeForGameDecision = 10f;
    private float currentTimeForGameDecision;

    [SerializeField]
    public GameObject randomSphere_Prefab;


    void Awake()
    {
        sphereRules.resetWholeVolume();//safety
        sphereList = new List<sphereRules>();//safety
    }

    // Use this for initialization
    void Start () {
        //we want to tell tehe menu the reason for exiting the game
        //DontDestroyOnLoad(this.gameObject);

        //cross reference of mySphere
        BroadcastMessage("setGameManager", this, SendMessageOptions.RequireReceiver);

        //mySphere = GetComponentInChildren<controllableObject>();
        //mySphere.setGameManager(this);

        //this loads all static settings of the classes
        LoadSettings();

        //set the timer for win/loose
        currentTimeForGameDecision =  timeForGameDecision;

        //create the spheres
        for (int i = 0; i < amountOfSpheres; i++)
        {
            //random position on playing field
            Vector3 randomPosition = new Vector3(Random.value * sphereRules.maxPlayingField, Random.value * sphereRules.maxPlayingField, Random.value * sphereRules.maxPlayingField);

            GameObject go = GameObject.Instantiate(randomSphere_Prefab, randomPosition, Quaternion.identity);
            //go.GetComponent<sphereRules>().setRealRadius(Random.value * maxRadius);

            //tell it the radius it has to set
            go.SendMessage("setRealRadius", Random.value * maxRadius, SendMessageOptions.RequireReceiver);

        }


        //for every second check win status once
        StartCoroutine(checkWinStatus());
        //update my mass
        StartCoroutine(updateHUD());
        //the mass slider blinking
        StartCoroutine(updateMassSlider());

        backgroundMusic.Play();

    }

    private void LoadSettings()
    {
        SettingsLoader loader = SettingsLoader.instance;
        Debug.Log(loader.isSettingsLoaded() + " :loader");
        //if settings loader not ready, then return
        if (loader == null || !loader.isSettingsLoaded())
            return;

        loader.getSetting(GetMemberName(() => sphereRules.maxPlayingField), ref sphereRules.maxPlayingField);
        loader.getSetting(GetMemberName(() => sphereRules.snapValue),ref sphereRules.snapValue);
        loader.getSetting(GetMemberName(() => sphereRules.massTransferDivisor),ref sphereRules.massTransferDivisor);

        loader.getSetting(GetMemberName(() => controllableSphere.maxTransSpeed),ref controllableSphere.maxTransSpeed);
        loader.getSetting(GetMemberName(() => controllableSphere.maxRotSpeed),ref controllableSphere.maxRotSpeed);

        loader.getSetting(GetMemberName(() => gameManager.amountOfSpheres), ref gameManager.amountOfSpheres);
        loader.getSetting(GetMemberName(() => gameManager.maxRadius), ref gameManager.maxRadius);

        loader.getSetting(GetMemberName(() => randomSpheres.minSpeed), ref randomSpheres.minSpeed);
        loader.getSetting(GetMemberName(() => randomSpheres.maxSpeed), ref randomSpheres.maxSpeed);

    }

    //because we are on a c# 4 plattform the "nameof" expression is not available
    //we use this, to not hardcode the string
    //this returns the name of a given variable
    public static string GetMemberName<T>(Expression<System.Func<T>> memberExpression)
    {
        MemberExpression expressionBody = (MemberExpression)memberExpression.Body;
        return expressionBody.Member.Name;
    }

    IEnumerator checkWinStatus()
    {
        int checkedInterval = 1;

        while (true)
        {
            //wait one second first. otherwise the other spheres have not been initialized
            yield return new WaitForSeconds(checkedInterval);

            //=============================================================
            gameManager.sphereList.Sort();//biggest > smallest
            


            //=============================================================
            //check if lost
            bool canWin = true;

            float volumeMySphereHas = 0;
            //solange nicht das letzte element erreicht ist
            //das letzte element ist zu schlagen
            for (int i = sphereList.Count - 1; i >= 0; i--)
            {

                //prüfe ob mySphere die Kugel aufnehmen kann
                if (mySphere.getVolume() + volumeMySphereHas < sphereList[i].getVolume())
                {
                    canWin = false;
                    break;
                }

                //nehme sie auf
                volumeMySphereHas += sphereList[i].getVolume(); //add the volume to the volumeMySphereHas

                //und prüfe if sie die nächste kugel auch aufnehmen kann in der nächsten runde
            }

            //do something if not can win
            if (!canWin)
            {
                currentTimeForGameDecision -= checkedInterval;//there is always 1 second between checks
                if (currentTimeForGameDecision < 0)
                    gameEnd(gameManager.ENDREASON.cantWin);
            }
            else//there t constellations we can win again. so reset this timer
            {
                currentTimeForGameDecision = timeForGameDecision;
            }
                


            //=============================================================
            //Check if won
            //we won if we have more than half of the whole mass

            if (mySphere.getVolume() > (sphereRules.getWholeVolume() / 2f))
            {
                gameEnd(gameManager.ENDREASON.won);
            }
        }
    }

    public void gameEnd(gameManager.ENDREASON reason)
    {
        Debug.Log("Endreason: " + reason);

        //makes shure non of the started corutienes will run
        //StopAllCoroutines();

        //StopCoroutine(checkWinStatus());
        //StopCoroutine(updateHUD());

        if(reason == ENDREASON.cantWin)
        {
            infKeeper.setEndmessage(ENDMESSAGE_LOST_CANTWIN);
            //endmessage = ENDMESSAGE_LOST_CANTWIN;
        }
        else if(reason == ENDREASON.gotEaten)
        {
            infKeeper.setEndmessage(ENDMESSAGE_LOST_GOTEATEN);
            //endmessage = ENDMESSAGE_LOST_GOTEATEN;
        }
        else if (reason == ENDREASON.won)
        {
            infKeeper.setEndmessage(ENDMESSAGE_WON);
            //endmessage = ENDMESSAGE_WON;
        }else if(reason == ENDREASON.exit)
        {
            infKeeper.setEndmessage("");//empty message
        }

        //stop Music
        backgroundMusic.Stop();

        Debug.Log("Load Scene: MainMenu");
        //load menu again
        SceneManager.LoadScene("MainMenu");
    }

    //called once per frame
    IEnumerator updateHUD()
    {
        while (true)
        {
            //text on HUD
            //no decimal if bigger 1
            if (mySphere.getVolume() < 1)
                massText.text = mySphere.getVolume().ToString();
            else
                massText.text = ((int)mySphere.getVolume()).ToString();
           // massText.text = mySphere.getVolume().ToString();

            //slider, percentage of whole
            massSlider.value = mySphere.getVolume() / sphereRules.getWholeVolume();

            yield return null;
        }
	}

    IEnumerator updateMassSlider()
    {
        Image sliderFill = null;
        foreach(Image img in massSlider.GetComponentsInChildren<Image>())
        {
            if (img.sprite.name.Equals("UISprite"))//fill component
            {
                sliderFill = img;
            }
        }

        if(sliderFill == null) {//no img found
            yield break;
        }

        //set green
        sliderFill.color = Color.green;

        while (true)
        {
            //switch between red and green
            //if not switching, stay red
            if(currentTimeForGameDecision < timeForGameDecision)
            {

                if (sliderFill.color.Equals(Color.green))
                {
                    sliderFill.color = Color.red;
                }
                else
                {
                    sliderFill.color = Color.green;
                }
            }
            else
            {
                sliderFill.color = Color.green;
            }


            yield return new WaitForSeconds(0.4f);
        }
        
    }

    public void Update()
    {
        //if user wants to exit
        if (Input.GetButtonDown("Cancel"))
        {
            gameEnd(ENDREASON.exit);
        }
    }

    //sets the mySphere object
    public void setMySphere(controllableSphere mySphere)
    {
        gameManager.mySphere = mySphere;
    }
}
