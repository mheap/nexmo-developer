---
title: Place a call
description: In this step you will place the call.
---

# Place a call

At the top of the `ViewController` class, right below the `client` declaration, add a `NXMCall` property to hold a reference to any call in progress

```swift
class ViewController: UIViewController, NXMClientDelegate {
    ...
    let client = NXMClient.shared
    var call: NXMCall?
    ...
}
```

Based on the object referenced by the `call` property, the `callButtonPressed` method can now be used to either place or end calls; the `placeCall` and `endCall` methods are triggered for each case. 

Replace the current `callButtonPressed` method with the code below:

```swift
@IBAction func callButtonPressed(_ sender: Any) {
    if call == nil {
        placeCall()
    } else {
        endCall()
    }
}

func placeCall() {
    callButton.setTitle("End Call", for: .normal)
    client.serverCall(withCallee: "PHONE_NUMBER", customData: nil) {  [weak self] (error, call) in
        if let error = error {
            self?.connectionStatusLabel.text = error.localizedDescription
            self?.callButton.setTitle("Call", for: .normal)
        }
        self?.call = call
    }
}

func endCall() {
    call?.hangup()
    call = nil
    callButton.setTitle("Call", for: .normal)
}
```

> **NOTE:** Please make sure to replace `PHONE_NUMBER` below with the actual phone number you want to call, in the E.164 format (for example, 447700900000).

> **NOTE:** Also, please make sure that the webhook server you built in the previous steps is still running. 


That's it! You can now build, run and place the call! Magic!


Once the call comes through you can answer it and hear the in-app voice call.


## Webhooks

As you proceed with placing the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO:

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