---
title: Make a call
description: In this step you learn how to make an app-to-app call.
---

# Make a call

To make a call you will make use of the `callButton` in the `CallViewController` UI. First you need to add a target to the button.

```swift
class CallViewController: UIViewController {
    ...
    override func viewDidLoad() {
        ...
        callButton.addTarget(self, action: #selector(makeCall), for: .touchUpInside)
    }
}
```

When the `callButton` is tapped it will call the `makeCall` function. Add it to the end of the `CallViewController` class.

```swift
class CallViewController: UIViewController {
    ...
    @objc private func makeCall() {
        setStatusLabelText("Calling \(user.callPartnerName)")

        client.call(user.callPartnerName, callHandler: .server) { error, call in
            if error != nil {
                self.setStatusLabelText(error?.localizedDescription)
                return
            }
            call?.setDelegate(self)
            self.setHangUpButtonHidden(false)
            self.call = call
        }
    }
}
```

The `makeCall` function uses the `NXMClient` instance to make the call. The Client SDK supports making calls with the server, your answer URL that provides a `NCCO`, or directly in app. If there is no error the call's delegate is set so that changes to the call can be monitored and the `hangUpButton` is made visible.  


> **NOTE:** Also, please make sure that the webhook server you built in the previous steps is still running. 

Press `Cmd + R` to build and run again. You now have a functioning call app! To test it out you can run the app on two different simulators/devices, and call the device logged in as the Alice user from the device logged in as the Bob user:

![Sent messages](/images/client-sdk/ios-in-app-voice/active-call.png)

## Webhooks

As you proceed with the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO:

```bash
NCCO request:
  - callee: Bob
---
EVENT:
{
  client_ref: 'F906B27D-2119-482F-A876-0E5354D555D3',
  from: null,
  to: 'Bob',
  uuid: '8eaf4a3b-bed7-4316-88f1-fdee8ed34552',
  conversation_uuid: 'CON-a5739d52-35f4-49e1-99c9-68ef9ef2529a',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-26T13:47:14.624Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  client_reference: 'F906B27D-2119-482F-A876-0E5354D555D3',
  rate: null,
  from: null,
  to: 'Bob',
  uuid: '8eaf4a3b-bed7-4316-88f1-fdee8ed34552',
  conversation_uuid: 'CON-a5739d52-35f4-49e1-99c9-68ef9ef2529a',
  status: 'answered',
  direction: 'inbound',
  network: null,
  timestamp: '2021-03-26T13:47:14.624Z'
}
---
EVENT:
{
  from: 'Bob',
  to: 'Alice',
  uuid: '61935d7b-9290-4788-8439-1111ae7c9f24',
  conversation_uuid: 'CON-a5739d52-35f4-49e1-99c9-68ef9ef2529a',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-26T13:47:21.032Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: 'Bob',
  to: 'Alice',
  uuid: '61935d7b-9290-4788-8439-1111ae7c9f24',
  conversation_uuid: 'CON-a5739d52-35f4-49e1-99c9-68ef9ef2529a',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-26T13:47:21.032Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-26T13:47:23.000Z',
  uuid: '61935d7b-9290-4788-8439-1111ae7c9f24',
  network: null,
  duration: '3',
  start_time: '2021-03-26T13:47:20.000Z',
  rate: '0.00',
  price: '0',
  from: 'Bob',
  to: 'Alice',
  conversation_uuid: 'CON-a5739d52-35f4-49e1-99c9-68ef9ef2529a',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-26T13:47:23.709Z'
}
---
EVENT:
{
  headers: {},
  client_reference: 'F906B27D-2119-482F-A876-0E5354D555D3',
  end_time: '2021-03-26T13:47:23.000Z',
  uuid: '8eaf4a3b-bed7-4316-88f1-fdee8ed34552',
  network: null,
  duration: '9',
  start_time: '2021-03-26T13:47:14.000Z',
  rate: '0.00',
  price: '0',
  from: null,
  to: 'Bob',
  conversation_uuid: 'CON-a5739d52-35f4-49e1-99c9-68ef9ef2529a',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-26T13:47:23.762Z'
}
---
```