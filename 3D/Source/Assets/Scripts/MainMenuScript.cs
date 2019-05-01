using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MainMenuScript : MonoBehaviour {

    [SerializeField]
    private Text endtext;

    [SerializeField]
    private AudioSource backgroundMusic;

    private void Start()
    {
        //this starts the loading process from settings
        StartCoroutine(SettingsLoader.Instance.Start());

        //if we went to the menu because a game ended, we will have a game manager 
        //find it and get the message
        GameObject gm = GameObject.Find("InformationKeeper");
        if (gm != null)
            endtext.text = gm.GetComponent<InformationKeeper>().getEndmessage();
        else
            endtext.text = "";
        //Debug.Log(transform.parent.GetComponent<gameManager>().getEndmessage());

        backgroundMusic.Play();

        //unlock cursor
        Cursor.lockState = CursorLockMode.None;
        // Hide cursor when locking
        Cursor.visible = true;

    }


    public void loadLevel()
    {
        backgroundMusic.Stop();

        Cursor.lockState = CursorLockMode.Locked;
        // Hide cursor when locking
        Cursor.visible = false;


        Debug.Log("called Load Level");
        SceneManager.LoadScene("MainGame");
    }
}
