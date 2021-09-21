## Associate an application with your webhook

To link your number to the endpoint you've now created you will need to create an Application:

```
$ vonage apps:create demo --voice_answer_webhook=<YOUR_HOSTNAME>/webhooks/answer --voice_event_webhook=<YOUR_HOSTNAME>/webhooks/event
$ vonage apps:link <APPLICATION_ID> --number=<VONAGE_NUMBER> 
```
