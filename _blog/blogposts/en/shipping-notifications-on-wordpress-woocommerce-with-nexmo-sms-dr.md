---
title: Shipping Notifications on WordPress WooCommerce Powered by Nexmo SMS
description: Set up a simple integration between WordPress WooCommerce and Nexmo
  SMS to notify the customer (via SMS) when the shipping status of their order
  changes. Learn how to create a WordPress plugin, how WordPress Actions work,
  and how to integrate Nexmo’s API to send SMS on WordPress.
thumbnail: /content/blog/shipping-notifications-on-wordpress-woocommerce-with-nexmo-sms-dr/E_Shipping-Notifications_1200x600.png
author: douglaskendyson
published: true
published_at: 2020-01-11T13:03:13.000Z
updated_at: 2021-04-26T11:47:20.056Z
category: tutorial
tags:
  - php
  - sms-api
  - wordpress
comments: true
spotlight: true
redirect: ""
canonical: ""
---
## Introduction

The customer experience following a purchase plays a huge role in user retention for any business. In eCommerce, the post-purchase experience includes timely notifications when the user’s order status changes. These timely order status notifications keep customers happy, and they reduce the burden of back and forth conversations with customer service.

In this tutorial, we’ll be setting up a simple integration between WordPress WooCommerce and Nexmo SMS to notify the customer (via SMS) when the shipping status of their order changes.

At the end of this tutorial, you’ll have a good understanding of how to create a WordPress plugin, how WordPress Actions work, and how to integrate Nexmo’s API to send SMS on WordPress using Nexmo’s PHP SDK. 

Let’s get started! 

### What You Need to Get Started:

* Self-hosted WordPress website 
* <a href="https://wordpress.org/plugins/woocommerce/">WooCommerce</a> plugin installed

<sign-up></sign-up>

### Outline

Let’s break this project into actionable steps and implement them from top to bottom: 

* Create your WordPress plugin
* Add the Nexmo PHP SDK to the plugin
* Listen for order status changes on WooCommerce 
* Send an SMS when the order status changes

### Creating Your WordPress Plugin

While you can create a WordPress plugin by simply adding a new folder in the WordPress plugins folder, a more efficient way is to get started with a lightweight boilerplate. Boilerplates are helpful to set up all the files and Classes in a standard way. In this tutorial, we’ll be using the <a href="https://wppb.me/">WordPress plugin boilerplate generator (wppb)</a> boilerplate; simply fill in the details on the website, and click the Build Plugin button to download your plugin boilerplate. 

![boilerplate generator](/content/blog/shipping-notifications-on-wordpress-woocommerce-powered-by-nexmo-sms/wordpress1.png "boilerplate generator")

Once you have that, extract the zip file and put it in your WordPress plugins folder.  Next, go to your WordPress admin dashboard, navigate to the installed plugins page and click the Activate button to activate your plugin: 

![WordPress installed plugins page](/content/blog/shipping-notifications-on-wordpress-woocommerce-powered-by-nexmo-sms/worpress2.png "WordPress installed plugins page")

### Adding Nexmo’s PHP Library

Nexmo recommends you install their <a href="https://github.com/Nexmo/nexmo-php">PHP Library</a> via Composer, hence, you’ll need to have Composer setup on your server/local system. If you don’t have Composer set up, here are two guides recommended by Nexmo to help: <a href="https://getcomposer.org/doc/00-intro.md">https://getcomposer.org/doc/00-intro.md</a> or <a href="https://scotch.io/tutorials/a-beginners-guide-to-composer">https://scotch.io/tutorials/a-beginners-guide-to-composer</a> 

With Composer installed, open your terminal, navigate to your plugin’s folder (it’s typically in the path:  `/your-wordpress-server-folder/wp-content/plugins/you-plugin-folder-name/` ) and run: 

```bash
composer require nexmo/client
```

It’ll create a new folder called `vendor` that contains a number of other libraries — Nexmo’s PHP Library included. To include the Library in your plugin, simply add this line to your plugin’s root PHP file:

```php
require_once plugin_dir_path( __FILE__ ) . 'vendor/autoload.php';
```

#### Initializing the Nexmo Class

Before you can make any call with Nexmo’s PHP Library, you need to initialize the Nexmo Class and use the client object to make your subsequent requests: 

```php
$basic  = new \Nexmo\Client\Credentials\Basic(NEXMO_API_KEY, NEXMO_API_SECRET);
$client = new \Nexmo\Client(new \Nexmo\Client\Credentials\Container($basic));
```

Your API Key and Secret can be found on the ‘<a href="https://dashboard.nexmo.com/getting-started-guide">Getting Started</a>’ page on your Nexmo dashboard.

If you’re using the boilerplate, you can make the following edits in the <a href="https://github.com/Kendysond/nexmo-wc-sms-order-status-notification/blob/master/public/class-nexmo-wc-sms-order-status-notification-public.php">public Class file</a> in your plugin’s `/public` folder. We’ll be initializing the Nexmo Library in the construct and setting the client object as a protected property so other methods of our public Class can access it: 

```
class Nexmo_Wc_Sms_Order_Status_Notification_Public {
 
   protected $nexmo_client;
   public function __construct( $plugin_name, $version ) {
 
       $this->plugin_name = $plugin_name;
       $this->version = $version;
 
       $this->nexmo_client = new Nexmo\Client(new Nexmo\Client\Credentials\Basic(WC_SMS_ORDER_NEXMO_KEY, WC_SMS_ORDER_NEXMO_SECRET));
      
   }
```

With that setup, we’ve added Nexmo’s Library to our WordPress plugin, and we can access all of the library-related functions with the class property  `$this->nexmo_client`.  Next, we’ll listen for the WooCommerce order status changes, and we’ll send the SMS notification. 

#### Primer on WordPress Actions

Most of the edits you’ll be making on WordPress have to do with hooking your functions to existing WordPress actions. <strong>Actions</strong> are functions performed when a certain event occurs in WordPress. If you want your function to run when a specific event occurs e.g when an order status changes, you’ll hook your function to the order status change action.

You hook your function to an existing action like this:

```php
add_action( 'action_name', 'name_of_your_function' );
```

### Hooking the WooCommerce Order Status Change

Now that we understand WordPress actions, we’ll be hooking our function that sends the SMS to the WooCommerce order status change event, `woocommerce_order_status_$STATUS_TRANSITION[to]`. `$STATUS_TRANSITION[to]` is whatever status changes you wish to listen to. For example, `'woocommerce_order_status_pending'` triggers our function when the order status changes to pending.

Here’s a code sample to make this clearer—the default statuses on WooCommerce are pending, failed, on-hold, processing, completed, refunded and canceled, and if we wanted to hook a function to each of these statuses, it would look like this:

```php
add_action( 'woocommerce_order_status_pending', 'send_customer_sms_notification');
       add_action( 'woocommerce_order_status_failed', 'send_customer_sms_notification');
       add_action( 'woocommerce_order_status_on-hold', 'send_customer_sms_notification');
       add_action( 'woocommerce_order_status_processing', 'send_customer_sms_notification');
       add_action( 'woocommerce_order_status_completed', 'send_customer_sms_notification');
       add_action( 'woocommerce_order_status_refunded', 'send_customer_sms_notification');
       add_action( 'woocommerce_order_status_cancelled', 'send_customer_sms_notification');
```

To clean up the above code, we’ll refactor to only 3 lines of code: 

```php
class Nexmo_Wc_Sms_Order_Status_Notification_Public {
 
   protected $nexmo_client;
 
  
   public function __construct( $plugin_name, $version ) {
 
       $this->plugin_name = $plugin_name;
       $this->version = $version;
 
       foreach ( array( 'pending', 'failed', 'on-hold', 'processing', 'completed', 'refunded', 'cancelled' ) as $status ) {
           add_action( 'woocommerce_order_status_'. $status, array( $this, 'send_customer_sms_notification' ) );
       }
       $this->nexmo_client = new Nexmo\Client(new Nexmo\Client\Credentials\Basic(WC_SMS_ORDER_NEXMO_KEY, WC_SMS_ORDER_NEXMO_SECRET));
      
   }
```

Next, we’ll create our `send_customer_sms_notification` function that sends the actual SMS via Nexmo SMS.

### Sending the SMS

This part is pretty straight forward: by hooking our function to the WooCommerce order status action, we get the Order ID, which we can use to get details of the order and send the SMS. 

```php
   public function send_customer_sms_notification( $order_id ) {
       $order = wc_get_order( $order_id );
       $order_status = $order->get_status();
       $phone_number   = method_exists( $order, 'get_billing_phone' ) ? $order->get_billing_phone() : $order->billing_phone;
   }
```

From the above, we use the Order ID to get the Order object by calling the WooCommerce function `wc_get_order()`, and with the Order object, we get the status (this is the new status that has just been updated) and the mobile number of the customer. With all of that info, we’re ready to send the SMS. 

We’ll be using the <a href="https://developer.nexmo.com/messaging/sms/overview">snippet</a> from the Nexmo documentation for sending an SMS.However, in our case, the `$client` variable will be the `$nexmo_client` property we set in our constructor earlier: 

```php
public function send_customer_sms_notification( $order_id ) {
       $order = wc_get_order( $order_id );
       $order_status = $order->get_status();
       $phone_number   = method_exists( $order, 'get_billing_phone' ) ? $order->get_billing_phone() : $order->billing_phone;
       $message =  "Your order #".$order_id." status has been updated to ".$order_status;
      
       try {
           $message = $this->nexmo_client->message()->send([
               'to' => $phone_number,
               'from' => WC_SMS_ORDER_NEXMO_SENDER_NAME,
               'text' => $message
           ]);
           $response = $message->getResponseData();
      
           if($response['messages'][0]['status'] == 0) {
               $order_note = "Customer notified on order status change to ".$order_status." via SMS (".$phone_number.")";
           } else {
               $order_note = "Unable to notify customer on order status change via SMS. Error:". $response['messages'][0]['status'];
           }
       } catch (Exception $e) {
           $order_note = "Unable to notify customer on order status change via SMS. Error:". $e->getMessage();
       }
       $order->add_order_note( $order_note );
   }
```

For visibility on the messages sent, we’ll also add an order note to the order with the WooCommerce function  `add_order_note()`. These notes can be seen via the admin: 

![notes in admin](/content/blog/shipping-notifications-on-wordpress-woocommerce-powered-by-nexmo-sms/wordpress3.png "notes in admin")

To test everything, simply place an order on your WooCommerce store, navigate to the admin and change the order status to anything else, and you should get the SMS with the new status. 

![sms demo](/content/blog/shipping-notifications-on-wordpress-woocommerce-powered-by-nexmo-sms/worpress4.png "sms demo")

Here’s a <a href="https://github.com/Kendysond/nexmo-wc-sms-order-status-notification/blob/master/public/class-nexmo-wc-sms-order-status-notification-public.php">link</a> to the full public Class file.

### Conclusion

In this tutorial, we learned the basics of building a WordPress plugin, how to integrate the Nexmo PHP Library, and how to use the Nexmo’s SMS API to send an SMS when a WooCommerce order status changes. 

I hope you found this very helpful—you can check out the full code on GitHub via this <a href="https://github.com/Kendysond/nexmo-wc-sms-order-status-notification/">link</a>. 

Thanks for reading!