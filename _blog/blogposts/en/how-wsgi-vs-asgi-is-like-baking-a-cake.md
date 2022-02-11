---
title: How Python's WSGI vs. ASGI is Like Baking a Cake
description: If you’re like us and want to understand this Python WSGI vs. ASGI
  business, let’s break it down by using an example of baking a cake.
thumbnail: /content/blog/how-pythons-wsgi-vs-asgi-is-like-baking-a-cake/flask-vs-fastapi_2.png
author: tonya-sims-1
published: true
published_at: 2021-11-19T13:12:18.026Z
updated_at: 2021-11-16T20:13:44.703Z
category: tutorial
tags:
  - wsgi
  - asgi
  - python
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
If you’re like most of us and want to understand this Python WSGI vs. ASGI business, let’s break it down simply by using an example of baking a cake.

But first, what are WSGI and ASGI?

WSGI stands for Web Server Gateway Interface, and ASGI stands for Asynchronous Server Gateway interface. They both specify the interface and sit in between the web server and a Python web application or framework. 

![wsgi vs. asgi interface](/content/blog/how-pythons-wsgi-vs-asgi-is-like-baking-a-cake/wsgi-vs.-asgi.png "wsgi vs. asgi interface")

One of their jobs is to handle incoming requests from the client, but they go about it in different ways.

Let’s look at how WSGI does it then we’ll check out ASGI.

WSGI handles requests synchronously. When requests come in, they are processed sequentially or one after the other. They have to wait until the one before it finishes before switching to a new task. 

![synchronous requests python wsgi vs. asgi](/content/blog/how-pythons-wsgi-vs-asgi-is-like-baking-a-cake/screen-shot-2021-11-16-at-2.10.14-pm.png "synchronous requests python wsgi vs. asgi")

As you can imagine, it could take a long time for the requests to be processed, especially if there are a lot of them, and hinder performance. 

If you’ve ever used Flask, you may have noticed that it uses WSGI. Flask is a popular micro web framework that has been around for some time. It’s lightweight, battle-tested, and gets served up using WSGI.

WSGI has been the Python standard for many years until ASGI came along.

ASGI is the spiritual successor of WSGI. It processes requests asynchronously, in the opposite way of WSGI.

When requests are processed asynchronously, the beauty is that they don’t have to wait for the others before them to finish doing their tasks. The different requests can do their processing finishing in no particular order. 

![asynchronous requests python wsgi vs. asgi](/content/blog/how-pythons-wsgi-vs-asgi-is-like-baking-a-cake/screen-shot-2021-11-16-at-2.10.24-pm.png "asynchronous requests python wsgi vs. asgi")

You may have heard of the new Python web framework, FastAPI. By default, it uses ASGI, which makes it lightning fast. FastAPI is also a micro web framework with many advantages, including out-of-the-box support for asynchronous code using the Python async and await keywords, and much more! It’s also gaining traction super fast and has some of the best documentation out there. 

I promised you a cake baking delight, so let’s start our example.

Let’s say you want to bake a cake and make the frosting, both from scratch.

Since we now know that WSGI will process the requests sequentially, it will carry out the instructions step-by-step, one after the other. 

## Bake a Cake

1. Prepare the baking pans
2. Preheat the oven
3. Grab the flour, baking powder, and salt
4. Stir together the dry ingredients
5. Grab the butter and sugar
6. Combine the butter and sugar
7. Grab the eggs
8. Add the eggs to the ingredients
9. Stir in the eggs
10. Pour the batter into the baking pans
11. Put the pans in the oven

## Make the Frosting

1. Grab a bowl
2. Grab the powdered sugar and butter
3. Mix with a spoon
4. Grab the vanilla extract and milk
5. Stir in the vanilla and milk to the ingredients

Here’s an example of what it would look like in Python pseudocode:

## Request 1

```python
def bake_cake(request):
  
    # task 1
    # task 2
    # task 3

    return response
```

## Request 2

```python
def make_frosting(request):

    # task 1
    # task 2
    # task 3

    return response
```

We’d process Request 1 and wait until that request finishes before moving on to Request 2.

For ASGI, remember that we process requests asynchronously. So requests don’t have to wait on the others before it to finish. Our cake baking and frosting making example would look like this:

## Bake a Cake

1. Prepare the baking pans

2. Preheat the oven

3. Grab the flour, baking powder, and salt

4. Stir together the dry ingredients

## Make the Frosting

5. Grab a bowl

6. Grab the powdered sugar and butter

**Bake a Cake**

7. Grab the butter and sugar

8. Combine the butter and sugar

9. Grab the eggs

10. Add the eggs to the ingredients

11. Stir in the eggs

## Make the Frosting

12. Mix with a spoon

13. Grab the vanilla extract and milk

14. Stir in the vanilla and milk to the ingredients

## Bake a Cake

15. Pour the batter into the baking pans

16. Put the pans in the oven

You see here that the requests are not processed sequentially, and we can switch between tasks. Here’s what that would look like in code:

## Request 1

```python
async def bake_cake(request):

    # task 1
    # task 2
    # task 3 is taking a long time for process Request 2
    # task 4

    return response
```

## Request 2

```python
async def make_frosting(request):

    # task 1
    # task 2
    # task 3 

    return response
```

Hopefully, now you have a better understanding of WSGI vs. ASGI and will be able to choose a Python web framework for your next project based on these interfaces. 

As always, if you have any questions or comments, feel free to [Tweet us at @vonagedev.](https://twitter.com/VonageDev)

We’d love to hear from you!