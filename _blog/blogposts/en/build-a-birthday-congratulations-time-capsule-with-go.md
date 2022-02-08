---
title: Build a Birthday Congratulations Time Capsule with Go
description: In this tutorial we're going to learn how to build a birthday time
  capsule with Go. The pandemic has taught us that even though we're not at time
  physically able to visit friends and family. Life does still go on! So
  creating virtual methods for these events is needed.
thumbnail: /content/blog/build-a-birthday-congratulations-time-capsule-with-go/go_birthday_voiceapi_1200x600.png
author: greg-holmes
published: true
published_at: 2021-06-22T11:59:14.531Z
updated_at: 2021-06-10T11:59:01.939Z
category: tutorial
tags:
  - go
  - voice-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Intro

With the pandemic, we've at times been forced into virtual interactions with our family and friends. But even with a pandemic going on, our lives have continued. People are still getting married; birthdays still come around once a year for everyone.  

So when my birthday came around, it also reminded me of something my grandmother used to do every year. She'd call me first thing in the morning and sing happy birthday down the phone to me.  

This memory triggered an idea in my head to create a birthday time capsule where all of your friends and family call a number. When they call, they can leave their well-wishes as a voice recording. Then, you would receive a call and hear all of the well-wishing recordings at a predetermined date and time.

## Prerequisites

To complete this tutorial you will need:

* [Go](https://golang.org/)
* [Ngrok](https://ngrok.com/)
* An active phone number

<sign-up number></sign-up>

## Create Ngrok Tunnel

When making or receiving voice calls, Vonage will send an HTTP request to your preconfigured webhook URLs. Your application should be accessible to the internet to receive it, so we recommend [using Ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr).

Launch ngrok with the following command:

```bash
ngrok http 8080 # Creates an http tunnel to the Internet from your computer on port 8080
```

Make sure to copy your ngrok HTTPS URL, as you'll need this later when configuring the project.

## Create Vonage Application with Webhooks

This project will rely on listening to the inbound webhook requests made by the Vonage APIs, so we'll need to create a new application. Go ahead and create a new [application](https://dashboard.nexmo.com/applications/new) with the following input:

* Name - this can be anything you wish; it's a name only you will see
* Capabilities

  * Voice

    * Under `Answer URL` add: `<your ngrok url>/webhooks/answer`
    * Under `Event URL` add: `<your ngrok url>/webhooks/event`
  * RTC (In-app voice & messaging)

    * Under `Event URL` add: `<your ngrok url>/webhooks/event`
* Click "Generate public & private key" and move the `private.key` file into your project directory.
* Click "Save changes"

Your application is now ready to send you any predefined webhooks!

> **Note** If you're using ngrok without an account, `<your ngrok url>` will be different every time you run ngrok. Remember to update your webhook URLs every time you run the command. Alternatively, sign up for a free account to make the URL persist.

## Collect Voice Recordings

The first half of this project is to receive the voice recordings from the well-wishers.

### Install Required Packages

We will need several third-party Go libraries to successfully run this project. These include the following:

* `joho/godotenv` - to securely store our Vonage credentials
* `vonage/vonage-go-sdk` - to make our API requests at Vonage
* `gorm` and `sqlite` to store the voice message file names and whether they've been played into an SQLite database

To install these third-party libraries, run the following four commands:

```go
go get github.com/joho/godotenv
go get github.com/vonage/vonage-go-sdk
go get gorm.io/gorm
go get gorm.io/driver/sqlite
```

To make use of `joho/gotdotenv` package, and start storing your credentials in a file, create your `.env` file in your project directory and add the following variables:

```dotenv
VONAGE_APPLICATION_ID=
VONAGE_PRIVATE_KEY_PATH=private.key
VONAGE_NUMBER=
TO_NUMBER=
PERSON_NAME=
NGROK_URL=
```

Be sure to populate these variables with the correct values you've gathered in previous steps. Below is a list of how to gain all of the required values:

* `VONAGE_APPLICATION_ID` - Your application ID is the ID given when you created an application in Vonage's [dashboard](https://dashboard.nexmo.com/applications)
* `VONAGE_PRIVATE_KEY` - The location of the `private.key` file relevant to the project directory
* `VONAGE_NUMBER` - Your Vonage number is the virtual phone number you purchased in the [Vonage Dashboard](https://dashboard.nexmo.com/your-numbers)
* `TO_NUMBER` - The number that will be receiving the call with all the voice recordings at your predetermined date and time
* `PERSON_NAME` - The name of the person who will be receiving these well wishes
* `NGROK_URL` - The ngrok URL you received and stored in a previous step

Structs are typed collections of fields that we'll use to group data from webhook requests throughout this tutorial. Create a new file called `structs.go` and add the following:

```go
package main

type Dtmf struct {
	Digits    string
	Timed_out bool
}

type EventResponse struct {
	Conversation_id string
	Type            string
	Body            EventBodyResponse
}

type EventBodyResponse struct {
	Channel EventBodyChannelResponse
}

type EventBodyChannelResponse struct {
	Id   string
	Type string
}

type Recording struct {
	Start_time        string
	Recording_url     string
	Size              int
	Recording_uuid    string
	End_time          string
	Conversation_uuid string
	Timestamp         string
}

type Response struct {
	Speech            []string
	Dtmf              Dtmf
	From              string
	To                string
	Uuid              string
	Conversation_uuid string
	Timestamp         string
}
```

Now we've created some of the boring bits to get started, let's create the project's main file, `main.go`, in your project directory and add the following code to it:

```go
package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"github.com/vonage/vonage-go-sdk/jwt"
)

func main() {
	err := godotenv.Load()

	if err != nil {
		log.Fatal("Error loading .env file")
	}

  connectDb()

	http.ListenAndServe(":8080", nil)
}
```

The code in the example above is the initial structure for the project. It currently loads the `.env` file into the project and creates a web server listening on port `8080`.

### Creating the Database Model

To save the file name of the audio files and whether they were played or not, we'll need to create a database. Let's create the model `BirthdayEntry` and a function `connectDb()` to handle connecting to our database. Create a new file called `models.go` and add the following code:

```go
package main

import (
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var db *gorm.DB
var err error

type BirthdayEntry struct {
	gorm.Model
	FileName string
	Played   bool
}

func connectDb() {
	db, err = gorm.Open(sqlite.Open("voiceRecordings.db"), &gorm.Config{})

	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&BirthdayEntry{})
}
```

### Handling the Answering of a Call

There will be multiple steps to the recording process of a voice message. The first one will answer the initial call and instruct the Vonage APIs on what to do next. So, create a new file in your project directory called `recording.go` and add the following:

```go
package main

import (
	"encoding/json"
	"errors"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"time"

  "github.com/vonage/vonage-go-sdk"
	"github.com/vonage/vonage-go-sdk/ncco"
	"github.com/vonage/vonage-go-sdk/jwt"
)

func answer(w http.ResponseWriter, req *http.Request) {
	MyNcco := ncco.Ncco{}
	talk := ncco.TalkAction{Text: "Thank you for calling the birthday congratulations hotline for " + os.Getenv("PERSON_NAME") + ".. If you would like to leave a message, please press 1. Otherwise end the call. Thank you"}
	MyNcco.AddAction(talk)

	inputAction := ncco.InputAction{EventUrl: []string{"https://" + req.Host + "/webhooks/record"}, Dtmf: &ncco.DtmfInput{MaxDigits: 1}}
	MyNcco.AddAction(inputAction)

	data, _ := json.Marshal(MyNcco)

	w.Header().Set("Content-Type", "application/json")
	w.Write(data)
}
```

The above functionality will create a new Call Control Object (NCCO) with two actions to be carried out. The first action will be to "Talk", converting predefined text into voice, and the second one will be to handle user's input via Dual Tone Multi-Frequency (DTMF), with another predefined webhook URL.

These actions are then converted into a JSON object and returned in the request.

This function is currently unused, so let's change that!
Back in `main.go` within the `main()` function, add the following line of code, which tells the webserver to listen for the URL `webhooks/answer`, and when triggered, call the `answer()` function:

```go
// First Step - Answer phone call
http.HandleFunc("/webhooks/answer", answer)
```

### Recording the Call

When in a voice call, the `RecordAction` in the NCCO is triggered and starts recording anything your microphone will pick up. When you trigger the `RecordAction`, you need to define the webhook URL to provide you with the details of the recorded file upon completion of the call.  

To trigger a recording, you'll first need to register two new routes in your webserver. In your `main.go` file below your call to the `answer` function, add the following two lines:

```go
// Second Step - Take Voice Recording
http.HandleFunc("/webhooks/record", recordUsersMessage)
// Third Step - Receive Voice Recording confirmation + Download the file
http.HandleFunc("/webhooks/recording-file", getFileRecording)
```

In your `recording.go` file, one of the functions you defined in the step above is the `recordUsersMessage()` function, triggered when the user inputs their DTMF response into the call (Pressing 1, for example). This function will create a new NCCO, which will first convert some text to speech, thanking them, then requesting they leave a message after the tone. 

The second action is a `RecordAction`, which tells the API to record whatever is said after the tone. Add this new function to your file:

```go
func recordUsersMessage(w http.ResponseWriter, req *http.Request) {
	data, _ := ioutil.ReadAll(req.Body)
	var response Response
	json.Unmarshal(data, &response)

	MyNcco := ncco.Ncco{}
	talk := ncco.TalkAction{Text: "Thank you. Please leave a message after the tone."}
	MyNcco.AddAction(talk)

	recordAction := ncco.RecordAction{EventUrl: []string{"https://" + req.Host + "/webhooks/recording-file"}, Format: "mp3", BeepStart: true, EndOnSilence: 10}
	MyNcco.AddAction(recordAction)

	responseData, _ := json.Marshal(MyNcco)

	w.Header().Set("Content-Type", "application/json")
	w.Write(responseData)
}
```

### Saving the Audio File

Once a voice recording is completed, a call to the `/webhooks/recording-file` path is triggered with JSON, similar to the example below:

```json
{
  "start_time": "2020-01-01T12:00:00Z",
  "recording_url": "https://api.nexmo.com/v1/files/aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "size": 12345,
  "recording_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "end_time": "2020-01-01T12:01:00Z",
  "conversation_uuid": "bbbbbbbb-cccc-dddd-eeee-0123456789ab",
  "timestamp": "2020-01-01T14:00:00.000Z"
}
```

In this JSON example, we can see the `recording_url`, which is vital for our tutorial to work. This recording URL is protected; you need to generate a JSON Web Token (JWT) and provide it with the `GET` request when pulling that recording file.   

The first step is to create a new row in the database for this file, create the file name (Unix timestamp) and call the `downloadFile()` function. Then, in your `recordings.go` file, add the following function:

```go
func getFileRecording(w http.ResponseWriter, req *http.Request) {
	data, _ := ioutil.ReadAll(req.Body)
	var recording Recording
	json.Unmarshal(data, &recording)

	responseData, _ := json.Marshal(data)

	fileName := strconv.FormatInt(time.Now().UTC().UnixNano(), 10) + ".mp3"
	err := downloadFile(recording.Recording_url, fileName)

	if err != nil {
		log.Fatal(err)
	}

	birthdayEntry := BirthdayEntry{FileName: fileName, Played: false}

	_ = db.Create(&birthdayEntry)

	w.Header().Set("Content-Type", "application/json")
	w.Write(responseData)
}
```

#### Downloading the File

You may have noticed that we don't yet have the `downloadFile()` function called in the example above. Our next step is to add this as well as another function to generate our JWT. The JWT needs passing as a header in the request.  
Add the following to your `recordings.go` file. This action will download the audio file from Vonage servers and save it as a file in the `recordings` directory with the predetermined file name.

```go
func downloadFile(audioUrl string, fileName string) error {
	//Get the response bytes from the url
	reqUrl, _ := url.Parse(audioUrl)
	token := generateJWT()
	request := &http.Request{
		Method: "GET",
		URL:    reqUrl,
		Header: map[string][]string{
			"Authorization": {"Bearer " + token},
		},
	}

	response, err := http.DefaultClient.Do(request)

	if err != nil {
		log.Fatal("Error:", err)
	}

	defer response.Body.Close()

	if response.StatusCode != 200 {
		return errors.New("received non 200 response code")
	}

	file, err := os.Create("./recordings/" + fileName)

	if err != nil {
		return err
	}

	defer file.Close()

	_, err = io.Copy(file, response.Body)

	if err != nil {
		return err
	}

	return nil
}
```

We still haven't generated our JWT token! So, using Vonage's Go SDK, add the following function to `recordings.go`. This function uses your `VONAGE_APPLICATION_ID` and your `VONAGE_PRIVATE_KEY_PATH` environment variables to generate a new JWT.

```go
func generateJWT() string {
	applicationId := os.Getenv("VONAGE_APPLICATION_ID")
	privateKey, _ := ioutil.ReadFile(os.Getenv("VONAGE_PRIVATE_KEY_PATH"))
	g := jwt.NewGenerator(applicationId, privateKey)

	token, _ := g.GenerateToken()

	return token
}
```

That's it for the part of the system that collects the voice calls; before we move on to the second half of the tutorial, we're going to want to test this half from start to finish.

First, make sure your project is running. In your Terminal, inside your project directory, run the command:

```bash
go run .
```

You should still have ngrok running, so go ahead and call your Vonage virtual number using your phone.

The first response is the following voice message: "Thank you for calling the birthday congratulations hotline for <insert name here>.. If you would like to leave a message, please press 1. Otherwise end the call. Thank you".

If you press one on your keypad, you'll then hear: "Thank you. Please leave a message after the tone.". Now record yourself saying a few words and hang up.

A few seconds after completion of the phone call, check your `recordings` directory. You'll see a new file created.

It's time to build the part of the system for the birthday person!

## Calling the Birthday Person

### Create a Cronjob and Congratulate

This project needs a method to run one of the functions at a specific date and time.  
The cron job is a time scheduler in Unix operating systems. This project will use a cron library for Go to define a particular date and time on running a specific function.  

In your Terminal, run the command below to install this cron library:

```bash
go get github.com/robfig/cron
```

Inside your the `main()` function within your `main.go` we're going to call a function yet to be created, `runCongratulateCron()`, so add this below the part where you call `connectDb()`:

```go
runCongratulateCron()
```

To keep the functionality separate from the first part of the tutorial, we will add the necessary functionality for this part in a separate file. Create a new file called `congratulate.go` and add the following code:

```go
package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

  "github.com/robfig/cron"
	"github.com/vonage/vonage-go-sdk"
	"github.com/vonage/vonage-go-sdk/ncco"
)

func runCongratulateCron() {
	c := cron.New()
	// This would be triggered at midnight on 1st Jan
	c.AddFunc("0 0 0 1 1 *", func() {
		congratulate()
	})
	c.Start()
}

func congratulate(w http.ResponseWriter, req *http.Request) {
	privateKey, _ := ioutil.ReadFile(os.Getenv("VONAGE_PRIVATE_KEY_PATH"))
	auth, _ := vonage.CreateAuthFromAppPrivateKey(os.Getenv("VONAGE_APPLICATION_ID"), privateKey)
	client := vonage.NewVoiceClient(auth)

	from := vonage.CallFrom{Type: "phone", Number: os.Getenv("VONAGE_NUMBER")}
	to := vonage.CallTo{Type: "phone", Number: os.Getenv("TO_NUMBER")}

	MyNcco := ncco.Ncco{}

	talkAction := ncco.TalkAction{Text: "Happy Birthday! I have collected a number of recordings from your friends and family wishing you a happy birthday. If you would like to listen to this, please press 1."}
	MyNcco.AddAction(talkAction)

	inputAction := ncco.InputAction{EventUrl: []string{"https://" + os.Getenv("NGROK_URL") + "/webhooks/play-audio"}, Dtmf: &ncco.DtmfInput{MaxDigits: 1}}
	MyNcco.AddAction(inputAction)

	conversationAction := ncco.ConversationAction{Name: os.Getenv("TO_NUMBER"), StartOnEnter: "false"}
	MyNcco.AddAction(conversationAction)

	client.CreateCall(vonage.CreateCallOpts{From: from, To: to, Ncco: MyNcco})
}
```

The above code has two functions.  
First, the `runCongratulateCron()` function defines a new cronjob and adds the specified time for the birthday person to receive their phone call. If you're unsure how to set up the times with a cronjob, please check the [Crontab Guru](https://crontab.guru/) to build your custom time set.

The second function gets called from the first one, and this makes the outbound Text-To-Speech voice call to the birthday person, then asks them for an InputAction ("Press 1 to continue"). 
To keep the call active for the receiver, a `ConversationAction` is needed. We'll learn how to play the audio into the call in the next step, but this needs to be done in an active conversation.

### Play Audio Into a Call

Now that we have a call, we need to add the code to play the audio files into the voice call. To do this, you'll need to grab the UUID and pass it into a request calling the `PlayAudioStream` function, alongside the URL of the file you wish to play first.

> **Note** you cannot queue the audio files. If you loop through playing each audio file into the call, it will interrupt each audio file with the latest one. To avoid this, we need to play the file and then wait for an event to come in on completion. We then find the next unplayed one in the database and play that one on completion of the previous audio file.

So, in `congratulate.go` add the following code:

```go
func congratulatePlayAudio(w http.ResponseWriter, req *http.Request) {
	data, _ := ioutil.ReadAll(req.Body)
	var response Response
	json.Unmarshal(data, &response)

	playAudio(response.Uuid, req.Host)
}

func playAudio(uuid string, host string) {
	var birthdayEntry BirthdayEntry

	privateKey, _ := ioutil.ReadFile(os.Getenv("VONAGE_PRIVATE_KEY_PATH"))
	auth, _ := vonage.CreateAuthFromAppPrivateKey(os.Getenv("VONAGE_APPLICATION_ID"), privateKey)
	client := vonage.NewVoiceClient(auth)

	if err := db.First(&birthdayEntry, "played = ?", false).Error; err != nil {
		client.PlayTts(uuid, "This is the end of your birthday wishes, you may now hang up.", vonage.PlayTtsOpts{})

		return
	}

	fmt.Println("https://" + host + "/" + birthdayEntry.FileName)

	result, _, _ := client.PlayAudioStream(uuid,
		"https://"+host+"/"+birthdayEntry.FileName,
		vonage.PlayAudioOpts{},
	)

	birthdayEntry.Played = true
	db.Save(&birthdayEntry)

	fmt.Println("Update message: " + result.Message)
}
```

In `main.go` find the line `http.HandleFunc("/webhooks/recording-file", getFileRecording)` and add the following:

```go
http.HandleFunc("/congratulate", congratulate)
http.HandleFunc("/webhooks/play-audio", congratulatePlayAudio)
```

### Trigger Request to Play Next Audio File

As previously discussed, we need to play the next audio file into the call upon completing the previous one. Using the previously defined webhook URL under: `RTC (In-app voice & messaging)` in the dashboard, we'll listen for a specific event that contains a particular key in the request. By listening to the `event.type` part of the request, we'll be able to check if the value is: `audio:play:done`, and then call the function `playAudio` to find the following unplayed audio file.

Inside `congratulate.go` add this new `event` function:

```go
func event(w http.ResponseWriter, req *http.Request) {
	var event EventResponse

	err := json.NewDecoder(req.Body).Decode(&event)

	if err != nil {
		return
	}

	if event.Type == "audio:play:done" {
		playAudio(event.Body.Channel.Id, req.Host)
	}
}
```

Then, in `main.go`, under the line `http.HandleFunc("/webhooks/play-audio", congratulatePlayAudio)` add:

```go
	http.HandleFunc("/webhooks/event", event)
```

That's it! We've now created our birthday celebrations time capsule with Go! Below we'll run through the step-by-step process to test the functionality.

## Test It!

Now that we've built this project, let's outline the process from start to finish:

1. Well-wishers call your virtual Vonage number
2. Your app answers the call with a Text-To-Speech message: "Thank you for calling the birthday congratulations hotline for <insert name here>.. If you would like to leave a message, please press 1. Otherwise, end the call. Thank you"
3. The app waits for you to input a number in your keypad.
4. The next webhook receives a request, sends a Text-To-Speech message: "Thank you. Please leave a message after the tone."
5. A beep happens, and the call is now recording anything picked up from your microphone.
6. You end the call when you're finished.

However, many well-wishers can repeat steps 1-6 there are.

7. At the specified time (Defined in the `runCongratulateCron()` function), the function `congratulate()` is called.
8. The application to the birthday person makes an outbound call.
9. On answering the call, the receiver is presented with "Happy Birthday! I have collected several recordings from your friends and family wishing you a happy birthday. If you would like to listen to this, please press 1."
10. The call is now waiting for the receiver to press a number on their keypad.
11. The application will then retrieve the first unplayed audio file from the database and stream it into the voice call.
12. On completion of the audio file stream, an event is sent back to the application. When this event is received, the application finds the next unplayed audio file and streams it through the call.
13. When there are no unplayed audio files, the call is ended.

You've now integrated a birthday celebrations time capsule with Go, using Vonage's Voice API. The example provided is just one of many ways to use the Voice API.

If this tutorial has piqued your interest in our Voice API, but Go isn't the language of your choice, other tutorials in various languages or services can be found here on the [Vonage blog](https://learn.vonage.com), such as:

* [Random Facts Voice Call With PHP, Uselessfacts and AWS Lambda](https://learn.vonage.com/blog/2021/04/13/random-fact-voice-call-with-php-uselessfacts-and-aws-lambda/)
* [Connecting Voice Calls to an Amazon Lex Bot](https://learn.vonage.com/blog/2021/03/10/connecting-voice-calls-to-an-amazon-lex-bot/)
* [Introducing the Vonage Voice API on Zapier](https://learn.vonage.com/blog/2021/01/21/introducing-the-vonage-voice-api-on-zapier/)
* [Build an Interactive Voice Response with Go](https://learn.vonage.com/blog/2021/02/11/build-an-interactive-voice-response-with-go/)

If you have any questions, advice, or ideas you'd like to share with the community, please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack), or contact me on [Twitter](https://www.twitter.com/greg__holmes). I'd love to hear back from anyone that has implemented this tutorial and how your project works.
