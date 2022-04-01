---
title: Cosa Sono Gli Oggetti di Controllo delle Chiamate (NCCO) | One Dev Min
description: Benvenuti a One Dev Minute! L'obiettivo di questa serie di video è
  condividere informazioni in un formato velocemente consumabile.
thumbnail: /content/blog/cosa-sono-gli-oggetti-di-controllo-delle-chiamate-ncco-one-dev-min/ncco.png
author: amanda-cavallaro
published: true
published_at: 2022-03-21T11:36:14.697Z
updated_at: 2022-03-21T11:36:14.714Z
category: tutorial
tags:
  - voice-api
  - javascript
  - italian
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Benvenuti a [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! L'obiettivo di questa serie di video è condividere informazioni in un formato velocemente consumabile. Puoi seguirla sul [canale YouTube di Vonage Dev](https://www.youtube.com/vonagedev).

In questo video, Amanda Cavallaro, la nostra Developer Advocate, vi parlerà dei Call Control Objects, che sono un insieme di azioni che istruiscono la piattaforma di Vonage su come controllare una chiamata alla tua applicazione Vonage. Ad esempio, puoi connettere una chiamata, inviare un messaggio sintetizzato, audio in streaming o registrare una chiamata.

<youtube id="XjTC8m52FZo"></youtube>

## Trascrizione

Un Call Control Object, o NCCO, è un insieme di istruzioni che controllerà una chiamata vocale.

Un NCCO è composto da una o più azioni. Il loro ordine è importante, poiché descrive il flusso della chiamata. Le opzioni vengono utilizzate per personalizzare un'azione. Un Call Control Object è rappresentato da un array JSON.

In questo esempio, possiamo vedere un'azione di connessione con le opzioni per effettuare una chiamata da un determinato numero a un endpoint di tipo telefono con un numero.

Questo secondo esempio è simile al primo, ma effettua una chiamata da un determinato numero di telefono a un endpoint di tipo app, connettendosi ad una client app, e inviando in aggiunta aggiornamenti dall'URL dell'evento.

È possibile unire più chiamate in una singola conferenza audio. In questo esempio, puoi vedere un’azione di tipo discorso con un testo descrittivo che mostra il tuo ingresso alla conferenza. È seguita da un'azione che crea la conversazione per la teleconferenza.

Possiamo anche sfruttare il riconoscimento vocale. Ecco un frammento di codice che mostra come gestire l'input di un utente.

Possiamo accettare Dual Tone Multi Frequency (DTMF), parlato o entrambi.

Puoi ottenere maggiori informazioni accedendo ai link qui in basso.

## Links

Altre risorse relative a NCCO:

[Guida NCCO](https://developer.vonage.com/voice/voice-api/guides/ncco)

[Riferimento NCCO](https://developer.vonage.com/voice/voice-api/ncco-reference)

[Raccolta di esempi NCCO](https://learn.vonage.com/blog/2019/10/25/introducing-the-ncco-examples-collection-dr/)

[Flusso di chiamata](https://developer.vonage.com/voice/voice-api/guides/call-flow)

Unisciti alla [community di sviluppatori Vonage Slack](https://developer.nexmo.com/community/slack)
