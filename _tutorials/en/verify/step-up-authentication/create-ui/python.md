---
title: Create the UI
description: Create the user interface for your app
---

# Create the UI

The application will use the [`jinja` template engine](https://jinja.palletsprojects.com/) to render the pages as HTML.

In a folder called `views` in your application directory, create the following templates:

`layout.html`

```html
<!-- layout.html -->

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" type="text/css" href="/static/styles/style.css">
  <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Open+Sans:300">
  <title>Step-up Authentication Example</title>
</head>
<body>
  {% block content %}{% endblock %}
</body>
</html>
```

`index.html`

```html
<!-- index.html -->

{% extends "layout.html" %}

{% block content %}
<h1>{{ brand }} Account Management</h1>

{% if number %}
  <p>You have verified your identity using the phone number {{ number }} and are now permitted to make changes to your account.</p>
  <a href="logout"><input class="ghost-button" type="button" value="Log Out"></a>
{% else %}
  <p>Please verify your account to make changes to your settings.</p>
  <a href="authenticate"><input class="ghost-button" type="button" value="Verify me"></a>
{% endif %}

{% if error %}
  <p class="error-message"><strong>ERROR! {{ error }}</strong></p>
{% endif %}

{% endblock %}
```

`authenticate.html`

```html
<!-- authenticate.html -->

{% extends "layout.html" %}

{% block content %}
<h1>Account Verification: Step 1</h1>
<fieldset>
  <form action="/verify" method="POST">
    <input name="mobile_number" class="ghost-input" type="text" placeholder="Enter your mobile number" required>
    <input class="ghost-button" type="submit" value="Get Verification Code"> 
  </form>
</fieldset>

{% endblock %}
```

`entercode.html`

```html
<!-- errorcode.html -->

{% extends "layout.html" %}

{% block content %}
<h1>Account Verification: Step 2</h1>
<fieldset>
  <form action="/check-code" method="POST">
    <input class="ghost-input" name="code" type="text" placeholder="Enter your verification code" required>
    <input class="ghost-button" type="submit" value="Verify me!">
  </form>
</fieldset>

{% endblock %}
```

Finally, create a file called `style.css` in the `static/styles` directory, which contains the following style sheet:

```css
body {
	width: 800px;
	margin: 0 auto;
	font-family: 'Open Sans', sans-serif;
}
.container {
	width: 600px;
	margin: 0 auto;
}
fieldset {
	display: block;
	-webkit-margin-start: 0px;
	-webkit-margin-end: 0px;
	-webkit-padding-before: 0em;
	-webkit-padding-start: 0em;
	-webkit-padding-end: 0em;
	-webkit-padding-after: 0em;
	border: 0px;
	border-image-source: initial;
	border-image-slice: initial;
	border-image-width: initial;
	border-image-outset: initial;
	border-image-repeat: initial;
	min-width: -webkit-min-content;
	padding: 30px;
}
.ghost-input,
p {
	display: block;
	font-weight: 300;
	width: 100%;
	font-size: 25px;
	border: 0px;
	outline: none;
	width: 100%;
	-webkit-box-sizing: border-box;
	-moz-box-sizing: border-box;
	box-sizing: border-box;
	color: #4b545f;
	background: #fff;
	font-family: Open Sans, Verdana;
	padding: 10px 15px;
	margin: 30px 0px;
	-webkit-transition: all 0.1s ease-in-out;
	-moz-transition: all 0.1s ease-in-out;
	-ms-transition: all 0.1s ease-in-out;
	-o-transition: all 0.1s ease-in-out;
	transition: all 0.1s ease-in-out;
}
.ghost-input:focus {
	border-bottom: 1px solid #ddd;
}
.ghost-button {
	font-size: 15px;
	color: white;
	background-color: blue;
	border: 2px solid #ddd;
	padding: 10px 30px;
	width: 100%;
	min-width: 350px;
	-webkit-transition: all 0.1s ease-in-out;
	-moz-transition: all 0.1s ease-in-out;
	-ms-transition: all 0.1s ease-in-out;
	-o-transition: all 0.1s ease-in-out;
	transition: all 0.1s ease-in-out;
}
.ghost-button:hover {
	border: 2px solid #515151;
}
p {
	color: #e64a19;
}

.error-message {
	color: whitesmoke;
	background-color: firebrick;
	font-size: small;
	font-family: 'Courier New', Courier, monospace;
}
```