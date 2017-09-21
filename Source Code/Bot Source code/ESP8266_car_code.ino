/*************************************************************
  Blynk is a platform with iOS and Android apps to control
  Arduino, Raspberry Pi and the likes over the Internet.
  You can easily build graphic interfaces for all your
  projects by simply dragging and dropping widgets.

    Downloads, docs, tutorials: http://www.blynk.cc
    Blynk community:            http://community.blynk.cc
    Social networks:            http://www.fb.com/blynkapp
                                http://twitter.com/blynk_app

  Blynk library is licensed under MIT license
  This example code is in public domain.

 *************************************************************
 // ESP8266_car_code - Code for the NodeMCU ESP 8266 on the Bot  //
 //
 //
 // Created  By:  	 	Joel Jacob (JJ)
 // Modified By:  	  Nishad Saraf (NS),PArimal Kulkarni (PK),Chaitaniya Deshpande (DP)
 //
 //
 // Revision History:
 // -----------------
 // 10th March-2017     	  JJ  	        Created this module
 // 15th March-2017		     JJ	      		Modified for Testing.
 // 19th March-2017		    JJ,NS,CD		  Modified to implement final functionality.
 //
 // Description
 // -----------
 // This module implements an interface between the ESP 8266,that receives control information,
 // from the Main ESP8266 on the HUB FPGA using the Blynk Bridge API
 //////////

 *************************************************************/

/* Comment this out to disable prints and save space */
#define BLYNK_PRINT Serial


#include <ESP8266WiFi.h>
#include <BlynkSimpleEsp8266.h>

// You should get Auth Token in the Blynk App.
// Go to the Project Settings (nut icon).

char auth[] = "Auth Key"; //local server

// Your WiFi credentials.
// Set password to "" for open networks.

char ssid[] = "SSID";
char pass[] = "Pass";

//Set up global constants
int a = 0, b = 0, c = 0, d = 0, e = 0;

//Define pins
#define LED_PIN 0
#define LED_PIN_1 2

//Define GPIO ports
#define JC_0 12
#define JC_1 13
#define JC_2 14
#define JC_3 16
#define JC_4 2
#define JC_5 4
#define JC_6 5


//Car Control

//Capture input from the Blynk API and move bot appropriately.

BLYNK_WRITE(V0)
{
  e = param.asInt();
}
BLYNK_WRITE(V1) //Forward
{
  a = param.asInt();
  if (a == 1)
  {
    digitalWrite(D3, HIGH);
    digitalWrite(D4, LOW);

    digitalWrite(D1, HIGH);
    digitalWrite(D2, HIGH);
  }
  else
  {
    digitalWrite(D1, LOW);
    digitalWrite(D2, LOW);
  }
}
BLYNK_WRITE(V2) //Right
{
  b = param.asInt();
  if (b == 1)
  {
    digitalWrite(D1, LOW);
    digitalWrite(D2, HIGH);
  }
  else
  {
    digitalWrite(D2, LOW);
  }
}
BLYNK_WRITE(V3) //Left
{
  c = param.asInt();
  if (c == 1)
  {
    digitalWrite(D1, HIGH);
    digitalWrite(D2, LOW);
  }
  else
  {
    digitalWrite(D1, LOW);
  }
}
BLYNK_WRITE(V4) //Reverse
{
  d = param.asInt();
  if (d == 1)
  {
    // reverse direction
    digitalWrite(D3, LOW);
    digitalWrite(D4, HIGH);

    digitalWrite(D1, HIGH);
    digitalWrite(D2, HIGH);
  }
  else
  {
    digitalWrite(D1, LOW);
    digitalWrite(D2, LOW);
  }

}
void setup()
{
  //  Debug console
  Serial.begin(115200);
  // You can also specify server:
  Blynk.begin(auth, ssid, pass, IPAddress(0, 0, 0, 0), 8442);

  //Car output
  pinMode(D1, OUTPUT);
  pinMode(D2, OUTPUT);
  pinMode(D3, OUTPUT);
  pinMode(D4, OUTPUT);

}

void loop()
{
  Blynk.run();

}
