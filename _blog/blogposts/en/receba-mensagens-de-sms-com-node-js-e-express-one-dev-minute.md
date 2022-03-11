---
title: Receba Mensagens de SMS com Node.js e Express | One Dev Minute
description: Vamos receber mensagens usando Node.js, Express e a API de Mensagens da Vonage.
thumbnail: /content/blog/receba-mensagens-de-sms-com-node-js-e-express-one-dev-minute/thumbnail-and-assets-for-one-dev-minute.jpg
author: amanda-cavallaro
published: true
published_at: 2022-02-24T10:06:55.114Z
updated_at: 2022-03-01T10:06:55.129Z
category: tutorial
tags:
  - node
  - messages-api
  - portuguese
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Boas vindas ao [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! Esta série está hospedada no [canal de YouTube VonageDev](https://www.youtube.com/vonagedev). O objetivo desta série de vídeos é compartilhar conhecimento de uma maneira breve.

Este passo a passo rápido mostrará como receber mensagens de SMS utilizando Node.js, Express assim como a API de Mensagens da Vonage.

<youtube id="EiPB-wIh_zQ"></youtube>

## Trancrição

Vamos receber mensagens usando Node.js, Express e a API de Mensagens da Vonage.

Antes de começarmos, verifique se você:

* criou uma conta na Vonage,
* instalou o Node.js, o ngrok e o Vonage CLI globalmente.

Crie uma pasta, mude o diretório dentro dela, instale o Express, e a SDK de Servidor Beta da Vonage.

Crie um novo arquivo de extensão `.js e abra-o em seu editor de código favorito.

Vamos criar um aplicativo Express que usa os módulos: json e urlencoded. O servidor irá escutar na porta 3000.

Agora vamos criar um manipulador de solicitação POST para o webhook de inbound a ser usado na URL de inbound. E nós registramos o corpo do *request* no *console*. 

Para executar o código, digite `node server.js` em uma aba do terminal, e em outra aba: `ngrok http 3000`. 

No painel da Vonage, clique em "*Settings* (Configurações em inglês)" no menu à esquerda. Certifique-se de que a API de mensagens esteja definida como padrão nas configurações de SMS, e depois clique em "*save*" para salvar. 

Vá para o painel da Vonage e clique para criar um novo aplicativo. Dê um nome, role para baixo até "*Capabilities* (recursos)" e selecione "*Messages* (mensagens)" à direita.

Volte para a guia do seu terminal e copie o URL HTTPS que foi gerado para usarmos no ngrok.

Para o URL de inbound, vamos colar o URL e anexar `/webhooks/inbound`, que é a rota que configuramos em nosso código. 

Role para baixo e clique para gerar um novo aplicativo. Vincule um número de telefone. Se você ainda não tiver um número, você pode comprá-lo no menu à esquerda.

Para ver tudo funcionando, você pode enviar uma mensagem do seu telefone para o seu número de telefone virtual.

Você deve ver uma mensagem sendo registrada na janela da linha de comando.

Aprenda mais nos links que disponibilizo abaixo.

## Links

[Leia a versão escrita em inglês do tutorial](https://learn.vonage.com/blog/2019/09/16/how-to-send-and-receive-sms-messages-with-node-js-and-express-dr/)

[Consulte o código no GitHub](https://github.com/nexmo-community/nexmo-sms-autoresponder-node/)

[Consulte o código no Glitch](https://glitch.com/edit/#!/whispering-rebel-ixia)

[Junte-se ao Slack da comunidade de desenvolvedores Vonage](https://developer.vonage.com/community/slack)