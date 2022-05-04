---
title: O Que São os Objetos de Controle de Chamadas (NCCOs)? | One Dev Minute
description: Aprenda sobre os objetos de controle de chamadas, que são um
  conjunto de ações que instruem o Vonage a controlar a chamada para seu
  aplicativo Vonage
thumbnail: /content/blog/o-que-sao-os-objetos-de-controle-de-chamadas-nccos-one-dev-minute/title.png
author: amanda-cavallaro
published: true
published_at: 2022-05-04T09:01:49.102Z
updated_at: 2022-05-03T09:40:02.172Z
category: tutorial
tags:
  - javascript
  - portuguese
  - voice-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Boas vindas ao [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! Esta série está hospedada no [canal de YouTube VonageDev](https://www.youtube.com/vonagedev). O objetivo desta série de vídeos é compartilhar conhecimento de uma maneira breve.

Neste vídeo, Amanda Cavallaro, nossa Developer Advocate, fala sobre os objetos de controle de chamadas, que são um conjunto de ações que instruem o Vonage a controlar a chamada para seu aplicativo Vonage. Por exemplo, você pode conectar uma chamada, enviar fala sintetizada usando conversa, transmitir áudio ou gravar uma chamada.

<youtube id="Mfw9GP8CoSw"></youtube>

## Transcrição

Olá, eu sou a Amanda Cavallaro, trabalho como developer advocate na Vonage.

Um objeto de controle de chamada, ou um NCCO, é um conjunto de instruções que uma chamada de voz irá seguir.

Um NCCO é composto por uma ou mais ações. A ordem das ações é importante, pois descreve o fluxo da chamada. As opções são usadas para personalizar uma ação. Um objeto de controle de chamada é representado por um array de JSON.

Neste exemplo, podemos ver uma ação de conexão com as opções para fazer uma chamada de um determinado número para um terminal do tipo telefone contendo um número.

Este segundo exemplo é semelhante ao primeiro, mas ele faz uma chamada de um determinado número de telefone para um endpoint do tipo app, conectando-se a um aplicativo cliente, e também envia atualizações da URL do evento.

Você pode unir várias chamadas em uma chamada de conversa em conferência. Neste exemplo, você pode ver uma ação usada pra conversação com um texto descritivo mostrando que está participando de uma conferência. É seguido por uma ação que cria a conversa para a teleconferência.

Também podemos tirar proveito do reconhecimento de fala. Aqui está um trecho de código que mostra como lidar com a entrada de um usuário.

Podemos aceitar Dual Tone Multi Frequency (DTMF), fala ou ambos.

Você pode aprender mais nos links abaixo.

## Links

Mais recursos relacionados ao NCCO:

[Guia NCCO](https://developer.vonage.com/voice/voice-api/guides/ncco)

[Referência NCCO](https://developer.vonage.com/voice/voice-api/ncco-reference)

[Coleção de exemplos de NCCO](https://learn.vonage.com/blog/2019/10/25/introducing-the-ncco-examples-collection-dr/)

[Fluxo de chamadas](https://developer.vonage.com/voice/voice-api/guides/call-flow)

Junte-se à [comunidade de pessoas desenvolvedoras da Vonage no Slack](https://developer.vonage.com/community/slack)
