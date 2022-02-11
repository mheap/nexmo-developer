---
title: Sending SMS Templates with Jinja2 and Python
description: Find out how to use templates to send personalised bulk SMS
  messages to multiple recipients in this Python tutorial from Nexmo
thumbnail: /content/blog/sending-sms-templates-python-dr/Sending-SMS-templates-with-Jinja2-and-Python.png
author: aaron
published: true
published_at: 2018-12-17T19:19:26.000Z
updated_at: 2021-05-11T09:26:49.841Z
category: tutorial
tags:
  - python
  - sms-api
comments: true
redirect: ""
canonical: ""
---
Need to send a message to many people at once? Want to personalise it so that it doesn't seem so, well, impersonal? Can't send a group message as you don't want your mum seeing you sent the same heartfelt text to every one of your relations and not just her? We're going to look at how to create an SMS client which supports bulk messages and templates for personalisation.

## Getting Started

You'll need a bit of experience with Python to run the CLI, and at least Python 3.6 as we're going to be using f-strings.

1. [Clone the source from GitHub](https://github.com/nexmo-community/nexmo-sms-brisk)
2. Install the dependencies into your virtual environment; I recommend using [pipenv](https://pipenv.readthedocs.io/en/latest/) and installing the package in editing mode: `pipenv install -e .`
3. Create the following environmental variables; `NEXMO_KEY`, `NEXMO_SECRET`, and `MY_NUMBER` the first two are available from [your Nexmo Dashboard](https://dashboard.nexmo.com/getting-started-guide). `MY_NUMBER` is your mobile number in the international E.164 format.

## Managing SMS Contacts

![Creating a new contact via the CLI](/content/blog/sending-sms-templates-with-jinja2-and-python/screencast-contact-1.gif "Creating a new contact via the CLI")

Our application is going to need [a basic CRM to hold our contacts](https://github.com/nexmo-community/nexmo-sms-brisk/blob/9b4ca9b0ac2c1cdb4d4362462c43830d58dfe6fe/src/brisk/contacts.py). We're going to use tinydb for our persistence layer as we don't need anything too complicated and as a bonus, it stores the data as a JSON file, which makes backups and manual edits of the data straightforward.

As well as the contact's name and telephone number we have a few multiple choice values we collect.

```python
@contact.command("create")
def contact_create():
    """Creates a new contact"""
    questions = [
        {"type": "input", "name": "name", "message": "Contact name"},
        {
            "type": "input",
            "name": "phonenumber",
            "message": "Contact phone number (E.164 international format)",
        },
        {
            "type": "checkbox",
            "qmark": "?",
            "message": "Select diminutives (select at least 1)",
            "name": "diminutive",
            "choices": [
                Separator("= The Bros ="),
                {"name": "Bro"},
                {"name": "Buddy"},
                {"name": "Dude"},
                {"name": "Matey"},
                {"name": "Pal"},
                Separator("= The Sweethearts ="),
                {"name": "Baby"},
                {"name": "Bae"},
                {"name": "Darling"},
                {"name": "Sweetheart"},
                {"name": "Sugar"},
                Separator("= The Scots/Irish/Aussies ="),
                {"name": "████"},
                {"name": "Eejit"},
                {"name": "█████████"},
                {"name": "Numpty"},
            ],
            "validate": lambda answer: "You must choose at least one diminutive."
            if len(answer) == 0
            else True,
        },
        {
            "type": "checkbox",
            "qmark": "?",
            "message": "Select greetings (select at least 1)",
            "name": "greeting",
            "choices": [
                {"name": "Alright"},
                {"name": "Greetings"},
                {"name": "Hello"},
                {"name": "Hey"},
                {"name": "Hi"},
                {"name": "Oi"},
                {"name": "Wasssssup"},
                {"name": "Yo"},
            ],
            "validate": lambda answer: "You must choose at least one greeting."
            if len(answer) == 0
            else True,
        },
        {
            "type": "checkbox",
            "qmark": "?",
            "message": "Select valediction (select at least 1)",
            "name": "valediction",
            "choices": [
                {"name": "Bye"},
                {"name": "Cya"},
                {"name": "Love you x"},
                {"name": "Peace"},
                {"name": "xox"},
            ],
            "validate": lambda answer: "You must choose at least one valediction."
            if len(answer) == 0
            else True,
        },
    ]

    answers = prompt(questions, style=questions_style)
    contacts_db.insert(answers)

    click.secho(
        f"New contact {answers['name']} created", fg="black", bg="cyan", bold=True
    )
```

When we render the template for a message, we'll supply a random value from these lists in the context, give the messages some variation.

## Managing Our SMS Templates

Our templates are going to be rendered using Jinja2 giving us access to all of Jinja's built-in filters and features. We also [supply information about each contact in the context](https://github.com/nexmo-community/nexmo-sms-brisk/blob/9b4ca9b0ac2c1cdb4d4362462c43830d58dfe6fe/src/brisk/sms.py#L56-L62) when rendering the template.

![Creating a new template via the CLI](/content/blog/sending-sms-templates-with-jinja2-and-python/screencast-template.gif "Creating a new template via the CLI")

I've made liberal use of Jinja's `random` filter so that there is some variation in my messages, even if I resend the same person the same message multiple times it should look as if I've taken the time to write it personally each time. For added authenticity, you can randomly add in the odd typo from time-to-time. 

`{{ greeting }} {{ diminutive }} {{ ["gah", "sorry", "I suck", "soz"]|random }}, I'm {{ ["running", "runnin", "runing"]|random }} about {{ range(5,25)|random }} {{ ["mins", "minutes", "mintes"]|random }} late. {{ valediction }}`

![Screenshot of phone with multiple SMS](/content/blog/sending-sms-templates-with-jinja2-and-python/img_fc1da0c0b022-1.png "Screenshot of phone with multiple SMS")

The rest of [our template management code](https://github.com/nexmo-community/nexmo-sms-brisk/blob/9b4ca9b0ac2c1cdb4d4362462c43830d58dfe6fe/src/brisk/templates.py) looks very similar to the contacts, although we do have a crude drill-down/expand so that you can quickly view the template contents.

```python
@template.command("list")
def template_list():
    """View all templates"""
    viewing_templates = True
    all_templates = templates_db.all()

    while viewing_templates:
        questions = [
            {
                "type": "list",
                "message": "View template",
                "name": "template",
                "choices": [
                    {"name": f"{template['name']}", "value": template}
                    for template in all_templates
                ],
            }
        ]

        answers = prompt(questions, style=questions_style)

        click.echo(answers["template"]["name"])
        click.echo("---")
        click.echo(answers["template"]["template"])

        if not click.confirm("View another template?"):
            viewing_templates = False
```

## Sending Multiple SMS with Python

![Sending multiple/bulk SMS via the CLI](/content/blog/sending-sms-templates-with-jinja2-and-python/screencast-send.gif "Sending multiple/bulk SMS via the CLI")

With the [Nexmo Python Client](https://github.com/Nexmo/nexmo-python) sending an SMS is a [single function call](https://github.com/nexmo-community/nexmo-sms-brisk/blob/9b4ca9b0ac2c1cdb4d4362462c43830d58dfe6fe/src/brisk/sms.py#L64-L70); most of our SMS sending code is to allow the user to select which numbers are going to receive the message, and which template we should use.

```python
@click.command()
def send():
    """Send SMS"""

    questions = [
        {
            "type": "checkbox",
            "qmark": "?",
            "message": "Select contacts to message",
            "name": "contacts",
            "choices": [
                {
                    "name": f"{contact['name']} - {contact['phonenumber']}",
                    "value": contact,
                }
                for contact in contacts_db.all()
            ],
            "validate": lambda answer: "You must choose at least one contact."
            if len(answer) == 0
            else True,
        },
        {
            "type": "list",
            "message": "Select template",
            "name": "template",
            "choices": [
                {"name": f"{template['name']}", "value": template["template"]}
                for template in templates_db.all()
            ],
        },
    ]

    answers = prompt(questions, style=questions_style)
    template = Template(answers["template"])

    with click.progressbar(answers["contacts"], label="Sending messages") as contacts:
        for contact in contacts:
            message = template.render(
                name=contact["name"],
                phonenumber=contact["phonenumber"],
                diminutive=random.choice(contact["diminutive"]),
                greeting=random.choice(contact["greeting"]),
                valediction=random.choice(contact["valediction"]),
            )

            nexmo_client.send_message(
                {
                    "from": os.environ["MY_NUMBER"],
                    "to": contact["phonenumber"],
                    "text": message,
                }
            )
```

I modified the code above to log the results of my Christmas message so you can see the sort of variation it produces across different contacts.

![Multiple messages output from bulk SMS CLI in Python](/content/blog/sending-sms-templates-with-jinja2-and-python/screenshot-2018-12-17-19.53.22.png "Multiple messages output from bulk SMS CLI in Python")