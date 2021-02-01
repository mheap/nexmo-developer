---
title: Call Flow
description: The various stages of a call and how they interact.
navigation_weight: 1
---

# Call Flow

Any voice interaction starts with a call.

**Inbound** calls are made to the Vonage platform by one of the following methods:

* to a [Vonage number](/numbers/overview) from a regular phone,
* to a [SIP domain](/voice/sip/concepts/programmable-sip) assigned to the application from PBX or any SIP capable software/hardware,
* from a client application using the [Client SDK](/client-sdk/overview).

**Outbound** calls are calls made from the Vonage platform to 

* a regular phone number, 
* a SIP endpoint, 
* client application, or 
* [WebSocket](/voice/voice-api/guides/websockets) server. 

Outbound calls are usually initiated in response to a request made via the REST API to create a new call. Outbound calls may also be made from within the call flow of an existing call (either inbound or outbound) using the `connect` action within the [NCCO](/voice/voice-api/guides/ncco). This scenario is generally used for forwarding calls.

There are two different types of call in terms of call flow:

* ["Scripted" Call](#scripted-call): when the flow is determined by a sequence of question-answer steps (actions);
* [Live Conversation](#live-conversation): which connects two or more participants in a conversation.

See both concepts described below, including [switching](#switching-between-scripted-call-and-live-conversation) seamlessly between on and another.

## Scripted Call
Both inbound and outbound calls initially follow the same call flow once answered. This call flow is controlled by an NCCO. An NCCO is a script of actions to be run within the context of the call. Actions are executed in the order they appear in the script, with the next action starting when the previous action has finished executing. For more information about NCCOs, see the [NCCO Reference](/voice/voice-api/ncco-reference).

when the Vonage API platform receives a call on your Vonage number, it makes an HTTP request to the `answer_url` provided. For inbound calls, the `answer_url` is configured in your [Voice Application](/application/overview). For outbound calls, you provide an `answer_url` in the API request that creates the call.

```sequence_diagram
activate User
User ->> Vonage: inbound call
activate Vonage
Vonage ->> Application: answer URL
activate Application
Application ->> Vonage: NCCO
Vonage ->> User: NCCO action
deactivate Application
deactivate Vonage
deactivate User
```
<br/>
<em style="margin-left: 258px;">Inbound call</em>

<br/>

You may choose to provide your NCCO as part of the request you send to create a call instead of providing an `answer_url`. This is done by providing an NCCO in the `ncco` key of your request.

```sequence_diagram
participant U as User
participant V as Vonage
participant A as Application

activate A
A->>V: POST /calls
note left of A: NCCO

activate V
V->>U: outbound call
activate U
V->>U: NCCO action

deactivate U
deactivate V
deactivate A
```
<br/>
<em style="margin-left: 204px;">Outbound call with embedded NCCO</em>

<br/>


During the call, Vonage is performing callback requests to the application at the `event_url`, set in the application configuration or in the NCCO action, if one is provided in the NCCO. There are two types of callbacks:

* notifications, for example, a call status change;
* instructions request, for example, on an `input` or `notify` callback - for these events Vonage expects the application to provide a new NCCO for processing, which allows implementing different logical call flows.

Successfully established calls pass through the following states:

* `started`
* `ringing`
* `answered`
* `completed`

The Vonage platform sends corresponding event callbacks per each status. You can find more detail in the [Webhooks Reference](/voice/voice-api/webhook-reference).

NCCO and webhooks allow scripting the call as a series of messages and questions to the user, which is applicable to [voice notifications](/use-cases/voice-alerts), [IVR](/use-cases/interactive-voice-response), [voice assistants](/use-cases/asr-use-case-voice-bot) and other scenarios with a predefined list of possible events. With an NCCO, the application may instruct the Vonage platform to play the audio message ([text-to-speech](/voice/voice-api/guides/text-to-speech) or [prerecorded](/voice/voice-api/ncco-reference#stream)) and then expect user input either with [DTMF](/voice/voice-api/guides/dtmf) or [speech](/voice/voice-api/guides/asr). When the user has made a menu selection, your application is notified and is able to direct the call appropriately by supplying new call instructions in the form of an NCCO.

```sequence_diagram
participant U as User
participant V as Vonage
participant A as Application

activate U
U->>V: inbound call

activate V
V->>A: answer URL

activate A
A->>V: NCCO
note left of A: talk\n...\ninput

V->>U: NCCO action 1: talk
V->>U: NCCO action N: input

U->>V: input
V->>A: event URL
A->>A: analyse input

A->>V: NCCO
V->>U: NCCO action

deactivate U
deactivate V
deactivate A
```
<br/>
<em style="margin-left: 268px;">Typical IVR flow</em>

<br/>

## Live Conversation

In some scenarios, for example, a [private voice communication](/use-cases/private-voice-communication) use case, you want to connect two or more participants to establish a live conversation. Each call, inbound or outbound, is automatically added to the new conversation behind the scenes. To connect it to another call with an NCCO, the application can either

* Create a new outbound call with the [`connect`](/voice/voice-api/ncco-reference#connect) action - it will be automatically joined to the same conversation;

* Move the call to an existing (or new) named conversation with the [`conversation`](/voice/voice-api/ncco-reference#conversation) action.

During the conversation, the call is no longer following a sequence of actions, it is now a live interaction between two or more members. To control the call during the conversation, for example, to mute/unmute a member, the application should use the [REST API](/voice/voice-api/api-reference).

```sequence_diagram
participant U1 as User 1
participant V as Vonage
participant A as Application
participant U2 as User 2

activate U1
U1->>V: inbound call

activate V
V->>A: answer URL

activate A
A->>V: NCCO
note left of A: connect

V->>U2: outbound call
activate U2

note over U1, U2: Conversation starts

A->>V: PUT /calls/id
V->>U1: modify call

deactivate U1
deactivate V
deactivate A
deactivate U2
```
<br/>
<em style="margin-left: 350px;">Live conversation flow</em>

<br/>


Using a sequence of `connect` actions, the application may add other members to the conversation (up to 50 total conversation participants).

> Since any type of voice endpoint might be used in the `connect` action, the second member is not necessarily a human: it might be a voice bot talking to the user using the media passed through the [WebSocket](/voice/voice-api/guides/websockets) connection.

## Switching between Scripted Call and Live Conversation
IVR usually has one or more options to speak to a live agent, sales, or support person. Also, in some cases a live conversation may end up with some scripted parts. For example, a customer satisfaction survey. The Voice API allows switching from one form of interaction to another so that the call flow may consist of three (or more in  complex cases) parts:

* Initial IVR, controlled with NCCO and webhooks; ends with `connect` or `conversation` action → 

* Live conversation with a person (or multiparty conference), controlled with REST API; ends with [`PUT /calls/{id}`](/api/voice#updateCall) REST API call with `transfer` action → 

* The survey, controlled with NCCO

```sequence_diagram
participant U as User
participant V as Vonage
participant App as Application
participant A as Agent

activate U
U->>V: inbound call
activate V
V->>App: answer URL
activate App
App->>V: NCCO
note left of App: talk\ninput
V->>U: question
U->>V: answer
V->>App: input callback
App->>V: NCCO
note left of App: conversation
App->>V: POST /calls
note left of App: conversation
V->>A:outbound call
activate A
note over U,A: Conversation
A->>V: hang up
deactivate A
V->>App: completed
App->>V: PUT /calls/id
note left of App: transfer: NCCO\ntalk\ninput
V->>U: question
U->>V: answer
V->>App: input callback
App->>App: save result
App->>V: NCCO
note left of App: talk
deactivate App
V->>U: message
V->>U: end call
deactivate V
deactivate U
```
<br/>
<em style="margin-left: 238px;">Switching from scripted call to live conversation and back</em>

<br/>

The scenario described above is a typical example; however, the application may have any combination of scripted and live parts depending on a certain use-case. See the [Contact Center Augmentation tutorial](/use-cases/contact-center) to learn how to implement the described scenario step by step.
