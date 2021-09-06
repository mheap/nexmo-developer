---
title: Place a call
description: In this step you will place the call.
---

# Place a call

Add a `NXMCall` property to the interface to hold a reference to any call in progress:

```objective_c
@interface ViewController () <NXMClientDelegate>
@property UIButton *callButton;
@property UILabel *connectionStatusLabel;
@property NXMClient *client;
@property NXMCall * call;
@end
```

Based on the object referenced by the `call` property, the `callButtonPressed` method can now be used to either place or end calls; the `placeCall` and `endCall` methods are triggered for each case. 

Please make sure to replace `PHONE_NUMBER` below with the actual phone number you want to call. Note: must be the same one as the one specified in the gist NCCO:

```objective_c
- (void)callButtonPressed {
    if (!self.call) {
        [self placeCall];
    } else {
        [self endCall];
    }
}

- (void)placeCall {
    [self.client serverCallWithCallee:@"PHONE_NUMBER" customData:nil completionHandler:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if (error) {
            self.connectionStatusLabel.text = error.localizedDescription;
            return;
        }
        
        self.call = call;
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.callButton setTitle:@"End call" forState:UIControlStateNormal];
        });
    }];
}

- (void)endCall {
    [self.call hangup];
    self.call = nil;
    [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
}
```

> **NOTE:** Please make sure to replace `PHONE_NUMBER` below with the actual phone number you want to call, in the E.164 format (for example, 447700900000).

> **NOTE:** Also, please make sure that the webhook server you built in the previous steps is still running. 


That's it! You can now build, run and place the call! Magic!

Once the call comes through you can answer it and hear the in-app voice call.

Also, as the call progresses through various stages, `/voice/event` is being sent events:

``` bash
NCCO request:
  - callee: 447700900000
```

Also, as the call progresses through various stages, `/voice/event` is being sent events:

``` bash
...
---
VOICE EVENT:
{
  from: null,
  to: 'Alice',
  uuid: '2da93da3-bcac-47ee-b48e-4a18fae7db08',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-10T10:36:21.285Z'
}
---
VOICE EVENT:
{
  headers: {},
  from: 'Alice',
  to: '447700900000',
  uuid: '8aa86e22-8d45-4201-b8d8-3dcd76e76429',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-10T10:36:27.080Z'
}
---
...
---
VOICE EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: 'Alice',
  to: '447700900000',
  uuid: '8aa86e22-8d45-4201-b8d8-3dcd76e76429',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-10T10:36:31.604Z'
}
---
VOICE EVENT:
{
  headers: {},
  end_time: '2021-03-10T10:36:36.000Z',
  uuid: '8aa86e22-8d45-4201-b8d8-3dcd76e76429',
  network: '23433',
  duration: '5',
  start_time: '2021-03-10T10:36:31.000Z',
  rate: '0.10000000',
  price: '0.00833333',
  from: 'Unknown',
  to: '447700900000',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-10T10:36:35.585Z'
}
---
VOICE EVENT:
{
  headers: {},
  end_time: '2021-03-10T10:36:35.000Z',
  uuid: '2da93da3-bcac-47ee-b48e-4a18fae7db08',
  network: null,
  duration: '15',
  start_time: '2021-03-10T10:36:20.000Z',
  rate: '0.00',
  price: '0',
  from: null,
  to: 'Alice',
  conversation_uuid: 'CON-1a28b1f8-0831-44e6-8d58-42739e7d4c77',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-10T10:36:36.187Z'
}
```

> **NOTE:** As the call is completed, events will also contain duration and  pricing information.
