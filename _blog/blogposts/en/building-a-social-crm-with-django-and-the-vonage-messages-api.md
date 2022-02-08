---
title: Building a Social CRM with Django and the Vonage Messages API
description: Learn how to build a social CRM using Django and the Vonage Messages API
thumbnail: /content/blog/building-a-social-crm-with-django-and-the-vonage-messages-api/social-crm_django.png
author: tolulope-olanrewaju
published: true
published_at: 2022-01-20T09:45:30.668Z
updated_at: 2022-01-04T20:12:13.243Z
category: tutorial
tags:
  - messages-api
  - django
  - CRM
comments: true
spotlight: true
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
In this article, you will learn how to build the core feature of a social CRM using Django and Vonage Messages API. Our social CRM will help sales agents and the customer support team communicate with potential customers directly on Facebook in real-time. Let's call it Sales Fox.

## Pre-requisites

1. Create a messages application from your Vonage dashboard. Follow the steps outlined [here](https://developer.vonage.com/messages/code-snippets/create-an-application#how-to-create-a-messages-and-dispatch-application-using-the-dashboard).
2. Authorise Vonage to access your Facebook business page and link your application to your Facebook page. Follow the steps outlined [here](https://developer.vonage.com/messages/concepts/facebook).
3. Install Redis - If you're using Linux or Mac, follow the instructions [here](https://redis.io/topics/quickstart#installing-redis). If you're using Windows, follow the instructions [here](https://redis.com/blog/redis-on-windows-10/).
4. Install Ngrok.  Go to [Ngrok download page](https://ngrok.com/download) and follow the instructions to set Ngrok up on your computer.

Now that you have the pre-requisites completed. You need to set up your development environment for the tutorial.   

## Project Set-up

1. ### Create and Activate Your Virtual Environment

   Create a directory for your project and change your working directory to the directory you just created. Then, run the following commands to create and activate a virtual environment for your project.

   `python3 -m venv sales-env`

   `source sales-env/bin/activate`
2. ### Install Required Packages

   To install all required packages at once, create a `requirements.txt` file in the directory created in step 1. Copy and paste the code snippet below in your `requirements.txt` file.

   ```
   aioredis==1.3.1
   asgiref==3.3.4
   async-timeout==3.0.1
   attrs==21.2.0
   autobahn==21.3.1
   Automat==20.2.0
   certifi==2021.10.8
   cffi==1.14.6
   channels==2.4.0
   channels-redis==2.4.2
   charset-normalizer==2.0.7
   constantly==15.1.0
   cryptography==3.4.7
   daphne==2.5.0
   Django==3.2.2
   djangorestframework==3.12.4
   hiredis==2.0.0
   hyperlink==21.0.0
   idna==3.2
   incremental==21.3.0
   msgpack==0.6.2
   Pillow==8.2.0
   pyasn1==0.4.8
   pyasn1-modules==0.2.8
   pycparser==2.20
   pyOpenSSL==20.0.1
   python-dotenv==0.19.2
   pytz==2021.1
   requests==2.26.0
   service-identity==21.1.0
   six==1.16.0
   sqlparse==0.4.1
   Twisted==21.7.0
   txaio==21.2.1
   typing-extensions==3.10.0.0
   urllib3==1.26.7
   zope.interface==5.4.0
   ```

   Now, install all the packages in `requirements.txt` by running the command below in your terminal.

   `pip install -r requirements.txt`
3. ### Create your Django project

* Run `django-admin startproject sales_fox` the following to create the Django project named "sales_fox".
* We will create two apps in sales_fox: The `lead_manager` app to manage leads and the `conversation` app for sales agents to communicate with potential customers (known as leads). Now, let's create our two apps by running these commands.

  ```
  python manage.py startapp lead_manager
  python manage.py startapp conversation
  ```

Take note that in this tutorial,

* I'll be using the words - "leads" and "customers" interchangeably. Leads are potential customers, so it won't hurt to regard them as customers where convenient.
* I will use the term `Project Directory` to refer to the directory where you have `settings.py`. This directory was created when you ran `django-admin startproject sales_fox`.
* I will use the term `Overall Directory` to refer to the directory you created at the beginning of the tutorial. It contains your virtual environment folder, the app directories, and your project directory

4. ### Let's get SalesFox ready to use Vonage.

* Create a `.env` file in your overall directory. Define `FACEBOOK_ID`, `VONAGE_API_KEY`, and `VONAGE_API_SECRET`. Your .env file should look like this:

  ```
  FACEBOOK_ID=YOUR-LINKED-FACEBOOK-ID
  VONAGE_API_KEY=YOUR-VONAGE-API-KEY
  VONAGE_API_SECRET=YOUR-VONAGE-API-SECRET
  ```

  You can find your Vonage API key and API secret in your [Vonage settings page](https://dashboard.nexmo.com/settings).
  And your Facebook ID can be found in the `Link social channels` tab on your application page.

  In your project directory, Go to `settings.py`, load the variables in your .env file using `python-dotenv` installed from `requirements.txt`. Add the following snippet in `settings.py` to load the .env file:

  ```
  from  dotenv  import  load_dotenv	
  import  os
  load_dotenv()
  ```

`load_dotenv` loads all variables in our .env file as environment variable.Now, define `FACEBOOK_ID`, `VONAGE_API_KEY`, `VONAGE_API_SECRET`, `VONAGE_MESSAGES_ENDPOINT` in your `settings.py` file. Simply copy and paste the snippet below. 

```
FACEBOOK_ID = os.getenv("FACEBOOK_ID")
VONAGE_API_KEY = os.getenv("VONAGE_API_KEY")
VONAGE_API_SECRET = os.getenv("VONAGE_API_SECRET")
VONAGE_MESSAGES_ENDPOINT = "https://api.nexmo.com/v0.1/messages"
```

5. ### Setup Static Files

In `settings.py`,  find `STATIC_URL` variable and add the `STATICFILES_DIRS` and `STATIC_FILES` beneath `STATIC_URL`, You should have something like:


```
STATIC_URL = '/static/'
STATICFILES_DIRS = [BASE_DIR / 'static']
STATIC_ROOT = BASE_DIR / 'staticfiles'
```

Go to your overall directory and create a folder named `static`. This is where you will keep all your static files. Note that you should only do this for a development environment. In a production environment, you should set up an external store like an AWS S3 bucket to serve your static files.

6. ### Update Installed Apps and define channel layer 

We need to add `channels` and the apps we created (lead_manager and conversation) to `INSTALLED_APPS` in the project's `settings.py`. Your INSTALLED_APPS in settings.py file should look like this:

```
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'channels',
    'lead_manager',
    'conversation',
]
```

Django channels help us include WebSocket support to Sales Fox. A channel layer introduces the use of channels and groups in SalesFox. It helps us build distributed features into our application. You can read more about channel layers [here](https://channels.readthedocs.io/en/stable/topics/channel_layers.html). For this project, I will be using Redis as our channel layer. We have installed `channels-redis` from requirements.txt. Now, let's add `CHANNEL_LAYER`  to `settings.py`. Copy and paste the code snippet below:

```
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            'hosts': [('127.0.0.1', '6379')],
        },
    },
}
```



## The Brass Tacks

Now, let's get to the real deal.

Create models for the `lead_manager` app. Here, we will add models for Lead and Agent. The model `Lead` will represent customers and prospective customers. The model `Agent` will represent SalesFox salespersons who will be in touch with the customers. Copy and paste the following code snippet into `lead_manager/models.py`:

```
from django.db import models
from django.contrib.auth.models import AbstractUser


#Users are staffs or partners that use the CRM
class User(AbstractUser):
    country = models.CharField(max_length=100, blank=True)
    address = models.CharField(max_length=200, blank=True)
    phone_number = models.CharField(max_length=15, blank=True)

  def __str__(self):
      return self.username


class Lead(models.Model):
    LEAD_SOURCES = (
        ('organic_search', 'Organic Search'),
        ('google_ad', 'Google Ad'),
        ('youtube', 'YouTube'),
        ('facebook', 'Facebook'),
        ('instagram', 'Instagram'),
        ('twitter', 'Twitter'),
    )

    MEDIA_CHOICES = (
        ('sms', 'SMS'),
        ('facebook', 'Facebook'),
        ('phone_call', 'Phone call')
    )

    first_name = models.CharField(max_length=25, blank=True)
    last_name = models.CharField(max_length=25, blank=True)
    age = models.IntegerField(default=0)

    facebook_id = models.CharField(max_length=100, blank=True)
    phone_number = models.CharField(max_length=15, blank=True)

    source = models.CharField(
        choices=LEAD_SOURCES, 
        max_length=50,
        blank=True,
        help_text="Where Lead found us",
        default=LEAD_SOURCES[3][0]
    )
    preferred_medium = models.CharField(
        choices=MEDIA_CHOICES, 
        max_length=50,
        default=MEDIA_CHOICES[1][0],
        help_text="Lead's preferred social media for communication"
    )
    active = models.BooleanField(default=False)

    profile_picture = models.ImageField(blank=True, null=True)

    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)

    agent = models.ForeignKey("Agent", on_delete=models.SET_NULL, null=True, blank=True, related_name='leads')

    def __str__(self):
        return self.first_name

    @property
    def has_agent(self):
        return self.agent is not None


class Agent(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='agent')

    def __str__(self):
        return self.user.username
```

We created a User model to represent every user in SalesFox - This could be community managers, region representatives, customer support, etc. However, to keep SalesFox as lean as possible, the only kind of users we have are the agents. 

The `Lead` model represents potential customers reaching out from their Facebook account. The facebook_id field represents the ID of a customer's Facebook account. It is the field we need for agents to send a direct message to customers on Facebook. The `Lead` model also has a preferred_medium field. It holds the customer's preferred means of communication. We will only focus on communicating via Facebook.

```
	
	`AUTH_USER_MODEL = 'lead_manager.User'`


```

Now, let's create a `Message` model in the conversation app. The `Message` model represents a single message sent from/to SalesFox. Copy and Paste the following code snippet into `models.py` of the `conversation` app.

```
from django.db import models
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey

LEAD_MODEL = models.Q(app_label='lead_manager', model='Lead')
AGENT_MODEL = models.Q(app_label='lead_manager', model='Agent')
communicating_parties = LEAD_MODEL | AGENT_MODEL

class Message(models.Model):
    body = models.TextField()

    sender_type = models.ForeignKey(
        ContentType, 
        limit_choices_to=communicating_parties,
        null=True, blank=True, on_delete=models.SET_NULL, related_name="sent_messages"
    ) 
    sender_id = models.PositiveIntegerField(null=True, blank=True, db_index=True)
    sender = GenericForeignKey(ct_field='sender_type', fk_field='sender_id')

    receiver_type = models.ForeignKey(
        ContentType, 
        limit_choices_to=communicating_parties,
        null=True, blank=True, on_delete=models.SET_NULL, related_name="received_messages"
    )
    receiver_id = models.PositiveIntegerField(null=True, blank=True, db_index=True)
    receiver = GenericForeignKey(ct_field='receiver_type', fk_field='receiver_id')

    date_created = models.DateTimeField(auto_now_add=True)
    message_key = models.CharField(null=True, blank=True, max_length=50)
    is_delivered = models.BooleanField(default=False)

    def __str__(self):
        return "Message (%s) from %s to %s" % (self.id, self.sender, self.receiver)
```

In our `Message` model, we have two generic relations to identify the sender and recipient of the message. The sender and receiver can either be a lead or an agent. It means only Agents or Leads can send or receive messages. Visit [here](https://simpleisbetterthancomplex.com/tutorial/2016/10/13/how-to-use-generic-relations.html) to learn more about generic relations in Django.

Create a property method `messages` for the `Lead` model in lead_manager/models.py. This method returns all the incoming and outgoing messages of a lead.

In lead_manager/models.py, paste the following import statements.

Under the `Lead` model, create the property method - "messages" as in the snippet below:

```
from  django.contrib.contenttypes.models  import  ContentType
from  django.db.models  import  Value
from  itertools  import  chain

@property
def messages(self):
  from conversation.models import Message
  message_type = ContentType.objects.get_for_model(self)
  msgFromLead = Message.objects.filter(sender_id=self.id, sender_type=message_type).annotate(
      from_lead=Value(True, models.BooleanField())
  )

  msgToLead =  Message.objects.filter(receiver_id=self.id, receiver_type=message_type).annotate(
      from_lead=Value(False, models.BooleanField())
  )
  messages = sorted(
      chain(msgFromLead, msgToLead), 
      key=lambda instance: instance.date_created
  )

  return messages
```

Let's get started with the views.

In lead_manager, we will create views to perform CRUD operations on the Lead model. Go to the lead_manager app folder, then copy and paste the following code in views.py to create the views:

```
from django.shortcuts import render, redirect
from django.urls import reverse
from django.views.generic import TemplateView, ListView, UpdateView, CreateView
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.exceptions import PermissionDenied
from django.contrib.auth.decorators import login_required
from .models import Lead
from .forms import LeadForm	
    
class HomeView(TemplateView):
    template_name = 'index.html'


class LeadListView(ListView, LoginRequiredMixin):
    template_name = 'lead_manager/lead_list.html'
    queryset = Lead.objects.all()
    context_object_name = 'leads'

    def dispatch(self, request, *args, **kwargs):
        if not (request.user.is_superuser and hasattr(request.user, 'agent')):
            return PermissionDenied
        return super().dispatch(request, *args, **kwargs)


class LeadCreateView(CreateView, LoginRequiredMixin):
    template_name = 'lead_manager/lead_create.html'
    form_class = LeadForm

    def dispatch(self, request, *args, **kwargs):
        if not (request.user.is_superuser and hasattr(request.user, 'agent')):
            return PermissionDenied
        return super().dispatch(request, *args, **kwargs)

    def get_success_url(self):
        return reverse('lead_manager:lead_list')


class LeadUpdateView(UpdateView, LoginRequiredMixin):
    template_name = 'lead_manager/lead_update.html'
    queryset = Lead.objects.all()
    form_class = LeadForm

    def dispatch(self, request, *args, **kwargs):
        if not hasattr(request.user, 'agent'):
            raise PermissionDenied

        return super().dispatch(request, *args, **kwargs)

    def get_success_url(self):
        messages.success(self.request, "{}'s info is successfully updated".format(self.get_object()))
        return reverse('lead_manager:lead_update', args=[self.get_object().id])


@login_required
def lead_delete(request, pk):
    if not request.user.is_superuser:
        return PermissionDenied

    lead = Lead.objects.only('id').get(id=pk)
    lead.delete()

    return redirect('lead_manager:lead_list')

```

In the views above, we override the dispatch method to handle permissions for each view.

Create  `forms.py` inside the lead_manager app directory. In `forms.py`, define `LeadForm`:

```
from django import forms
from .models import Lead

class LeadForm(forms.ModelForm):
    class Meta:
        model = Lead
        fields = [
            'first_name', 
            'last_name', 
            'age',
            'facebook_id',
            'phone_number',
            'source', 
            'preferred_medium', 
            'agent'
        ]
```

Create `views.py` file inside a sub-folder in lead_manager named `agent`. And define your `AgentLoginView` and `AgentDashboardView` views.

```
from django.contrib.auth.views import LoginView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.exceptions import PermissionDenied
from django.views.generic.base import TemplateView

class AgentLoginView(LoginView):
    template_name = 'lead_manager/agent_login.html'


class AgentDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'lead_manager/agent_dashboard.html'

    def dispatch(self, request, *args, **kwargs):
        if not hasattr(request.user, 'agent'):
            raise PermissionDenied

        return super().dispatch(request, *args, **kwargs)

    def get(self, request):
        assigned_leads = request.user.agent.leads.all()
        context = {
            'assigned_leads': assigned_leads,
        }

        return self.render_to_response(context)
```

Let us create `lead_manager/urls.py` and `lead_manager/agent/urls.py`.

Go to the lead_manager directory and create a `urls.py` file. Now, define URL patterns for lead_manager views.

````
from django.urls import path
from . import views

app_name = 'lead_manager'
urlpatterns = [
    path('', views.LeadListView.as_view(), name='lead_list'),
    path('create/', views.LeadCreateView.as_view(), name='lead_create'),
    path('<int:pk>/update/', views.LeadUpdateView.as_view(), name='lead_update'),
    path('<int:pk>/delete/', views.lead_delete, name='lead_delete'),
]
```
In your lead_manager directory, go to `agent` folder and create a file named `urls.py`. Define URL patterns for agent views as in the snippet below:

```
from django.contrib.auth.views import LogoutView
from django.urls import path
from .views import AgentLoginView, AgentDashboardView  

app_name = 'agent'
urlpatterns = [
    path('login/', AgentLoginView.as_view(), name='agent_login'),
    path('logout/', LogoutView.as_view(), name='agent_logout'),
    path('dashboard/', AgentDashboardView.as_view(), name='agent_dashboard'),
]
````

From the two `urls.py` in the lead_manager app, you can confirm that all the views we created in the lead_manager app have corresponding URL configurations.

Now, let's inform Django of the login URL, login redirect URL, and logout redirect URL. Add the following to `settings.py`

```
LOGIN_URL = 'agent:agent_login'
LOGIN_REDIRECT_URL = 'agent:agent_dashboard'
LOGOUT_REDIRECT_URL = 'home'
```

Now, let's move to the conversation app. 

Besides views and URL configuration, you will also set up a web-socket consumer in the conversation app. It will enable communication between SalesFox agents and leads in real-time.

Let's create the `lead_conversation_room` view for the conversation room. Go to `views.py` in the conversation folder and paste the code snippet below	

```
from  django.shortcuts  import  render
from  django.contrib.auth.decorators  import  login_required
from  django.http  import  HttpResponse, HttpResponseForbidden
from django.core.exceptions import PermissionDenied
from lead_manager.models import Lead	
    
@login_required
def lead_conversation_room(request, lead_id):
    if not hasattr(request.user, 'agent'):
        return PermissionDenied

    agent = request.user.agent
    try:
        lead = agent.leads.get(id=lead_id)
    except Lead.DoesNotExist:
        return HttpResponseForbidden()

    context = {"lead": lead}
    return render(request, "conversation/room.html", context)
```

The `lead_conversation_room` view handles requests made by agents to open a conversation room with a customer.

Now, create `send_outbound` function. `send_outbound` function is responsible for sending messages from SalesFox to customers on Facebook Messenger. It takes the message to be sent and the lead facebook ID as arguments.

```
from django.conf  import  settings
import  requests
import  json
import  base64
from  requests.exceptions  import  ConnectionError

def send_outbound(message, lead_facebook_id):
    url = settings.VONAGE_MESSAGES_ENDPOINT

    auth_param = settings.VONAGE_API_KEY + ":" + settings.VONAGE_API_SECRET
    auth_code = base64.b64encode(auth_param.encode('utf-8'))

    payload = json.dumps({
    "from": {
        "type": "messenger",
        "id": settings.FACEBOOK_ID
    },
    "to": {
        "type": "messenger",
        "id": lead_facebook_id
    },
    "message": {
        "content": {
        "type": "text",
        "text": message
        }
    }
    })
    headers = {
    'Authorization': 'Basic %s' % auth_code.decode('utf-8'),
    'Accept': 'application/json',
    'Content-Type': 'application/json'
    }
    try:
        response = requests.request("POST", url, headers=headers, data=payload)
    except ConnectionError:
        return
    return response
```

Because we want real-time communication between leads and agents in the conversation room, we need to create a WebSocket on the client-side and set up a WebSocket consumer on the backend.

Right in the conversation app folder, create a `consumers.py` folder. In the `consumers.py`, create a WebSocket consumer class - `ConversationConsumer`.

```
import json
from channels.generic.websocket import WebsocketConsumer
from asgiref.sync import async_to_sync
from django.contrib.contenttypes.models import ContentType

from .models import Message
from .views import send_outbound
from lead_manager.models import Lead, Agent

def create_conversation_group(convo_id):
    return "conversation_%s" % convo_id

class ConversationConsumer(WebsocketConsumer):
    def connect(self):
        self.lead_id = self.scope['url_route']['kwargs']['lead_id']
        self.conversation = create_conversation_group(self.lead_id)
        self.agent = getattr(self.scope['user'], 'agent', None)
        
        try:
            self.lead = Lead.objects.get(id=self.lead_id)
        except Lead.DoesNotExist:
            self.lead = None

        # join conversation
        async_to_sync(self.channel_layer.group_add)(
            self.conversation,
            self.channel_name
        )

        self.accept()
    
    def disconnect(self, exit_code):
        # leave conversation
        async_to_sync(self.channel_layer.group_discard)(
            self.conversation,
            self.channel_name
        )

    def save_message(self, message_data):
        if self.agent:
            sender_type = ContentType.objects.get_for_model(self.agent)
            message_data['sender_type'] = sender_type
            message_data['sender_id'] = self.agent.id
        
        if self.lead:
            receiver_type = ContentType.objects.get_for_model(self.lead)
            message_data['receiver_type'] = receiver_type
            message_data['receiver_id'] = self.lead.id

        message = Message.objects.create(**message_data)
        return message

    def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']
        saved_message = self.save_message({'body': message})

        if self.lead:
            # send message to Lead on social media (Facebook)
            response = send_outbound(message, self.lead.facebook_id)
            if response and response.ok:
                response_data = response.json()
                saved_message.is_delivered = True
                saved_message.message_key = response_data["message_uuid"]
                saved_message.save()

        # send message to everyone connected to the conversation
        async_to_sync(self.channel_layer.group_send)(
            self.conversation,
            {
                'type': 'send_to_conversation',
                'message': message,
                'from_agent': True
            }
        )
    
    def send_to_conversation(self, event):
        # send message to Websocket
        self.send(
            json.dumps(
                {
                    "message": event['message'],
                    "from_agent": event['from_agent'],
                }
            )
        )
        
```

To explain the methods -
For every agent that opens the conversation page, there is a call to `ConversationConsumer`.  It results in a new channel for the agent.

* `connect()`: is called when a WebSocket connection is received. Here, we add the agent's channel to a conversation and then accept the connection.
* `disconnect()`: Here, we remove the agent's channel from the conversation.
* `receive()`: Here, we receive a new message from the client. After which we call `save_message` which saves the message to our database. We then send the message as a Facebook direct message to the lead by calling `send_outbound`. The message is then sent back to the conversation room. At the end of the `receive` method, the message will be sent to every agent in the conversation room.
* `save_message()`: We save the agent's message to the database here. This is called in `receive`
* `send_to_conversation()`: We use this to broadcast the agent's message to the conversation room so that every agent in the room can see the message.

Now, let's set up routing for our `ConversationConsumer`.

Create `routing.py` in the conversation app directory and paste the following:

```
from  django.urls  import  re_path
from .consumers  import  ConversationConsumer

websocket_urlpatterns = [
re_path(r'ws/conversation/(?P<lead_id>\d+)/$', ConversationConsumer),
]
```

Create a `routing.py` file in your project directory. This file holds the global routing configuration for the project. 

```
from  channels.routing  import  ProtocolTypeRouter, URLRouter
from  channels.auth  import  AuthMiddlewareStack
from  conversation  import  routing

application = ProtocolTypeRouter({
    'websocket': AuthMiddlewareStack(URLRouter(
        routing.websocket_urlpatterns
    )),
})
```

Now, reference `application` in `settings.py`  as ASGI application to be executed when Sales-Fox is served through asynchronous server gateway interface:

```
ASGI_APPLICATION = 'sales_fox.routing.application'
```

Let's create an `inbound` view. The `inbound` view receives a customer's message from Vonage, saves the message, and sends it to agents in the conversation room.

```
from  channels.layers  import  get_channel_layer
from  asgiref.sync  import  async_to_sync
from  django.views.decorators.http  import  require_POST
from  django.views.decorators.csrf  import  csrf_exempt
from  django.contrib.contenttypes.models  import  ContentType
from  lead_manager.models  import  Lead
from .models  import  Message


@require_POST
@csrf_exempt
def inbound(request):
    from .consumers import create_conversation_group
    body = json.loads(request.body)
    channel_layer = get_channel_layer()

    message = body["message"]["content"].get("text")
    lead_facebook_id = body["from"]["id"]
    lead, _ = Lead.objects.get_or_create(facebook_id=lead_facebook_id)
    if message:
        sender_type = ContentType.objects.get_for_model(lead)
        sender_id = lead.id

        message_data = dict(body=message, sender_type=sender_type, sender_id=sender_id)
        agent = lead.agent
        if agent:
            receiver_type = ContentType.objects.get_for_model(agent)
            receiver_id = agent.id

            message_data["receiver_type"] = receiver_type
            message_data["receiver_id"] = receiver_id

        message_obj = Message.objects.create(**message_data)

        conversation_group = create_conversation_group(lead.id)
        try:
            async_to_sync(channel_layer.group_send)(
                conversation_group,
                {
                    "type": "send_to_conversation",
                    "message": message,
                    "from_agent": False, 
                } 
            )

            message_obj.is_delivered = True
            message_obj.save()
        except Exception as e:
            print("Something went wrong")
            print(e)

    with open('inbound.txt', 'w') as inbound_file:
        json.dump(body, inbound_file, sort_keys=True, indent=2)
    return HttpResponse(status=204)

```

Vonage sends message status updates via the status endpoint.

Since we will not be using the status information in this tutorial, let's create a simple status view to write the request body in a `status.txt` file.

In the `views.py` file on the conversation app, copy the following to create the status view.

```
@require_POST
@csrf_exempt
def  status(request):
	body = json.loads(request.body)
	with  open('status.txt', 'w') as  status_file:
		json.dump(body, status_file)
	return  HttpResponse(status=204)

```

Let's create URL configurations for the conversation app. Go to the conversation app directory and create `urls.py` file. Then copy and paste the code snippet below:

```
from django.urls import path
from .views import inbound, status, lead_conversation_room

app_name = 'conversation'
urlpatterns = [
    path('inbound/', inbound, name='conversation-inbound'),
    path('status/', status, name='conversation-status'),
    path('lead/<int:lead_id>/', lead_conversation_room, name="lead-conversation-room"),
]
```

Go to the project directory and find the urls.py file. This file is in the same directory as settings.py. Now, copy and paste the following code:

```
from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static
from django.urls import path, include
from lead_manager.views import HomeView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('leads/', include('lead_manager.urls', namespace='lead_manager')),
    path('agent/', include('lead_manager.agent.urls', namespace='agent')),
    path('conversation/', include('conversation.urls', namespace='conversation')),
    path('', HomeView.as_view(), name="home")
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

```

Now that we're through with the backend of our project. Let's create the frontend files.

Go to your static folder in the overall directory and create a folder named `css`. In `css` folder, create two files `style.css` and `chat.css`.

In `styles.css`, copy and paste the following styles

```
.container {
    margin: 30px;
}

.link-group {
    display: inline-flex; 
    column-gap: 20px;
}

a {
    text-decoration: none;
}

.list {
    margin-bottom: 20px;
}
```

In chat.css, copy and paste the following styles:

```
.container {
    max-width: 500 !important;
    margin: auto;
    margin-top: 4%;
    letter-spacing: 0.5px;
}

.msg-header {
    border: 1px solid #ccc;
    width: 100%;
    height: 10%;
    border-bottom: none;
    display: inline-block;
    background-color: #007bff;
}

.active {
    width: 120px;
    float: left;
    margin-top: 10px;
}

.active h4 {
    font-size: 20px;
    margin-left: 10px;
    color: #fff;
}

.msg-inbox {
    border: 1px solid #ccc;
    overflow: hidden;
    padding-bottom: 20px;
}

.chats {
    padding: 30px 15px 0 25px;

}

.msg-page {
    height: 400px;
    overflow-y: auto;
}

.received-msg {
    display: inline-block;
    padding: 0 0 0 10px;
    vertical-align: top;
    width: 53%;
}

.received-msg p {
    background: #efefef none repeat scroll;
    border-radius: 10px;
    color: #646464;
    font-size: 14px;
    margin: 0;
    padding: 5px 10px 5px 12px;
    width: 100%;
}

.time {
    color: #777;
    display: block;
    font-size: 12px;
    margin: 8px 0 0;
}
.outgoing-msg {
    float: left;
    width: 46%;
    margin-left: 45%;
}

.outgoing-msg p {
    background: #007bff none repeat scroll 0 0;
    color: #fff;
    border-radius: 10px;
    font-size: 14px;
    margin: 0;
    padding: 5px 10px 5px 12px;
    width: 100%;
}

.msg-bottom {
    position: relative;
    width: 100%;
    height: 20%;
    background: #007bff;
    display: inline-block;
}

.input-group {
    float: right;
    margin: 10px 20px 10px 0;
    outline: none !important;
    border-radius: 20px;
    width: 61% !important;
    background-color: #fff;
}

.form-control {
    border: none !important;
    border-radius:  20px !important;
}

.input-group-text {
    background: transparent !important;
    border: none !important;
    color: #007bff;
    cursor: pointer;
}

.input-group-append {
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
}

.input-group .fa {
    color: #007bff;
    float: right;
}

.bottom-icons {
    float: left;
    margin-top: 17ox;
    width: 30px !important;
    margin-left: 22px;
}

.bottom-icons .fa {
    color: #007bff;
    padding: 5px;
}

.form-control:focus {
    border-color: none !important;
    box-shadow: none !important;
}

```

We will use the chat.css file for conversation `room.html` while we use styles.css for other pages. Now, in your overall directory, create a folder named templates and create two HTML files - `base.html` and `index.html`. You will extend `base.html` in every other HTML file except in conversation `room`.html.

In base.html, copy and paste the following

```
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="{% static 'css/style.css' %}">

    <title>{% block title %} Sales Fox {% endblock title %}</title>
</head>
<body>
    <div class="container">
    {% block content %}
    {% endblock content %}
    </div>
</body>
{% block script %}
{% endblock script %}
</html>

```

In index.html (Home page), copy and paste the following

```
{% extends 'base.html' %}
{% load static %}
{% block content %}
```

Now, go to the lead_manager application directory.
Create a folder `templates` and in `templates`, create another folder `lead_manager`. In lead_manager/templates/lead_manager, create five html files - `lead_list.html`, `lead_create.html`, `lead_update.html`, `agent_login.html`, `agent_dashboard.html`.

`lead_list.html`, 

```
 {% extends 'base.html' %}
  {% load static %}

  {% block content %}
      <a href="{% url 'agent:agent_dashboard' %}">Go to dashboard</a>
      <h4>List of leads</h4>
      <ul>
          {% for lead in leads %}
          <li class="list">
              <div class="link-group">
                  <div style="width: 100px;">
                      {{lead.first_name}} ({{lead.id}})
                  </div>
                  <a href="{% url 'lead_manager:lead_update' lead.id %}">Update</a>
                  <a href="{% url 'lead_manager:lead_delete' lead.id %}"> Delete</a>
                  {% if not lead.has_agent %} | <span style="color: red;">Not Assigned</span> {% endif %}
              </div>
          </li>
          {% empty %}
          <p>Lead list is empty</p>
          {% endfor %}
      </ul> 

  <div class="create_lead_link">
      <a href="{% url 'lead_manager:lead_create' %}">Create new lead</a>
  </div>
{% endblock content %}
```

`lead_create.html`, 

```
{% extends 'base.html' %}
{% load static %}

{% block content %}
    <a href="{% url 'lead_manager:lead_list'  %}">Go to lead list</a>
    <h1>Lead Creation Form</h1>

    <form action="." method="POST">
        {% csrf_token %}
        {{ form.as_p }}
        <input type="submit" value="Send">
    </form>
{% endblock content %}
```

`lead_update.html`,

```
{% extends 'base.html' %}
{% load static %}	

{% block content %}
    <a href="{% url 'agent:agent_dashboard' %}">Go to dashboard</a>

    {% if messages %}
    <ul class="messages">
        {% for message in messages %}
        <li{% if message.tags %}>{{ message }}</li>
        {% endfor %}
    </ul>
    {% endif %}

    <form action="." method="POST">
        {% csrf_token %}
        {{ form.as_p }}
        <input type="submit" value="Send">
    </form>
{% endblock content %}
	
```

`agent_login.html`

```
{% extends 'base.html' %}
{% load static %}

{% block content %}
    <h1>Login to your dashboard</h1>

<form action="." method="POST">
    {% csrf_token %}
    {{ form.as_p }}
    <input type="submit" value="Login">
</form>
{% endblock content %}

```

`agent_dashboard.html`

```
{% extends 'base.html' %}
{% load static %}

{% block content %}
    <h4>List of leads assigned to you</h4>

    {% if messages %}
    <ul class="messages">
        {% for message in messages %}
        <li{% if message.tags %} class="message-{{ message.tags }}"{% endif %}>{{ message }}</li>
        {% endfor %}
    </ul>
    {% endif %}

    <div>
        <ul>
            {% for lead in assigned_leads %}
            <li class="list">
                <div class="link-group">
                    <div style="width: 100px;">
                        {{lead.first_name}} ({{lead.id}})
                    </div>
                    <a href="{% url 'lead_manager:lead_update' lead.id %}">Update</a>
                    <a href="{% url 'conversation:lead-conversation-room' lead.id %}">Go to conversation room</a>
                    </div>
            </li>
            {% empty %}
            <p>No assigned lead</p>
            {% endfor %}
        </ul>
    </div>

    <div class="link-group">
        {% if request.user.is_superuser %}    
        <a href="{% url 'lead_manager:lead_list' %}">View lead list</a>
        <a href="{% url 'lead_manager:lead_create' %}">Create new lead</a>    
        {% endif %}
        <a href="{% url 'agent:agent_logout' %}">Logout</a>
    </div>
{% endblock content %}

```

In the conversation app directory, create a folder `templates` and in `templates` folder create a sub-folder `conversation`.

Inside "conversation/templates/conversation" folder, create a `room.html` file. Copy and paste the following:

```
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="{% static 'css/chat.css' %}">
    <title>Conversation with {{lead}}</title>
</head>
<body>
    <div class="container">
        <a href="{% url 'agent:agent_dashboard' %}">Go to Dashboard</a>
        <div class="msg-header">
            <div class="active">
                <h4>{{lead.first_name}} {{lead.last_name}}</h4>
            </div>
        </div>

        <div class="conversation">
            <div class="msg-inbox">
                <div class="chats">
                    <div class="msg-page" id="msgPage">
                        {% for message in lead.messages %}
                        {% if message.from_lead %}
                        
                        <div class="received-msg">
                            <div class="received-msg-inbox">
                                <p>{{message.body}} {{message.from_lead}}</p>
                                <span class="time">{{message.date_created}}</span>
                            </div>
                        </div>
                        
                        {% else %}
                        <div class="outgoing-msg">
                            <p>{{message.body}}</p>
                            <span class="time">{{message.date_created}}</span>
                        </div>
                        {% endif %}
                        {% endfor %}
                    </div>
                </div>
            </div>

            <div class="msg-bottom">
                <div class="input-group">
                    <textarea name="message" id="msgWriter" rows="3" class="form-control"></textarea>
                    <div class="input-group-append">
                        <span class="input-group-text" id="send">Send</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        const selectElement = (e) => document.querySelector(e);

        let messagePage = selectElement("#msgPage");
        let msgWriter = selectElement("#msgWriter");
        const msgType = {agent: 'outgoing', lead: 'received'}
        let socket = null

        const keepScrollToEnd = () => {
            messagePage.scrollTop = messagePage.scrollHeight
        }

        const getMessageBox = (text, date, type=msgType.agent) => {
            const parentDiv = document.createElement('div')
            parentDiv.classList.add(`${type}-chats`)

            const childDiv = document.createElement('div')
            childDiv.classList.add(`${type}-msg`)

            const msgParagraph = document.createElement('p')
            msgParagraph.textContent = text

            const dateSpan = document.createElement('span')
            dateSpan.classList.add('time')
            dateSpan.textContent = date

            childDiv.append(msgParagraph, dateSpan)
            parentDiv.append(childDiv)

            return parentDiv
        }

        // Displays new message in messagePage
        const showNewMessage = (val) => {
            let msgElement
            if (val.from_agent){
                msgElement = getMessageBox(text=val.message, date=val.date, type=msgType.agent)
            } else {
                msgElement = getMessageBox(text=val.message, date=val.date, type=msgType.lead)
            }
            messagePage.append(msgElement);
            keepScrollToEnd()
        }

         
        function sendMessage(event) {
            if (!msgWriter.value) return false;
            if (!socket) {
                alert("No socket connection. Reload browser");
                return false
            }

            socket.send(JSON.stringify({"message": msgWriter.value}));
            msgWriter.value = "";
            event.preventDefault();
            return false
        }

        if (!window["WebSocket"]) {
            alert("Your browser does not support web sockets. Change browser");
        } else {
            var conversationURL = "ws://" + window.location.host + "/ws/conversation/" + "{{ lead.id }}/"
            socket = new WebSocket(conversationURL);
            socket.onclose = function(){
                alert("Web socket connection has been closed");
            }

            // calls showNewMessage if socket receives message
            socket.onmessage = function(msg) {
                showNewMessage(JSON.parse(msg.data));
            }
        }
        selectElement("#send").addEventListener("click", sendMessage, false);
    </script>
</body>
</html
```

Before the closing tag for the body element in room.html, we have a script that handles the WebSocket operation and message rendering in the conversation room.

## Get SalesFox Running

We have now completed the development of SalesFox.

Follow these steps to get SalesFox running locally.

1. Run `redis-server` to start Redis. You can safely stop the Redis server by running `redis-cli shutdown`
2. Create an HTTP tunnel with Ngrok that forwards request to the port from which you're running SalesFox. This provides you with a public available URL for your SalesFox `localhost:port`. Learn more about this [here](https://ngrok.com/docs#getting-started-expose).
3. Go to the .env file in your overall directory. Define a new env variable called HOST set to your Ngrok tunnel URL. 

   ```
   HOST=4339-197-210-53-35.ngrok.io
   ```
4. Add `HOST` from .env file to `ALLOWED_HOST` in `settings.py`. `ALLOWED_HOST` definition in `settings.py` should look like this:

   ```
   ALLOWED_HOSTS = [os.getenv('HOST'), "localhost", "127.0.0.1"]
   ```
5. Recall that we filled in dummy URLs as inbound and status URLs in our Vonage application page. Now, we will replace these URLs with the correct values. Because my tunnel host is `http://4339-197-210-53-35.ngrok.io`, my inbound URL will be `http://4339-197-210-53-35.ngrok.io/conversation/inbound` and my status URL will be `http://4339-197-210-53-35.ngrok.io/conversation/status`.

   Go to your Vonage application page and update the `Inbound URL` and `Status URL` fields.
6. Now, go to your terminal (ensure that you're in the overall directory). Then, run `python manage.py runserver` to serve SalesFox on port 8000.

   `python manage.py runserver 9000`.

## Conclusion

If you got here, Thank you for building this project with me. In the course of building SalesFox, we have stuck to the minimum possible features and design. However, You can do so much more by creating more features upon SalesFox.

You can add more preferred_medium options for leads. Vonage provides varieties of communication APIs, some of which you can develop SalesFox to support. It would be worth checking them out [here](https://www.vonage.com/communications-apis/).

Cheers!