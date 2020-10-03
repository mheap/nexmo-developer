---
title: Add a Send SMS View
description: Add a view that renders a Jinja2 template for the web application
---

# Add a Send SMS View

Add a view that renders a `Jinja2` template for the web application. Create this template at `templates/index.html`:

```
@app.route('/')
def index():
    """ A view that renders the Send SMS form. """
    return render_template('index.html')
```

The following HTML includes the Bootstrap CSS framework and then renders a form with two fields: `to_number` for taking the destination phone number and `message`, so the user can enter their SMS message.

```
<h1>Send an SMS</h1>
 
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<div class="container">
    <h1>Send an SMS</h1>
    <form action="/send_sms" method="POST">
        <div class="form-group"><label for="destination">Phone Number</label>
            <input id="to_number" class="form-control" name="to_number" type="tel" placeholder="Phone Number" /></div>
        <div class="form-group"><label for="message">Message</label>
            <textarea id="message" class="form-control" name="message" placeholder="Your message goes here"></textarea></div>
        <button class="btn btn-default" type="submit">Send SMS</button>
    </form>
</div>
```