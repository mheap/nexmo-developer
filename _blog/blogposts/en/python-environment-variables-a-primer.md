---
title: "Python Environment Variables: A Primer"
description: "Everything you need to know about using environment variables with Python. "
thumbnail: /content/blog/python-environment-variables-a-primer/python_environmental-variables_1200x600.png
author: cory-althoff
published: true
published_at: 2021-10-01T10:57:35.676Z
updated_at: 2021-09-29T22:17:02.176Z
category: tutorial
tags:
  - python
  - environment variables
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Python programmers have a lot of secrets. That doesn't mean they have many things they've sworn to keep to themselves (although they might). Instead, they often deal with data they don't want anyone else to see—for example, API keys, API secrets, database names, etc.

One way programmers store these secrets are in environment variables. In this article, you will learn everything you need to know about using environment variables in Python, including how to set them, get them, and the different ways you can keep all of your secrets safe. 

## What Are Environment Variables? 

Environment variables are variables you store outside of your program that can affect how it runs. For example, you can set environment variables that contain the key and secret for an API. Your program might then use those variables when it connects to the API. 

Storing your secrets in your environment instead of your source code has two advantages. 

The first is that it keeps sensitive data safe. For example, you may not want whoever downloads your source code access to an API key you are using. 

The second advantage is that when you use environment variables, you do not have to update your source code when your secrets change.

For example, say your code ran differently based on the operating system the user is running. Instead of changing your source code every time you run the code with a different user, you can automatically update the value using an environment variable.

You often store environment variables in your operating system, but there are other ways to use them you will learn about shortly.  

## Installing Python

To follow along with the examples in this article, you need to have Python installed.

There are two main versions of Python: Python 2 and 3. For this tutorial, make sure you are using Python 3. 

If you haven't already, you can install Python 3 [by following the instructions here.](https://www.python.org/downloads/) 

## Environment Variables in Python

You can get and set environment variables in Python using the built-in `os` module. You can view all of the environment variables in your program by saving the following code in a Python file and then running this Python program: 

```python
import os

os.environ
```

Your Python interpreter should print out all of your operating system's environment variables when running this code. 

You can access the different environment variables in `os.environ` like a Python dictionary. Here are two ways to access them:

```python
import os

os.environ["USER"]
os.environ.get("USER")
```

The last two lines in your Python code above get the "`USER"` environment variable from your operating system, but when you use the first way, Python throws an exception if it does not find the variable. 

You may want to use the first way if the environment variable is required for your Python application to run and the second if it is optional. 

One important environment variable you have access to in `os.environ` is `PYTHONPATH`. 

The URLs in `PYTHONPATH` are where Python looks for modules. 

If you navigate to the URL in your `PYTHONPATH`, you can see this for yourself (you should see all of Python's built-in modules there). 

Adding directories to this environment variable adds them to Python's search path when it is looking for modules.

That means you can add a directory with a module in it anywhere on your computer to `PYTHONPATH`, and Python will be able to find it.   

## Environment Variables in Operating Systems

![Coder working at desk](/content/blog/python-environment-variables-a-primer/coder_at_desk.png)

In the previous example, "`USER"` was an environment variable your operating sets representing who is using your computer. Although your operating system creates this variable automatically, you can also create your own environment variables on your operating system. 

Here is how to create an environment variable on your operating system (using a Unix-like system). First, open up your command line. Then, type the following command:

```python
export vonage_api=your_api
```

The code above creates a variable called `vonage_api` and sets it to `your_api`. 

Now you can print your variable's value like this:

```
echo $vonage_api
```

When you run the code above, your terminal should print `your_api`. 

If you are using Windows, you can [learn how to get and set environment variables here](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html#GUID-DD6F9982-60D5-48F6-8270-A27EC53807D0). 

## Storing Environment Variables in Files

When you create a new environment variable using your terminal, it only exists for that session. When you close your terminal, the environment variable no longer exists.

Often when you are programming, you want your environment variable to persist. One way to accomplish this is to store them in a file: for example, a `.env` file. 

To store environment variables in a `.env` file, you must create a `.env` file in your project directory. 

 First, create a new project.

```
mkdir test_project
```

Then, go into your new directory and create a `.env` file:

Next, create a variable inside your `.env` file like this:

```
vonage_api=your_api
```

Now you need to download Python's `dotenv` library.

First, create and activate a new virtual environment by typing the following in your terminal's command prompt:

```
python3 -m venv env
source env/bin/activate
```

Then, use pip to download `dotenv`:

```
pip3 install python-dotenv
```

Now, you can use Python's `dotenv` library to load your environment variables into `os.environ` like this:

```
from dotenv import load_dotenv
import os

load_dotenv()
print(os.environ["vonage_api"])
```

The line of code `load_dotenv` brings your environment variables into `os.environ`, and you can then use them like you usually would. 

## Storing Environment Variables in the Cloud

![HTML](/content/blog/python-environment-variables-a-primer/html.png)

When you create software for production, you probably won't run it from your computer. 

Instead, you most likely will run your code on a server. 

That means you need to know how to set and get environment variables from wherever you run your code in production. 

Here is a list of cloud providers and where you can get more information about dealing with environment variables using them:

1. [Azure Websites](https://docs.microsoft.com/en-us/azure/app-service/configure-common#application-settings)
2. [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-use-azure-function-app-settings?tabs=portal#application-settings)
3. [AWS](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html)
4. [Docker File](https://docs.docker.com/engine/reference/builder/#/env)
5. [Docker Run](https://docs.docker.com/engine/reference/run/#/env-environment-variables)
6. [Heroku](https://devcenter.heroku.com/articles/config-vars)

## Universal Secrets Managers

Storing your secrets in a `.env` file persists your environment variables but does have some problems.

For example, say you are on a team with ten people. Everyone is tracking their secrets in `.env` files, and one of the secrets changes (say you get a new API key).

In that case, ten people all have to update their `.env` file, which is not very efficient.     

Or, what if you decide to switch from Heroku to AWS? In that case, you will have to learn how to deal with secrets on a new platform, which requires extra work.  

To solve these problems, some programmers use [a universal secrets manager like Doppler.](https://www.doppler.com/) 

A universal secrets manager allows you to store your secrets in one place, so everyone on your team can access them. 

![Doppler's Dashboard](/content/blog/python-environment-variables-a-primer/doppler.png "Doppler's Dashboard")

With a universal secrets manager, your secrets are independent of your local machine or a cloud provider, and so you can bring them with you no matter where you run your code. 

## Final Thoughts 

Setting environment variables is an essential part of creating production software. 

You are now familiar with how to get and set environment variables using Python. 

You also now understand your different options for storing your secrets: temporarily setting them using your OS, storing them in a .env file, keeping them on the cloud, and using a universal secrets manager.

Which method you choose depends on the circumstances of the project you are working on. 

I hope this article helped you better understand how to manage all of your secrets. 

If you have any questions, feel free to [reach out to us on Twitter](https://twitter.com/vonagedev)!