---
title: Adding 2-Factor Authentication to WordPress with Nexmo Verify API
description: "Learn the basics of building a WordPress plugin and have a good
  understanding of how to integrating the Nexmo API with WordPress using the
  Nexmo PHP Library. "
thumbnail: /content/blog/adding-2-factor-authentication-to-wordpress-with-nexmo-verify-api-dr/E_2FA-WordPress_1200x600.jpg
author: douglaskendyson
published: true
published_at: 2019-10-09T21:06:04.000Z
updated_at: 2021-05-13T12:12:02.708Z
category: tutorial
tags:
  - verify-api
  - wordpress
comments: true
spotlight: true
redirect: ""
canonical: ""
---
## Introduction

With security breaches on the rise, protecting your website and its users has never been as dire as it is today. In this tutorial, you will set up 2FA (two-factor authentication) on WordPress using the Nexmo Verify API. With this setup, whenever a user tries to log in, they’ll get an SMS or call on the mobile number registered to their profile with a unique code, and upon entering the valid code will they be logged in.

At the end of this tutorial, you'll have learned the basics of building a WordPress plugin and have a good understanding of how to integrating the Nexmo API with WordPress using the Nexmo PHP Library. So let’s get started! 

### About the Nexmo Verify API

The Verify API is Nexmo’s plug and play solution for two-factor authentication on any system. The process is simple; you’d call the [Send Verification](https://developer.nexmo.com/verify/code-snippets/send-verify-request/php) endpoint passing a mobile number, Nexmo will send the mobile number a unique code via SMS/call and return a request ID. With the user’s code, you’d call the [Check Verification](https://developer.nexmo.com/verify/code-snippets/check-verify-request) endpoint along with the request ID to verify the code, and Nexmo returns a status depending on if the code is valid or not. Quite simple right? 

I particularly like Nexmo Verify because of something called workflows. With workflows, you can set up multiple fallback options in case a user doesn’t receive the code via SMS on time. You can set up a fallback option for a voice call after a certain duration and much more, you can read about workflows [here](https://developer.nexmo.com/verify/guides/workflows-and-events). 

## What You Need to Get Started:

* Self-hosted [WordPress](https://wordpress.com) website 

<sign-up></sign-up>


## Creating Your WordPress Plugin

While you can create a WordPress plugin by simply adding a new folder in the WordPress plugins folder, a really efficient way is using a lightweight boilerplate to get started. Boilerplates are helpful to set up all the files and Classes in a standard way. In this tutorial, you’ll be using the [wppb](https://wppb.me/) boilerplate; simply fill in the details on the website, and click the build plugin button to download your plugin boilerplate. 

![Wordpress Plugin Boilerplate Generator](/content/blog/adding-2-factor-authentication-to-wordpress-with-nexmo-verify-api/wordpress_login.png "Wordpress Plugin Boilerplate Generator")

Once you have that, extract the zip file and put it in your WordPress plugins folder.  Next, go to your WordPress admin, navigate to the installed plugins page and activate your plugin. 

![Plugins](/content/blog/adding-2-factor-authentication-to-wordpress-with-nexmo-verify-api/plugins.png "Plugins")

## User Stories

With our goal of setting up 2FA on WordPress, let’s break the idea into actionable user stories/steps and implement them from top to bottom: 

* On the WordPress user profile settings, you’ll need custom fields for the user’s 2FA mobile number and if they’re enabled for 2FA
* You’ll send a code to the user’s mobile number when they log in 
* You’ll have a form for the user to enter the code they received and verify the code

#### Understanding WordPress Actions and Filters

Most of the edits you’ll be making on WordPress have to do with hooking your functions to existing WordPress actions and filters; <strong>Actions</strong> are functions performed when a certain event occurs in WordPress. Hence, if you want your function to run when a specific event occurs e.g when a user logs in, you’ll hook your function to the login related action. On the other end, <strong>Filters</strong> modify certain functions; you can use a filter to manipulate the result of a function.

You hook your function to an existing action like this:

`add_action( 'action_name', 'name_of_your_function' );`

You hook your function to a filter like this:

`add_filter( 'filter_name', 'name_of_your_function' );`

## User Custom Fields

For brevity of this post, here’s the [link](https://github.com/Kendysond/two-factor-auth-nexmo/blob/dca42f3695ad8385cd1655f942b5f42e8b45b16c/admin/class-two-factor-auth-nexmo-admin.php#L62) to the code that adds the mobile number and 2FA enabled checkbox fields to the WordPress user profile settings. With that setup, your user settings page would look like this:

![Nexmo 2FA](/content/blog/adding-2-factor-authentication-to-wordpress-with-nexmo-verify-api/nexmo_2fa.png "Nexmo 2FA")

## Adding the Nexmo PHP Library to the Mix

Nexmo recommends you install their [PHP Library](https://github.com/Nexmo/nexmo-php) via Composer; you’ll need to have Composer set up on your server/local system. If you don’t have Composer set up, here are two guides recommended by Nexmo to help you: [GetComposer.org](https://getcomposer.org/doc/00-intro.md) or [Scotch.io](https://scotch.io/tutorials/a-beginners-guide-to-composer) 

With Composer installed, open your terminal, navigate to your plugin’s root folder, and run: 

```bash
composer require nexmo/client
```

It’ll create a new folder called `vendor` that contains a number of other libraries, Nexmo’s PHP Library included. To include the Library in your plugin, simply add this line to your plugin’s root PHP file.

`require_once plugin_dir_path( __FILE__ ) . 'vendor/autoload.php';`  

#### Initializing the Nexmo Class

Before you can make any call with Nexmo’s PHP Library, you need to initialize the Nexmo Class and use the client object to make your subsequent requests. 

```php
$basic  = new \Nexmo\Client\Credentials\Basic(NEXMO_API_KEY, NEXMO_API_SECRET);
$client = new \Nexmo\Client(new \Nexmo\Client\Credentials\Container($basic));
```

If you’re using the boilerplate, you can make the following edits in the [public Class file](https://github.com/Kendysond/two-factor-auth-nexmo/blob/master/public/class-two-factor-auth-nexmo-public.php) in your plugin’s `/public` folder. You’ll be initializing the Nexmo Library in the construct and setting the client object as a protected variable so other methods of our public Class can access it. 

```php
<?php
 
 
class Two_Factor_Auth_Nexmo_Public {
 
    protected $nexmo_client;
 
    public function __construct( $plugin_name, $version ) {
       $this->nexmo_client = new Nexmo\Client(new Nexmo\Client\Credentials\Basic(TWO_FACTOR_AUTH_NEXMO_KEY, TWO_FACTOR_AUTH_NEXMO_SECRET));
       
    }
}
```

#### Sending the Verification Request

Based on our user story, we want to intercept the user login, check if the user is enabled for 2FA, and if they are, initiate a [Send Verification](https://developer.nexmo.com/verify/code-snippets/send-verify-request) request to their mobile number. To achieve this, you'll be hooking the `authenticate` WordPress action as it’s the action triggered when a user logs in successfully.  

```php
<?php
 
class Two_Factor_Auth_Nexmo_Public {
 
    protected $nexmo_client;
 
    public function __construct( $plugin_name, $version ) {
        $this->nexmo_client = new Nexmo\Client(new Nexmo\Client\Credentials\Basic(TWO_FACTOR_AUTH_NEXMO_KEY, TWO_FACTOR_AUTH_NEXMO_SECRET));
        
 
        add_action( 'authenticate', array( $this, 'intercept_login_with_two_factor_auth' ), 10, 3 );
    }
 
    public function intercept_login_with_two_factor_auth( $user, $username, $password ) {
        $errors = array();
        $redirect_to = isset( $_POST['redirect_to'] ) ? $_POST['redirect_to'] : admin_url();
        $remember_me = ( isset( $_POST['rememberme'] ) && $_POST['rememberme'] === 'forever' ) ? true : false;
        
        $_user = get_user_by( 'login', $username );
 
        if ( $_user ) {
            $this->verify_user( $_user, $redirect_to, $remember_me );
        }
 
        return $user;
    }
```

Hooking our function into the `authenticate` action gives us three variables to work with: `$user`, `$username`, and `$password`, the `$user` variable is typically null, but that’s okay.  What you need is the `$username`, with that, you can call the WordPress function to get the user object. You need the user object to get other properties of the user like the mobile number and if they’re enabled for 2FA. 

```php
$_user = get_user_by( 'login', $username );// Function to get the user object
```

To get the value for a user’s custom fields, you use the WordPress function `get_user_meta`, passing the user ID and the name for the custom field. As defined in the user profile settings code, the name of the fields are `two_factor_auth_nexmo_enabled` and `two_factor_auth_nexmo_mobile`. 

```php
  private function verify_user( $user, $redirect_to, $remember_me, $errors = array() ) {
        
        $enabled_2fa = get_user_meta($user->ID, 'two_factor_auth_nexmo_enabled', true );
        $mobile = get_user_meta($user->ID, 'two_factor_auth_nexmo_mobile', true );
        
        if ( ! $mobile || ! $enabled_2fa) {
            return;
        }
 
        try {
            $verification = new \Nexmo\Verify\Verification($mobile, TWO_FACTOR_AUTH_NEXMO_SENDER_NAME);
            $this->nexmo_client->verify()->start($verification);
        }
        catch(Exception $e) {
            $errors = array( "Error sending verification request" );
        }
        
 
        $request_id = $verification->getRequestId();
        update_user_meta( $user->ID, 'two_factor_auth_nexmo_request_id', $request_id);
        
        wp_logout();
        
    }
```

If all the required variables are set (mobile number and 2FA enabled for the user), you call the function to initiate a [Send Verification](https://developer.nexmo.com/verify/code-snippets/send-verify-request) request, Nexmo sends the user the unique code, and a request ID is returned. It’s important to store the request ID so you can use it to call the Validate code function in the next step. A simple way to do this is using the WordPress `update_user_meta` function with the key identifier for the variable (in our case `two_factor_auth_nexmo_request_id`) and the variable `$request_id`.

Lastly, call the `logout` function. You might be wondering, why would you do that? You do this because, as initially stated, the authenticate action is triggered when the user has successfully logged in. So in reality, all of this code is running when the user is logged in, but that’s not what you want—at least not yet. You want the user logged in only after validating the code. Hence, log the user out after sending the code, and that leads us to our final step, validating the code and logging the user in. 

#### Validating the Code

You’ve sent the code to the user in the above section, all that’s left is showing the user a form to enter the code they received and validating it against their profile to log them in. 

Building on the `verify_user` function you created earlier, you’ll be adding the code validation form.

```php
private function verify_user( $user, $redirect_to, $remember_me, $errors = array() ) {
        
        $enabled_2fa = get_user_meta($user->ID, 'two_factor_auth_nexmo_enabled', true );
        $mobile = get_user_meta($user->ID, 'two_factor_auth_nexmo_mobile', true );
        
        if ( ! $mobile || ! $enabled_2fa) {
            return;
        }
 
        try {
            $verification = new \Nexmo\Verify\Verification($mobile, TWO_FACTOR_AUTH_NEXMO_SENDER_NAME);
            $this->nexmo_client->verify()->start($verification);
        }
        catch(Exception $e) {
            $errors = array( "Error sending verification request" );
        }
        
 
        $request_id = $verification->getRequestId();
        update_user_meta( $user->ID, 'two_factor_auth_nexmo_request_id', $request_id);
        
        wp_logout();
        nocache_headers();
        header('Content-Type: ' . get_bloginfo( 'html_type' ) . '; charset=' . get_bloginfo( 'charset' ) );
        login_header('Nexmo Two-Factor Authentication', '<p class="message">' . sprintf( 'Enter the PIN code sent to your mobile number ending in <strong>%1$s</strong>' , substr($mobile, -5) ) . '</p>');
 
        if(!empty($errors)) { 
        
        ?>
            <div id="login_error"><?php echo implode( '<br />', $errors ) ?></div>
        <?php  } ?>
 
        <form name="loginform" id="loginform" action="<?php echo esc_url( site_url( 'wp-login.php', 'login_post' ) ) ?>" method="post" autocomplete="off">
            <p>
                <label for="two_factor_auth_nexmo_pin_code">Code
                    <br />
                    <input type="number" name="two_factor_auth_nexmo_pin_code" id="two_factor_auth_nexmo_pin_code" class="input" value="" size="6" />
                </label>
            </p>
            <p class="submit">
                <input type="submit" name="wp-submit" id="wp-submit" class="button button-primary button-large" value="Verify" />
                <input type="hidden" name="log" value="<?php echo esc_attr( $user->user_login ) ?>" />
                <input type="hidden" name="two_factor_auth_nexmo_request_id" value="<?php echo esc_attr( $request_id ) ?>" />
                <input type="hidden" name="redirect_to" value="<?php echo esc_attr( $redirect_to ) ?>" />
 
                <?php if ( $remember_me ) : ?>
                    <input type="hidden" name="rememberme" value="forever" />
                <?php endif; ?>
            </p>
        </form>
 
        <?php 
        
        login_footer( 'two_factor_auth_nexmo_pin_code' );
 
        exit;
    }
```

**NB**: I have my HTML in the Class method here, but you can always put yours in a separate file and include it.

With the above code, you should have a page that looks like this when you try to log in to an account enabled for 2FA.

![Wordpress Pin](/content/blog/adding-2-factor-authentication-to-wordpress-with-nexmo-verify-api/wordpress-pin.png "Wordpress Pin")

The `login_header` function adds that small section above the form that shows the last 5 digits of the user’s mobile number. 

The `<form>` in this view is a replica of the WordPress login form with just a couple changes. If you inspect your WordPress login form via your browser, you’ll notice the username input field has a name attribute called “<strong>log</strong>.” Keep that because that’s how WordPress gets the username variable; however, in this case, you’ll pass the username from your user object. For keeping the experience of redirects and remember me preference from the initial login session, keep those variables in their respective input field names, but this time, they’ll be hidden. Lastly, pass the request ID from the Send Verification request call in a hidden input field as well as the value for the code the user enters—all of these would be used for validating the code. 

The form’s parameters are:

* `log`: Username of the user 
* `two_factor_auth_nexmo_pin_code`: Code the user enters
* `two_factor_auth_nexmo_request_id`: Request ID from the initial request
* `rememberme`: Remember me status from the initial login 
* `redirect_to`: Redirect to URL if the user was trying to access a particular page before the login form
          

**Important note:** The form’s action URL is still the WordPress login URL route
`<?php echo esc_url( site_url( 'wp-login.php', 'login_post' ) ) ?>`, What’s interesting is, because our intercept function is hooked to the authenticate action, when you click the verify button on the verify code form, your intercept function still runs, and that’s where you add the code snippet to validate the code the user entered. 

```php
public function intercept_login_with_two_factor_auth( $user, $username, $password ) {
        $errors = array();
        $redirect_to = isset( $_POST['redirect_to'] ) ? $_POST['redirect_to'] : admin_url();
        $remember_me = ( isset( $_POST['rememberme'] ) && $_POST['rememberme'] === 'forever' ) ? true : false;
        
        $_user = get_user_by( 'login', $username );
// New addition
        $saved_request_id =  ($_user) ? get_user_meta($_user->ID, 'two_factor_auth_nexmo_request_id', true ) : null;
        $nexmo_pin_code = isset( $_POST['two_factor_auth_nexmo_pin_code'] ) ? $_POST['two_factor_auth_nexmo_pin_code'] : false;
        $nexmo_request_id = isset( $_POST['two_factor_auth_nexmo_request_id'] ) ? $_POST['two_factor_auth_nexmo_request_id'] : false;
        
        if ( $nexmo_request_id && $nexmo_pin_code && $saved_request_id == $nexmo_request_id ) {
            
            $verification = new \Nexmo\Verify\Verification($nexmo_request_id);
            try {
                $result = $this->nexmo_client->verify()->check($verification, $nexmo_pin_code);
                $response = $result->getResponseData();
                if ($response['status']  == "0") {
                    wp_set_auth_cookie( $_user->ID, $remember_me );
                    wp_safe_redirect( $redirect_to );
                    exit;
                }
            }
            catch(Exception $e) {
                // handle invalid  code
                if ($e->getCode() == 16){
                    $errors = array( "Invalid PIN code" );
                }
                $this->verify_user( $_user, $redirect_to, $remember_me,$errors );
            }
        }
// End of addition
        if ( $_user ) {
            $this->verify_user( $_user, $redirect_to, $remember_me );
        }
 
        return $user;
    }
```

In the above addition, you are checking the POST data of the login request to see if the `'two_factor_auth_nexmo_pin_code'` and `'two_factor_auth_nexmo_request_id'` keys are set. If they are, it is a request to validate a code. To ensure you’re validating the code for the right user, you also compare the request ID from the POST data with the request ID saved on the user’s profile; if they match, then you call the [Check Verification](https://developer.nexmo.com/verify/code-snippets/check-verify-request) function to verify the code entered is correct. If it’s correct, you set the WordPress authentication cookie for the user and redirect them to the dashboard. 

```php
wp_set_auth_cookie( $_user->ID, $remember_me );
wp_safe_redirect( $redirect_to );
```

If it’s not, you simply call the `verify_user` function again and send a new verification code.

Here’s a [link](https://github.com/Kendysond/two-factor-auth-nexmo/blob/master/public/class-two-factor-auth-nexmo-public.php) to the full Class file. 

## Conclusion

In this tutorial, you learned the basics of building a WordPress plugin, integrating the Nexmo PHP Library, and using the Nexmo Verify API. I hope you found this very helpful; you can check out the full code on GitHub via this [link](https://github.com/Kendysond/two-factor-auth-nexmo).  Thanks for reading!