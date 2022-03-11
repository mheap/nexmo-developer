---
title: Envie Mensagens de SMS com Node.js | One Dev Minute
description: Este passo a passo rápido mostrará como enviar mensagens de SMS
  utilizando Node.js assim como a API de Mensagens da Vonage
thumbnail: /content/blog/envie-mensagens-de-sms-com-node-js-one-dev-minute/thumbnail-and-assets-for-one-dev-minute-1-.jpg
author: amanda-cavallaro
published: true
published_at: 2022-02-22T12:17:43.824Z
updated_at: 2022-02-28T12:17:43.838Z
category: tutorial
tags:
  - messages-api
  - node
  - portuguese
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Boas vindas ao [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! Esta série está hospedada no [canal de YouTube VonageDev](https://www.youtube.com/vonagedev). O objetivo desta série de vídeos é compartilhar conhecimento de uma maneira breve.

Este passo a passo rápido mostrará como enviar mensagens de SMS utilizando Node.js assim como a API de Mensagens da Vonage.

<youtube id="v-IxH5OwAW8"></youtube>

## Trancrição

Vamos enviar mensagens de SMS usando Node.js com a API de Mensagens da Vonage.
Antes de começarmos, verifique se você:

* Criou uma conta no site da Vonage,
* Instalou Node.js e o Vonage CLI Beta.

No painel da Vonage, clique em "*Settings* (Configurações em inglês)" no menu à esquerda.

Certifique-se de que a API de Mensagens esteja definida como padrão nas configurações de SMS e clique em "*save*" para salvar.

Crie um aplicativo e clique em "*Generate the public and private key*" para gerar a chave pública e privada. Um arquivo será baixado. Vamos usá-lo já já.

Crie uma pasta para o projeto, altere o diretório para dentro dela e abra seu editor de código favorito.

Adicione a chave privada baixada à raiz do projeto.

Instale a dependência da SDK de Servidor da Vonage e crie um arquivo `index.js`.

Inicialize uma nova instância do objeto Vonage. Adicione a ID do aplicativo e a chave privada. Elas podem ser encontradas em seu painel da Vonage.

Declare uma variável contendo o texto que será enviado via SMS e outra variável que conterá o número de telefone para o qual enviaremos uma mensagem de texto. 

É hora de usar a API de Mensagens para enviar um SMS. Usaremos o método `vonage.channel.send` da SDK de Node da Vonage.

Para enviar um SMS, especificaremos como SMS o tipo de destinatário e remetente. 

O primeiro campo irá conter o destinatário e o segundo o remetente. 

Para o conteúdo, especificaremos um tipo de texto e o campo de texto que conterá nossa mensagem de texto.

O callback retorna um erro e o objeto de resposta registrará mensagens sobre o sucesso ou falha da operação.

Você pode executar o código digitando `node index.js` na linha de comando. Você receberá a mensagem de SMS no número de telefone especificado.

Você pode aprender mais nos links abaixo.

## Links

[Leia a versão escrita em inglês do tutorial](https://learn.vonage.com/blog/2019/09/16/how-to-send-and-receive-sms-messages-with-node-js-and-express-dr/) 

[Consulte o código no GitHub](https://github.com/nexmo-community/nexmo-sms-autoresponder-node/) 

[Consulte o código no Glitch](https://glitch.com/edit/#!/whispering-rebel-ixia) 

[Junte-se ao Slack da comunidade de desenvolvedores Vonage](https://developer.vonage.com/community/slack)