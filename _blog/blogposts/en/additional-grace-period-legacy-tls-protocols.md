---
title: Additional Grace Period for Legacy TLS Protocols
description: Nexmo Announces Additional Grace Period for Legacy TLS Protocols in
  order to mitigate adverse impact to your business and assist with your
  transition.
thumbnail: /content/blog/additional-grace-period-legacy-tls-protocols/TLS-Deprecation_1200x675.png
author: oliver-schlieben
published: true
published_at: 2018-08-09T16:03:36.000Z
updated_at: 2021-05-04T13:42:51.655Z
category: announcement
tags:
  - http
  - security
  - tls
comments: true
redirect: ""
canonical: ""
---
On the 7th of August 2018 at 09:40 UTC, Nexmo disabled support of legacy TLSv1 and TLSv1.1 protocols. At 15:25 UTC we have temporarily restored support for TLSv1 and TLSv1.1 for a period of two weeks in order to mitigate adverse impact to your business and assist with your transition.

**On 21st of August at 09:00 UTC the grace period ends**

All API requests and all web requests to the [Nexmo Dashboard](https://dashboard.nexmo.com/sign-in) using legacy TLS protocols will be rejected after the 21st of August.

The only supported encryption protocol for HTTPS connections will be TLSv1.2\. 

Three-stage legacy TLS deprecation process:

1. **July 10, 10:00 - 11:23 BST**: TLSv1 and TLSv1.1 were temporarily disabled to facilitate detection of legacy API clients. 
2. **August 7, 09:40 - 16:25 BST**: 2nd shutdown of legacy TLSv1 and TLSv1.1 (suspended the deadline by 2 weeks). 
3. **August 21, 10:00 BST** - permanent shutdown of TLSv1 and TLSv1.1

## Verifying TLSv1.2 Support 
Nexmo rejects plain HTTP requests, but for HTTPS connections we currently accept all TLS versions. Deprecation of TLSv1 and TLSv1.1 will affect only a small proportion of traffic (94% are already TLSv1.2), and many clients will automatically switch to using TLSv1.2. 

In order to see if your system supports TLSv1.2, please refer to the guide below. 

## Web browsers 
To check if your web browser supports TLSv1.2 for communication with the [Nexmo Dashboard](https://dashboard.nexmo.com/sign-in), you can use these online tools: 
* [SSL/TLS Capabilities of Your Browser](https://www.ssllabs.com/ssltest/viewMyClient.html) 
* [User Agent Capabilities list](https://www.ssllabs.com/ssltest/clients.html) 

Updating to the most recent browser version will generally solve any problems. 

## API clients 
There is a variety of available client software and underlying platforms. If your production system communicates with Nexmo using TLSv1 or TLSv1.1, you need to check one of the following components: 
* the operating system * encryption libraries 
* the runtime environment 
* the SDK Generally, all modern operating systems and runtime environments support TLSv1.2, but some use legacy versions by default (e.g. JDK 7). 

To make sure that your system will automatically switch to TLSV1.2 when legacy TLS versions are disabled by Nexmo, please make a GET/POST request to [https://api.nexmo.com/tlsverification](https://api.nexmo.com/tlsverification). 

This verification endpoint accepts only TLSv1.2 connections, responding with 200 OK, and rejects legacy TLS connections with 400 Bad Request. 

All current Nexmo [SDKs and libraries](https://developer.nexmo.com/tools) support TLSv1.2: 
* **nexmo-java**: SDK versions above 3.0 use TLSv1.2 by default. However, you are required to use Java 7 and above. Generally, Java 8 is preferred because it [defaults](https://blogs.oracle.com/java-platform-group/diagnosing-tls,-ssl,-and-https) to using TLSv1.2. 
* **nexmo-ruby**: Ruby 2.0.0 or later and OpenSSL 1.0.1c or later are required.Run the following command with the executable you are using to run your application:

<pre class="top-margin:12 bottom-margin:12 toolbar-overlay:true lang:default decode:true">ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION'</pre>

OpenSSL 1.0.1c and above support TLSv1.2. If your OpenSSL version is below 1.0.1c, we recommend that you upgrade to the latest OpenSSL, and upgrade to a recent release of Ruby. 
* **nexmo-dotnet**: Ensure your system runs .NET framework 4.5 or above. 
* **nexmo-python**: Run the following command with the python executable you are using to run your application:

<pre class="top-margin:12 bottom-margin:12 toolbar-overlay:true lang:default decode:true">python -c "from __future__ import print_function; import ssl; print(ssl.OPENSSL_VERSION)"</pre>

OpenSSL 1.0.1c and above support TLSv1.2. If your OpenSSL version is below 1.0.1c, we recommend that you upgrade to the latest OpenSSL, and upgrade to the latest release of Python 2.7 or 3.4+. 
* **nexmo-php**: Run the following command with the PHP executable you are using to run your application:

<pre class="top-margin:12 bottom-margin:12 toolbar-overlay:true lang:default decode:true">php -r "echo OPENSSL_VERSION_TEXT;"</pre>

OpenSSL 1.0.1c and above support TLSv1.2. If your OpenSSL version is below 1.0.1c, we recommend that you upgrade to the latest OpenSSL and a more recent release of PHP. 
* **nexmo-node & nexmo-CLI**: Run the following command with the node executable you are using to run your application:

<pre class="top-margin:12 bottom-margin:12 toolbar-overlay:true lang:default decode:true crayon-selected">node -p process.versions.openssl</pre>

OpenSSL 1.0.1c and above support TLSv1.2. If your OpenSSL version is below 1.0.1c, we recommend that you upgrade to the latest OpenSSL and to the most recent release of Node (at least 4.9.0 or greater). 

If you need assistance with technical issues please contact us at [support@nexmo.com](mailto:support@nexmo.com).