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
NCCO request:
  - caller: 447700900000
  - callee: 442038297050
```

Also, as the call progresses through various stages, `/voice/event` is being sent events:

```bash
EVENT:
{
  headers: {},
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'ringing',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:05.582Z'
}
---
EVENT:
{
  headers: {},
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:05.582Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'answered',
  direction: 'inbound',
  network: null,
  timestamp: '2021-03-29T21:20:06.182Z'
}
---
EVENT:
{
  from: '447700900000',
  to: 'Alice',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-29T21:20:13.025Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447700900000',
  to: 'Alice',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-29T21:20:13.025Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-29T21:20:16.000Z',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  network: null,
  duration: '5',
  start_time: '2021-03-29T21:20:11.000Z',
  rate: '0.00',
  price: '0',
  from: '447700900000',
  to: 'Alice',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-29T21:20:17.574Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-29T21:20:18.000Z',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  network: 'GB-FIXED',
  duration: '12',
  start_time: '2021-03-29T21:20:06.000Z',
  rate: '0.00720000',
  price: '0.00144000',
  from: ' 447700900000',
  to: '442038297050',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:17.514Z'
}
---
```