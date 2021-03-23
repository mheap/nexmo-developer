---
title: Receive a call
description: In this step you will receive the call.
---

# Receive a call

At the top of the `ViewController` class, below the `client` declaration, add a `NXMCall` property to hold a reference to any call in progress.

```objective_c
 @interface ViewController () <NXMClientDelegate>
 @property UILabel *connectionStatusLabel;
 @property NXMClient *client;
 @property NXMCall * call;
 @end
 ```

When the application receives a call you will want to give the option to accept or reject the call. To do this add the `displayIncomingCallAlert` function to the `ViewController` class.

```objective_c
- (void)displayIncomingCallAlert:(NXMCall *)call {
    NSString *from = call.otherCallMembers.firstObject.channel.from.data;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.call = call;
        [call answer:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [call reject:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
```
The `displayIncomingCallAlert` function takes a `NXMCall` as a parameter, with this you can access the members, which are the type `NXMCallMember`, of the call to retrieve the phone number of the incoming call. Note in the `UIAlertAction` for answering the call you assign the call to the property from earlier.

To use `displayIncomingCallAlert` you need to use the `NXMClientDelegate` which has a function that will be called when the client receives an incoming `NXMCall`.

```objective_c
- (void)client:(NXMClient *)client didReceiveCall:(NXMCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:call];
    });
}
```

> **NOTE:** Also, please make sure that the webhook server you built in the previous steps is still running. 

Press `Cmd + R` to build and run again, when you call the number linked with your application from earlier you will be presented with an alert. You can pick up and the call will be connected!

![Incoming call alert](/meta/client-sdk/ios-phone-to-app/alert.png)

## Webhooks

As you proceed with the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO:

```bash
EVENT:
{
  headers: {},
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'ringing',
  direction: 'inbound',
  timestamp: '2021-03-23T13:21:56.882Z'
}
---
NCCO request:
  - from: 447000000000
---
EVENT:
{
  headers: {},
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-23T13:21:56.882Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'answered',
  direction: 'inbound',
  network: null,
  timestamp: '2021-03-23T13:21:57.846Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: 'Unknown',
  to: 'Alice',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-23T13:22:05.841Z'
}
---
EVENT:
{
  from: 'Unknown',
  to: 'Alice',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-23T13:22:05.841Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-23T13:22:08.000Z',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  network: '23409',
  duration: '11',
  start_time: '2021-03-23T13:21:57.000Z',
  rate: '0.00720000',
  price: '0.00132000',
  from: '447000000000',
  to: '447441444905',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-23T13:22:08.706Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-23T13:22:08.000Z',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  network: null,
  duration: '3',
  start_time: '2021-03-23T13:22:05.000Z',
  rate: '0.00',
  price: '0',
  from: 'Unknown',
  to: 'Alice',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-23T13:22:09.292Z'
}
---
```