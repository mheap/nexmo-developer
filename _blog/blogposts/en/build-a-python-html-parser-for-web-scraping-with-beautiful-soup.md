---
title: "Build a Python HTML Parser for Web Scraping "
description: "Learn how to parse HTML by building a web scraper using Beautiful
  Soup and Python. "
thumbnail: /content/blog/build-a-python-html-parser-for-web-scraping-with-beautiful-soup/python-html_soup_1200x600.png
author: cory-althoff
published: true
published_at: 2021-09-16T12:43:13.925Z
updated_at: 2021-09-08T01:08:28.361Z
category: tutorial
tags:
  - python
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
The internet contains the most extensive collection of data in human history. 

All that data is available to you if you learn how to build a web scraper. A web scraper is a piece of software that collects data from web pages. It is a powerful tool you can use to feed data to your programs. 

For example, you could scrape data from a lyrics website and use it to create a word cloud from the day’s top 10 most popular songs. Or you could analyze headlines and use their sentiment to trade stocks.

In this tutorial, you will learn how to scrape data from the web using Python and Beautiful Soup (a Python library). To follow along, you should have a basic understanding of programming in Python. I do not assume you have experience as a web developer, so I will explain all of the web basics you need to keep up.

 By the end of this tutorial, you will have a functioning web scraper that collects data from a website. Let's get started! 

## How Web Scraping Works

When you visit a website, your web browser sends an HTTP request to the website’s server, asking for the resources your browser needs to display the site. The server might respond with files containing HTML, CSS, JavaScript, and anything else your browser needs to display the site. HTML gives a website its structure, CSS gives it style, and JavaScript makes it interactive.

When you build a web scraper, you write code that sends the HTTP request for you and uses the data to accomplish something without you having to go to the website using your web browser. So a web scraper:

1. Makes a request to a website.
2. Gets the website’s HTML.
3. Searches the HTML for what it needs. 
4. Uses the data to do something.

## Web Scraping Problems

Although web scraping is helpful in many situations, it does have some problems. One problem is web scrapers often break. Web scrapers rely on a website’s HTML staying the same, so when a developer updates a site, it can break your scraper, and you will have to make changes to fix it. 

Web scraping can also be against the terms of service of certain websites, so it is important to read a website's terms of service before scraping data from it. 

If a website allows you to scrape data from it, scraping a website’s data still costs money for the website (because you are consuming its resources), so here are a few things to keep in mind as best practices when you are scraping data: 

1. Don’t scrape data more often than you need to. 
2. Cache data when you can. 

## Web Scraping VS. APIs

Before you build a web scraper, you may want to investigate if the data source you are scraping from has an API. An API is an application programming interface, and it allows two programs to talk to each other. For example, at Vonage, we have an SMS API that allows you to send an SMS message programmatically. We also have a video API that lets you easily add video streaming to your website and a bunch of [other communication APIs](https://www.vonage.com/communications-apis/). 

Many data sources offer APIs that give you access to their information without having to write a web scraper. For example, [IMDB has an API](https://developer.imdb.com/documentation) you can use to get their movie ratings. 

There are several advantages to using IMDB's API instead of scraping the data from their website yourself. 

The first is that you don’t have to worry about violating their terms of service. It is also much faster to get data from an API than to scrape it. Finally, a team of developers manages the IMDB API, so you don’t have to worry about it breaking as a web scraper could.

## What is HTML? 

Before we get any further, here is a quick primer on HTML (if you are already familiar with web development, feel free to skip this section). HTML stands for hyper-text markup language and is a markup language that gives websites their structure. Take a look at this website:

![Example.com](/content/blog/build-a-python-html-parser-for-web-scraping-with-beautiful-soup/example.com.png)

The website has “Example Domain” at the top as a header (which means it is in a  large font and bold). Underneath “Example Domain” is a paragraph of text followed by a link. 

Here is the HTML code for this website.

![HTML example](/content/blog/build-a-python-html-parser-for-web-scraping-with-beautiful-soup/html.png)

As you can see, HTML consists of tags. The tags tell your web browser to do something. In this case, the HTML tells your web browser to create a webpage that says "Example.com" at the top. 

Inside a body tag comes a paragraph of text and a link. If you look at the HTML, you will see "Example.com" is surrounded by `<h1>` and `</h1>`. Many HTML tags, like this one, have an opening tag and a closing tag. In this case, your browser treats everything in between the tags as a header. 

Anything inside of `<p>` tags is a paragraph. Finally, an `<a>` tag is a link. In this case, the line of code `"ahref=https://www.iana.org/domains/example"` inside the `<a>` tag  tells your browser to create a link to https://www.iana.org/domains/example. 

All of the HTML in this example is wrapped in `<body>`, `<div>` and, `<html>` tags, which give your browser additional information. 

To see this website live, you can head to [www.example.com](http://www.example.com). 

To see its HTML, you can press Ctrl+U in your browser or Cmd+Option+U on a Mac (Cmd+U if you are using Firefox).

## What is Parsing

In this tutorial, you will learn how to scrape data from the internet and parse it. What does parsing mean, though? Parsing means taking text and turning it into another format that allows you to extract meaningful information.

For example, soon you will take HTML and feed it into Beautiful Soup. Once you've done that, you can look at the data in a variety of different ways. You can get all of the links on the page, the text, or the images. 

Beautiful Soup allows you to "understand" the data by making sense of HTML's different tags. That way, you can quickly get all of the information you need from a website. 

## Downloading a Website's HTML

Alright, it is time to start building our web scraper! To start, we will scrape all the data from [www.example.com](http://www.example.com). 

The first thing we need to do is get example.com's HTML. 

You can get a website's HTML by sending an HTTP request. 

There are different HTTP requests to accomplish various tasks, but we will use a GET request to ask a website's server to send us its resources. 

Python has a built-in library called `requests` that lets you easily send an HTTP request. Here is how to use the `requests` library to send a GET request and print example.com's HTML.

```python
import requests



print(requests.get('https://example.com').content)

>> b'<!doctype html>\n<html>\n<head>\n    <title>Example Domain</title>\n\n...
```

When you run this code, you should see example.com's HTML.

## Parsing HTML with Beautiful Soup

We can now use Python's Beautiful Soup library to parse example.com's HTML. To do this, we are going to import the `BeautifulSoup` library and use it to create a `BeautifulSoup` object like this: 

```python
import requests
from bs4 import BeautifulSoup


page = requests.get("https://example.com")
soup = BeautifulSoup(page.content, "html.parser")
```

The `BeautifulSoup` class accepts the text it is parsing as a parameter and a string letting it know what the text is. In this case, the text represents HTML, so we pass in `"html.parser"`.    

Now you can use your `BeautifulSoup` object’s `find` method to search for different tags in the HTML. The `find` method accepts the name of a tag as a parameter and returns the first tag that matches.    

```python
import requests
from bs4 import BeautifulSoup


page = requests.get("https://example.com")
soup = BeautifulSoup(page.content, "html.parser")
print(soup.find('p'))

>> <p>This domain is for use in illustrative examples in documents...
```

In this case, you searched the HTML for `p` tags, which stands for paragraph, and BeautifulSoup returned everything in `<p>` tags. 

![HTML example](/content/blog/build-a-python-html-parser-for-web-scraping-with-beautiful-soup/html.png)

The part of the example.com website that says “Example Domain” is in an `<h1>` tag. To scrape “Example Domain,” you can pass in `h1` to `find` instead of `p`.

```python
print(soup.find("h1"))

>> <h1>Example Domain</h1>
```

Now, your code should print the website's title. 

The last piece of information on example.com is the link at the end that says “More information…” to grab this final piece of information, you need to search for an `a` tag. 

```python
print(soup.find("a"))

>> <a href="https://www.iana.org/domains/example">More information...</a>
```

Now when you run your code, it should return the link.

## Scrape More Data

Let’s take a look at how to scrape even more data from a website. 

When you use your web browser and have multiple tabs open, each tab has the website's name.

Web developers define a website’s title in a `<title>` tag. You can get a website’s title like this: 

```python
import requests
from bs4 import BeautifulSoup



URL = "https://example.com"
page = requests.get(URL)
soup = BeautifulSoup(page.content, "html.parser")
print (soup.title.get_text())

>> Example Domain
```

When you run this code, Python should print “Example Domain.”

In HTML, you can give a tag an id or a class, which allows you to give it style using CSS. 

You can search for tags by class and id when you are scraping a website. 

To see this in action, let's look at a website Real Python put together: [a fake job board site.](https://realpython.github.io/fake-jobs/) When you go there, you will see the top of the website says "Fake Python." 

When you look at the website's HTML, you will see that this HTML is what creates "Fake Python" in your browser's tab. 

```phtml
<h1 class="title is-1">Fake Python </h1>
```

If you want to scrape this data, first, you must send an HTTP request to download the HTML. Then, you can use Beautiful Soup to look for a tag with the class `"title"`. Here is how to do it: 

```python
import requests
from bs4 import BeautifulSoup

URL = "https://realpython.github.io/fake-jobs/"
page = requests.get(URL)
soup = BeautifulSoup(page.content, "html.parser")
result = soup.find(class_="title")
print(result)

>> <h1 class="title is-1">
        Fake Python
   </h1>
```

All you have to do is pass in the name of the class to `find` with this code: `class_="title"`. 

Up until now, we've been using `soup.find` to search our HTML, which returns the first result it finds. Beautiful Soup also has a method `soup.find_all` that returns every match. For example, you could use it to get all of the job titles on the Fake Python site. Here is how:

```python
import requests
from bs4 import BeautifulSoup

URL = "https://realpython.github.io/fake-jobs/"
page = requests.get(URL)
soup = BeautifulSoup(page.content, "html.parser")
result = soup.find_all(class_="is-5")
for html in result:
    print(html)
    
>> <h2 class="title is-5">Senior Python Developer</h2>
<h2 class="title is-5">Energy engineer</h2>
<h2 class="title is-5">Legal executive</h2>...
```

First, you need to use your browser to look at Fake Python's HTML. You discover all of the job titles have the class `"is-5"`. Then, all you have to do is search for any HTML that has that class using `find_all`, iterate through the results, and print them. 

## Regular Expressions

If you want to get fancier with your web scraping, you can use regular expressions. A regular expression is a sequence of characters that define a search pattern. 

Python has a built-in library called `re` you can use to define them. For example, you can define a regular expression that searches for numbers in a string. Here is how to use re to search for numbers in a string.

```python
import re


print(re.findall('\d+', 'hello 1 hello 2 hello 3'))

>> \[‘1’, ‘2’, ‘3’]
```

The `re` module's `findall` method accepts two parameters: the string to search and a regular expression.  The regular expression in this example is `'\d+'`.

As you can see, this regular expression returned all of the numbers in the string `'hello 1 hello 2 hello 3'`. 

Regular expressions are flexible: you can write regular expressions to match everything from broad patterns to specific ones. For example, here is how to match a regular expression that only matches strings that start with "The" and end with "brown." 

```python
import re


print(re.findall('^The.*brown$', 'The fox is brown'))

>> ['The fox is brown']
```

Python prints the string because it starts with "The" and ends with "brown."

 In this case, the regular expression is `'^The.*brown$'`. The caret at the beginning followed by "The" means match "The" at the start of a string.

 The .`*` means match anything. Next is `brown$`, which means the string must end with brown.  

If you change the string to end with "green," Python does not find a match because it does not fit the pattern you defined: 

```python
import re


print(re.findall('^The.*brown$', 'The fox is green'))

>> []
```

You can use regular expressions when you are scraping data from websites. Here is how: 

```python
import re
import requests
from bs4 import BeautifulSoup


page = requests.get("https://example.com")
soup = BeautifulSoup(page.content, "html.parser")
result = soup.find_all(re.compile("(head|div)"))
print(result)

>> [<head>
<title>Example Domain</title>...
```

In this code, you pass `soup.find_all` the regular expression `"(head|div)"`. This regular expression matches anything either in a `<head>` tag or a `<div>` tag. When you define a regular expression, the pip symbol means "or." 

## Final Thoughts

Congratulations! You know how to scrape a website! All of the public data from the web is now at your fingertips. 

As we discussed earlier, web scraping does have some problems, so before you commit to scraping data, it is best to see if the data source provides an API first. If they do not have one, and their terms of service allow it, you can now scrape any data you need. 

Of course, there is more to web scraping than the basics I covered in this tutorial. If you want to learn more about web scraping, you can try a free Coursera course like [Using Python to Access Web Data](https://www.coursera.org/learn/python-network-data). 

You can also read through [BeautifulSoup’s documentation.](https://www.crummy.com/software/BeautifulSoup/bs4/doc/) You can [learn more about regular expressions here](https://medium.com/factory-mind/regex-tutorial-a-simple-cheatsheet-by-examples-649dc1c3f285). 

Finally, you might want to [check out Scrapy](https://docs.scrapy.org/en/latest/), a popular Python framework for web scraping.\
\
Thanks for reading, and best of luck with your web scraping!