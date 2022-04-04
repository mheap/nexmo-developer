---
title: Primeiros Passos com a API de SMS da Vonage
description: Vou te mostrar como mandar uma mensagem de SMS com a API de SMS da
  Vonage em 2 minutos com apenas algumas linhas de código.
thumbnail: /content/blog/primeiros-passos-com-a-api-de-sms-da-vonage/getting-started-sms_yt_thumbnail_2.png
author: amanda-cavallaro
published: true
published_at: 2022-02-17T10:38:47.105Z
updated_at: 2022-03-10T13:19:07.358Z
category: tutorial
tags:
  - sms-api
  - portuguese
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Neste passo a passo rápido, irei te mostrar como enviar mensagens de SMS com a API de SMS Vonage e cURL em apenas 2 minutos.

<youtube id="lx0sHnXPfao"></youtube>

## Transcrição

Olá, eu sou a Amanda Cavallaro, developer advocate na Vonage.

Vou te mostrar como mandar uma mensagem de SMS com a API de SMS da Vonage em 2 minutos com apenas algumas linhas de código.

A mensagem de SMS será enviada para um número que pode ser de um celular que você já possui, ou você também pode provisionar um número de telefone no painel da Vonage instantaneamente.

Você tem a opção de usar um número existente, comprar um novo ou até mesmo portar seus números.

Vou usar um número da Grã-Bretanha que já comprei. Ele se encontra no menu à esquerda em *Numbers* (Números), seguido de *Your numbers* (Seus números).

Vamos usar o cURL para enviar uma mensagem de SMS a partir da linha de comando usando a API de SMS da Vonage. Você precisará de algumas variáveis para tal.

No painel da Vonage, você pode navegar para a página de introdução ao SMS e verá algumas variáveis fornecidas: o número ou marca que enviará a mensagem de SMS, o texto no corpo da mensagem, o número de telefone para o qual estamos enviando a mensagem. E, finalmente, a chave e o segredo da API da Vonage que podem ser encontrados no painel da Vonage.

Se copiarmos e colarmos o trecho de código cURL em nossa linha de comando e pressionarmos enter, a mensagem será enviada imediatamente para o número fornecido.

Você pode pesquisar os logs para ver a mensagem recebida. No lado esquerdo do painel da Vonage, clique em Logs seguidos por SMS Logs.

Você pode filtrar as mensagens de SMS a partir de diversos filtros. No meu exemplo estou filtrando por número de telefone e digitando o número de telefone da Grã Bretanha que comprei. Então podemos ver a mensagem que acabamos de enviar.

Vamos enviar outra mensagem contendo o texto "Testando SMS" e enviá-la da linha de comando.

Se eu navegar até os "Registros de SMS", após atualizarmos a página, podemos ver as informações referentes a mensagem de SMS enviada.

Neste tutorial, você aprendeu como enviar a sua primeira mensagem de SMS com o cURL. Essa não é a sua única opção. Temos várias linguagens de programação incluindo: Node, .NET, Java, PHP, Python e Ruby.

Vá em frente e experimente as nossas APIs!

## Links

[Junte-se ao Slack da comunidade de pessas desenvolvedoras da Vonage](https://developer.vonage.com/community/slack)
