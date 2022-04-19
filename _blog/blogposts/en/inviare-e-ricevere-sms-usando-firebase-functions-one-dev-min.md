---
title: Inviare e ricevere SMS usando Firebase Functions | One Dev Min
description: Questa panoramica ti mostrerà come creare un registro dei messaggi
  SMS ricevuti e come inviare una risposta al mittente utilizzando Firebase
  Cloud Functions e Firebase Real-Time Database insieme alle API Vonage SMS.
thumbnail: /content/blog/send-and-receive-sms-messages-with-firebase-functions-one-dev-minute/one-dev-minute.jpg
author: amanda-cavallaro
published: true
published_at: 2022-04-19T11:03:40.217Z
updated_at: 2022-04-19T11:03:43.379Z
category: tutorial
tags:
  - italian
  - sms-api
  - firebase
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Benvenuti a [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! L'obiettivo di questa serie di video è condividere informazioni in un formato velocemente consumabile. Puoi seguirla sul [canale YouTube di Vonage Dev](https://www.youtube.com/vonagedev).

Questa panoramica ti mostrerà come creare un registro dei messaggi SMS ricevuti e come inviare una risposta al mittente utilizzando Firebase Cloud Functions e Firebase Real-Time Database insieme alla API SMS di Vonage.

<youtube id="BC4MCjtRn3I"></youtube>

## **Trascrizione**

Per inviare messaggi SMS utilizzando Cloud Functions per Firebase dovrai creare un paio di account:

* uno per Firebase
* e uno per l'API Vonage

<sign-up></sign-up>

Crea il progetto nella console Firebase e scegli se utilizzare Analytics opuure no.

Attendi la creazione del tuo progetto.

Seleziona il piano di fatturazione Firebase, in questo caso è il pagamento in base al consumo, "pay as you go".

Nella riga di comando, installa gli strumenti Firebase.

Accedi a Firebase e autenticati. Crea la cartella del progetto e naviga al suo interno.

Inizializza le Cloud Functions per Firebase.

Installa le dipendenze che useremo all'interno della cartella delle funzioni.

Crea un file `.env`e aggiungi lì le variabili d'ambiente per Vonage API.

All'interno del file `index.js`, aggiungi tutte le dipendenze e le variabili di ambiente richieste e inizializza Firebase.

Nello stesso file, crea la prima funzione che fungerà da webhook per acquisire e registrare i messaggi SMS in arrivo su un numero di telefono Vonage.

Crea quindi una funzione per Firebase per inviare l'SMS di risposta e per reagire agli aggiornamenti del database.

Rilascia la funzione e invia un messaggio SMS dal tuo telefono al numero di telefono dell'applicazione Vonage.

Riceverai quindi un messaggio SMS di risposta sul telefono e un aggiornamento al Firebase Real-Time Database.

Puoi trovare il codice completo su GitHub. 

Grazie per la visione e buono sviluppo!

## Links

[Il codice di questo tutorial su GitHub](https://github.com/nexmo-community/firebase-functions-sms-example).

[Trova il tutorial scritto qui](https://developer.vonage.com/blog/2020/01/24/send-and-receive-sms-messages-with-firebase-functions-dr).

[Dai un'occhiata alla documentazione per gli sviluppatori](https://developer.vonage.com/).

[Dettagli sulla funzionalità SMS di Vonage](https://developer.vonage.com/messaging/sms/overview).

[Guida introduttiva alle funzioni Firebase](https://firebase.google.com/docs/functions/get-started).
