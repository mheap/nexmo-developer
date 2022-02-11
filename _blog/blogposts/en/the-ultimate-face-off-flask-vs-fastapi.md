---
title: "The Ultimate Face-off: Flask vs. FastAPI"
description: When you need to choose between web frameworks, our face-off
  between FastAPI and Flask helps lead you to victory.
thumbnail: /content/blog/the-ultimate-face-off-flask-vs-fastapi/flask-vs-fastapi_1200x600.png
author: tonya-sims-1
published: true
published_at: 2021-08-10T09:39:27.950Z
updated_at: 2021-07-30T21:31:24.022Z
category: tutorial
tags:
  - python
  - flask
  - fastapi
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Choosing a framework is not easy, and that’s why I’m here to help you get rid of the headache.

Why should we even compare [Flask](https://flask.palletsprojects.com/en/2.0.x/) and [FastAPI](https://fastapi.tiangolo.com/)?

They are similar. Both are stripped-down Python microframeworks without the bloated bells and whistles, which means faster development time and more flexibility. Also, both are used for building APIs and web applications.

They are also different. Flask is more battle-tested, therefore slightly more reliable, and it’s widely used. FastAPI is a newer, more modern framework known for its speed with lots of built-in support like Pydantic and SwaggerUI.

Now that you have a better understanding of each framework, let our faceoff begin!

# Installation

Sometimes the most challenging part of learning something new is actually getting started. That’s why we’ll start with Installation.

It’s relatively straightforward to install both Flask and FastAPI using Python’s favorite installer, pip. It’s also good practice to install both inside a virtual environment, an isolated environment for each of your Python projects that eliminates collision errors.   

#### Flask

```python
$ pip install flask
```

#### FastAPI

```python
$ pip install fastapi uvicorn
```

**Conclusion**: Notice that you install FastAPI with Uvicorn. Think of Uvicorn as a lightning-fast server that allows your applications to perform faster. 

# Hello World Application

If you’ve only written one line of code in your entire life, I bet it was something like this:

`print(“Hello World”)`

It’s kind of like if you were learning another language, let’s say Mandarin. There’s a system called Pinyin, which transcribes Chinese characters to English so people can pronounce them. It’s designed to get you up and running quickly, just like a Hello World application. 

Let’s see what a hello world application looks like in both Flask and FastAPI.

#### Flask < 2.0

```python
# inside of a Python .py file

from flask import Flask

app = Flask(__name__)

@app.route("/", methods=\[“GET”])
def home():
    return {"Hello": "World"}

if __name__ == "__main__":

    app.run()
```

#### Flask 2.0

```python
from flask import Flask

app = Flask(__name__)

@app.get("/")
def home():
    return {"Hello": "World"}

if __name__ == "__main__":

    app.run()
```

#### FastAPI

```python
# inside of a Python .py file

import uvicorn

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"Hello": "World"}

if __name__ == "__main__":

    uvicorn.run("main:app")
```

**Conclusion**: In the newer versions of Flask, you can use the `@app.get()` and `@app.post()` decorators as shortcuts for routing. The previous way of using `@app.route()` required you to pass in your HTTP verbs to a methods list like so: `methods=\[“GET”, “POST”]`.  

> Note: Flask does a `GET` by default, so you don’t need to specify it in the methods list.\
> These methods also come in FastAPI with support for the following decorated routes for each HTTP method:

* `@app.get()`
* `@app.post()`
* `@app.put()`
* `@app.delete()`

# Running in Development

Once you have your "Hello World" app written, you’ll want to run it in development—or locally on your machine— first, before putting it out into production for the whole world to see. If your application doesn’t work as expected, people will definitely freak out. You want to minimize the freakout.

So in your terminal, run these commands:

#### Flask

```python
$ export FLASK_APP=app.py

$ export FLASK_ENV=development

$ flask run
```

#### FastAPI

```python
$ uvicorn main:app --reload
```

**Conclusion**: FastAPI uses Hot Reloading, which keeps the app running while you’re making code changes. Hence, you don’t have to keep restarting the development server. With Flask, you need an extra terminal command: `export FLASK_ENV=development`, which allows you to make code changes without restarting your development server. 

# HTTP Methods

In the Hello World example, we saw what a GET looks like in Flask and FastAPI, so now let’s take a closer look at a POST method.

#### Flask < 2.0

```python
@app.route("/teams", methods=["POST"])
def create_team():
    team = {

        "team_name": "Phoenix Suns",
        "players": [

            {

                  "name": "Chris Paul",
                  "age": 36

            }

        ]

    }

    teams.append(team)
    return (jsonify(teams))
```

#### Flask 2.0

```python
@app.post("/teams")
def create_team():
    team = {

        "team_name": "Phoenix Suns",
        "players": [

            {

                  "name": "Chris Paul",
                  "age": 36

            }

        ]

    }

    teams.append(team)
    return (jsonify(teams))
```

#### FastAPI

```python
@app.post("/teams")
def create_team():
    team = {

        "team_name": "Phoenix Suns",
        "players": [

            {

                  "name": "Chris Paul",
                  "age": 36

            }

        ]

    }

    teams.append(team)
    return {'teams':teams}
```

**Conclusion**: Flask 2.0 and FastAPI look very similar when doing a POST method. The trick is seeing how new data is created.  

With Flask, you’ll have to use a tool like Postman acting as a client, so you can see your POST requests and the data you’ve created in JSON format.\
FastAPI comes with Pydantic and SwaggerUI out of the box, which allows you to use automatic documentation to interact with your requests from the browser, including POST requests.  

Flask can also use automatic documentation, but you’ll have to install it using flask-swagger. There’s also lots of configuration involved to make it work. Let’s look at how to see your POST requests in FastAPI in the next section.

# Automatic Documentation

If you believe in magic, you’ll most definitely love Automatic Documentation.  

FastAPI is based on Pydantic, a framework for easily modeling and validating objects. It comes out of the box, so no need to install it. Pydantic takes the pain of writing constructors away, and you get all the magic methods. Pydantic also does Data validation which displays friendlier errors and uses python type hints, reducing debugging time. To access your automatic documentation, make sure your development server is running,  then go to your localhost and the port on which your application is running:

```
http://127.0.0.1:8000/docs
```

You’ll see your POST request like the example below; if you’re using other HTTP methods, these will be visible as well.

![FastAPI Python automatic documentation POST request using Pydantic](https://lh4.googleusercontent.com/5faKZk_Rcq-dIjGcV6eNgcKRqfa7f5pJ-k2DMH-j0PxhJB_W3TnruP8r9oe30A6h0wyboXC3xNoXMFq-sskbcJ7aDT7rcco0Q4Q4n5b-nlPriI9PpeR4hptDmk5h90kbpSvBhUtI "FastAPI Python automatic documentation POST request using Pydantic")

Let’s do something much cooler so we can see the beauty of automatic documentation. Let’s say we have this code in FastAPI:

#### FastAPI

```python
from pydantic import BaseModel

app = FastAPI()

class Player(BaseModel):
    player_name: str
    player_team: str
    player_age: int

@app.post("/teams")
def create_team(request: Player):
    return {'teams':request}
```

Notice that in order to use Pydantic, you have to import the `BaseModel` that the `Player` class will inherit. We’re also declaring variables as type hints inside our class and returning a dictionary in our POST request.

When you pull up your automatic documentation, you’ll see a Schema. This Schema is a skeleton for your model with variables, where you can see which fields are required and which are optional.

![FastAPI Python automatic documentation with Pydantic POST request and schema](https://lh4.googleusercontent.com/Ge-DOMuMRzEAZOiOLmfrNvBylmunW8j6Tq9AznT42sIJbV3LPnHwS8u7a-vF2KWUe0pF-fqpamLKAxRMhsSsipmAcP-gkyXbMxGv1FYT1fZpiC2LdvXkWSjtgppHbGUWRm55DWV4 "FastAPI Python automatic documentation with Pydantic POST request and schema")

You can also “Try it out” and test your API endpoint by passing in values for the variables. Here, for example, we’re passing in `“Michael Jordan”` for the variable `player_name` of type String.

![FastAPI Python automatic documentation with Pydantic POST request and request body](https://lh6.googleusercontent.com/o5zjizYBoPXJTj9UUPA7dkGWc8VQoa9sisspu0nguEhvITJNl03s9j8iEJ9QYt7b6dbOJ79WgrrgCirXUhOEHKDDMdDY7rHyBxr4ouVvvH0_ooOlOEVfym8yME9SEyxSi7mbDKKR "FastAPI Python automatic documentation with Pydantic POST request and request body")

Then, when you click Execute, it’ll give you the Response Body. There’s no need to use an extra tool like Postman.

![FastAPI Python automatic documentation with Pydantic POST request and response body](https://lh6.googleusercontent.com/khsqTWPxA9jHnQ3hs542QAC37EZ02jtgxRzOkcy-yp-ShsOgSx4rAHk0x61SxTiNsXYECsCWW8EM0JaFYcQVgDrDGWfndZnzp-3P-Ph_Kqsg0pzmNJq6Gglb9H6fFVK-QiL4Ao7S "FastAPI Python automatic documentation with Pydantic POST request and response body")

Your interactive documentation will also generate a curl command for you, so you don’t have to write one from scratch: 

![FastAPI Python automatic documentation with Pydantic POST request and Curl](https://lh5.googleusercontent.com/2AJ3gnhujq1HwdLHHR4LulHOXlSV_sqkKPM8PW5d6hR60ggedoKx19S3Zy0BmgFdcflLXk4rIotZ3aaFgT8MORV0pzVf8TOH6kdOGywan2mYMixkGgb8eS937PiVttBI6qoln9NV "FastAPI Python automatic documentation with Pydantic POST request and Curl")

**Conclusion**: Since Automatic Documentation comes out of the box with FastAPI along with Pydantic and Swagger UI, these features will definitely speed up your development time. You don’t have to install any external tools to test your requests.

# Data Validation

Since our lovely friend Pydantic comes with FastAPI upon installation, it will give you some pretty friendly error messages when you run into problems with your code.

#### FastAPI

```python
from pydantic import BaseModel

from typing import Optional

class Login(BaseModel):
    username: str
    password: str
    agree_to_terms: Optional\[bool]

@app.post("/login")
def login(request: Login):
    if request.username == "janedoe" and   request.password == "password12345":
        return {"message": "Success"}
    return {"message": "Authentication Failed"}
```

Here we’re creating a class Login that inherits from the Pydantic BaseModel with type hinted variables inside of it. We are first checking if the `username` is `janedoe` and the `password` is `passworld12345`, then we return a success or a failure message accordingly. 

We turn to automatic documentation and test our request body by passing in `None` to the username:

![FastAPI Python automatic documentation with Pydantic POST request and change request body](https://lh6.googleusercontent.com/KzV7vaKxI1fVMjzMnPTduBWhE6CXIrEwDQjXtaX7eUOtuPULKMf6DOWpr2CYjFujrspQ9OYI3cXM0nVQ4MC9v5hFQ8990CdoSsWbRdlQsXuPi2odFrhi_X0RG6q7neoyDw4_thy4 "FastAPI Python automatic documentation with Pydantic POST request and change request body")

Pydantic will work its magic, and you’ll get a friendly message telling you exactly what the error is. In this case, it returns the error `Expecting Value`, which is right on the money because we passed in `None` to the `username`.

![FastAPI Python automatic documentation with Pydantic error message](https://lh6.googleusercontent.com/9biK0m7fzVbqdvTtw64PfK6cQRqK-HrQMVbW7gd0-3rDiYz69qD_35JtuUol7qt1ME3MFkJ9SH_fo3rR3R8XETkHhmYTpCuQ2-Vsq1J7ykC4f8Ex_85TNvz2YCWnt1WsmCCxiY53 "FastAPI Python automatic documentation with Pydantic error message")

**Conclusion**: Flask does not have any in-house data validation support. You can use the powerful Pydantic package for data validation by installing it with *Flask-Pydantic*.

# URL or Path Parameters

A path or URL parameter fetches one single item. Let’s say we want to get a single player. Whichever player has an id of what we pass into the URL will be returned to the user. 

Let’s say we have a list of dictionaries, and we want to get one player from this JSON file:

```python
players = [

    {

        "player_id": 1,
        "name": "Giannis"

    },

    {

        "player_id": 2,
        "name": "Luka"

    }

]
```

#### Flask

```python
@app.get('/players/<int:player_id>')

def get_player_details(player_id):
    for player in players:
        if player["player_id"] == player_id:
            return jsonify(player)
```

Here we pass in our route to localhost on port 5000 with an id of 2, and we get back the player with an id of 2.

![Flask Python url or path parameters running on localhost returning JSON as response body](https://lh4.googleusercontent.com/MMQ37ZRuC40c3ZnIvqv9XuN98ji0J0vAGlG4UtFE_JroLK9z1ZBG7vYBuqHCh7QFW7FqD5fsJSdSyMWRtF7kayerX-AG1M38bG3cRTm3KkctJ8EciBwwbcf3IzAucZ6EoY8B1QmE "Flask Python url or path parameters running on localhost returning JSON as response body")

#### FastAPI

```python
@app.get("/player/{player_id}")

def get_player_details(player_id: int):
    for player in players:
        if player['player_id'] == player_id:
            return {'player':player['name']}
```

Here we pass in our route to localhost on port 8000 with an id of 1, and we get back the player with an id of 1.

![FastAPI Python url or path parameters running on localhost returning JSON as response body](https://lh3.googleusercontent.com/sdlIDlSJyDGCQt5Ps8sFfWNpny1uc5BEASoLFdOtOdnks6IqF0NGeEMbuc9NgUAPwUPbcUw2WgEjKPrfIVQO50i-H8PcT4IJSSpPFD_JRcip95bGKds8eD3C0OKusU2LVV0Xe9xA "FastAPI Python url or path parameters running on localhost returning JSON as response body")

**Conclusion**: With FastAPI, since it’s using Python type hinting, you can port your code to other frameworks, like Django. With Flask, it’s not portable because we’re using framework-specific type hinting, not Python hinting.

# Templates Folder

The Templates Folder stores your HTML files when you’re building a web application in Flask or FastAPI, and you have to use Jinja to display your variables in HTML. Jinja is a templating engine that allows you to write code similar to Python to display HTML. 

#### Flask

By default, Flask looks for templates in a "templates" folder. You’ll just need to create one in your file structure. 

![Flask Python templates folder in file structure to render HTML files](https://lh6.googleusercontent.com/5x9KJw2aUIxEn8gglrQ88QEFfOj0HwIGhEHJuYSVsudt8HJKfOf42v1UmFlWfYxIif66pAY1su7Zu0EbMRjU-XmT25Ou-F_05NN6oGf9ac0xVmLxxnvYqt632M65fktbEI-GupPU "Flask Python templates folder in file structure to render HTML files")

![Flask Python templates folder in file structure to render HTML files](https://lh5.googleusercontent.com/IQfD9C2YbAz2rdG6bJVj9N1dLkgAst75jOD2xBGPW9_CKI0bhqTpdGp-j1RPbpd0xKBmLoyP6d2EoHr5tAnPB9Lvn5FJPFsOXTE3ghT9vkg4uB7M8WxbjK7o5xXLTSwwKi_UntP2 "Flask Python templates folder in file structure to render HTML files")

Then you can use Jinja to display your variables by surrounding them with double curly braces:

```html
<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Players</title>

</head>

<body>

    <h1>Display Players</h1>

    {{ player.name }}

    {{ player.jersey_number }}

</body>

</html>
```

**Conclusion**: Jijnja comes with Flask when installed, which is a huge plus. In FastAPI, you have to install Jinja and define the templates folder in your code.

# Production Server

At some point, you’ll want to deploy your application and show it to the world.

#### Flask

Flask uses a web server called WSGI, which stands for Web Server Gateway Interface and has been the Python standard for many years. The drawback is that it’s synchronous. This means that if you have a bunch of requests, they have to wait in line for the queue to complete.

#### FastAPI

FastAPI uses a web server called ASGI or Asynchronous Server Gateway Interface, which is lighting fast because it’s—well, you guessed it—Asynchronous. So, if you have a bunch of requests coming in, they don’t have to wait for the other ones to complete before they are processed. 

**Conclusion**: ASGI makes for faster performance in your web applications because they process requests asynchronously.

Drumroll, please.

The winner is... well, it depends. 

This is how you can choose.

**Use [Flask](https://flask.palletsprojects.com/en/2.0.x/) if you want:**

* A battle-tested framework, as it’s been around for a long time
* To develop a quick prototype
* To do web application development

**Use [FastAPI](https://fastapi.tiangolo.com/) if you want:**

* Speed, as in development time and performance
* To decrease the number of bugs and errors in your code
* To build APIs from scratch

Ok, so you’ve seen both Flask and FastAPI in action. Now you have a better understanding of both, and you've figured out which one would be a better fit for your next project. 

So which framework did you choose? Tweet us [@VonageDev](https://twitter.com/VonageDev) or [@tonyasims](https://twitter.com/TonyaSims).