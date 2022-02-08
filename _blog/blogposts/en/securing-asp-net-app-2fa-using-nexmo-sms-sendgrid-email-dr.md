---
title: Securing Your ASP.NET App with 2FA Using Nexmo SMS and SendGrid Email
description: Learn how to secure your ASP.NET application with Two-factor
  authentication using Vonage SMS API and SendGrid email
thumbnail: /content/blog/securing-asp-net-app-2fa-using-nexmo-sms-sendgrid-email-dr/2fa-with-sms-or-email.png
author: sidharth-sharma
published: true
published_at: 2016-08-10T22:34:18.000Z
updated_at: 2021-05-17T12:38:12.449Z
category: tutorial
tags:
  - dotnet
  - 2fa
  - sms-api
comments: true
redirect: ""
canonical: ""
---
2FA (2 Factor Authentication) is a must nowadays to increase the security within your application. It is seen in all kinds of apps: from the signup process to user action verification. The most common types of 2FA are phone verification and email verification.

In this tutorial we'll show how to set up 2FA in your .NET application using ASP .NET Identity, the [Nexmo C# Client Library](https://github.com/nexmo/nexmo-dotnet) for SMS auth and the [SendGrid C# Client](https://github.com/sendgrid/sendgrid-csharp) for email auth.

If you just want to see the result you can take a look at [the video](#video) or [grab the code](https://github.com/nexmo-community/sms-email-2fa-dotnet-example).

#### Setup ASP .NET MVC application

Open Visual Studio and create a new ASP .NET MVC application. For this demo, we'll delete the Contact &amp; About sections from the default generated website. 

#### Install the Nexmo Client to your app via NuGet Package Manager

Add the Nexmo Client to your application via the NuGet Package Console. 

```bash
PM> Install-Package Nexmo.Csharp.Client
```

#### Install the SendGrid client via NuGet Package Manager

```bash
PM> Install-Package SendGrid -Version 8.0.3
```

#### Add Nexmo and SendGrid credentials

For the purpose of the demo we'll put the Nexmo and SendGrid credentials in the <appSettings> section of the `Web.config` file. If we were developing this application for distribution we may chose to enter these credentials in our Azure portal.

```xml
<add key="Nexmo.Url.Rest" value="https://rest.nexmo.com"/>
<add key="Nexmo.Url.Api" value="https://api.nexmo.com"/>
<add key="Nexmo.api_key" value="NEXMO_API_KEY"/>
<add key="Nexmo.api_secret" value="NEXMO_API_SECRET"/>
<add key="SMSAccountFrom" value="SMS_FROM_NUMBER"/>
<add key="mailAccount" value="SENDGRID_API_KEY"/>
```

#### Plug in Nexmo in the SMS Service, SendGrid in the Email Service

Inside the `IdentityConfig.cs` file, add the SendGrid configuration in the `SMSService` method. Then, plug in the Nexmo Client inside the `SMSService` method of the `IdentityConfig.cs` file.

Remember to add the using directives for the `Nexmo.Api` and `SendGrid` namespaces, and any other namespaces that are flagged as missing.

```cs
public class EmailService : IIdentityMessageService
{
    public async Task SendAsync(IdentityMessage message)
    {
        // Plug in your email service here to send an email.
        await configSendGridasync(message);
    }
    private async Task configSendGridasync(IdentityMessage message)
    {
        string apiKey = ConfigurationManager.AppSettings["mailAPIKey"];       
        dynamic sg = new SendGridAPIClient(apiKey, "https://api.sendgrid.com");
        
        Email from = new Email("demo@nexmo.com");
        string subject = message.Subject;
        Email to = new Email(message.Destination);
        Content content = new Content("text/plain", message.Body);
        Mail mail = new Mail(from, subject, to, content); 

        dynamic response = await sg.client.mail.send.post(requestBody: mail.Get()); 
    }
}

public class SmsService : IIdentityMessageService
{
    public Task SendAsync(IdentityMessage message)
    {
        var sms = SMS.Send(new SMS.SMSRequest
        {
            from = ConfigurationManager.AppSettings["SMSAccountFrom"],
            to = message.Destination,
            text = message.Body
        });
        return Task.FromResult(0);
    }
}
```

#### Add 'SendEmailConfirmationTokenAsync()' method to 'AccountController'

Add the following method to your `AccountController` which will be called on user registration to send a confirmation email to the provided email address.

```cs
private async Task<string> SendEmailConfirmationTokenAsync(string userID, string subject)
{
    string code = await UserManager.GenerateEmailConfirmationTokenAsync(userID);
    var callbackUrl = Url.Action("ConfirmEmail", "Account",  new { userId = userID, code = code }, protocol: Request.Url.Scheme);
    await UserManager.SendEmailAsync(userID, subject, "Please confirm your account by clicking <a href="" + callbackUrl + "">here</a>");
    return callbackUrl;
}
```

#### Update 'Register' action method

Inside the `Register` method of the `AccountController`, add a couple properties to newly created variable of the ApplicationUser type: `TwoFactorEnabled` (`true`), `PhoneNumberConfirmed` (`false`). Once the user is successfully created, store the user ID in a session state and redirect the user to the `AddPhoneNumber` action method in the `ManageController`.

```cs
[AllowAnonymous]
public ActionResult AddPhoneNumber()
{
    return View();
}

[HttpPost]
[AllowAnonymous]
[ValidateAntiForgeryToken]
public async Task<ActionResult> Register(RegisterViewModel model)
{
    if (ModelState.IsValid)
    {
        var user = new ApplicationUser { UserName = model.Email, Email = model.Email, TwoFactorEnabled = true, PhoneNumberConfirmed = false};
        var result = await UserManager.CreateAsync(user, model.Password);
        if (result.Succeeded)
        {
            Session["UserID"] = user.Id;
            return RedirectToAction("AddPhoneNumber", "Manage");
        }
        AddErrors(result);
    }
    // If we got this far, something failed, redisplay form
    return View(model);
}
```

#### Check DB for existing phone number and add SMS logic to the AddPhoneNumber action method

In the `ManageController` add the `[AllowAnonymous]` attribute to both the GET &amp; POST `AddPhoneNumber` action methods. This gives the currently unregistered user access to the phone number confirmation workflow. Make a database query to check if the phone number entered by the user is previously associated with an account. If not, redirect the user to the `VerifyPhoneNumber` action method.

```cs
[HttpPost]
[AllowAnonymous]
[ValidateAntiForgeryToken]
public async Task<ActionResult> AddPhoneNumber(AddPhoneNumberViewModel model)
{
    if (!ModelState.IsValid)
    {
        return View(model);
    }
    var db = new ApplicationDbContext();
    if (db.Users.FirstOrDefault(u => u.PhoneNumber == model.Number) == null)
    {
        // Generate the token and send it
        var code = await UserManager.GenerateChangePhoneNumberTokenAsync((string)Session["UserID"], model.Number);
        if (UserManager.SmsService != null)
        {
            var message = new IdentityMessage
            {
                Destination = model.Number,
                Body = "Your security code is: " + code
            };
            await UserManager.SmsService.SendAsync(message);
        }
        return RedirectToAction("VerifyPhoneNumber", new { PhoneNumber = model.Number });
    }
    else
    {
        ModelState.AddModelError("", "The provided phone number is associated with another account.");
        return View();
    }
}
```

#### Update VerifyPhoneNumber Action method

Add the `[AllowAnonymous]` attribute to the GET action method and delete everything in the method but the return statement that directs the verification flow,

```cs
[AllowAnonymous]
public async Task<ActionResult> VerifyPhoneNumber(string phoneNumber)
{
    return phoneNumber == null ? View("Error") : View(new VerifyPhoneNumberViewModel { PhoneNumber = phoneNumber });
}
```

Replace `User.Identity.GetUserId()` with `Session["UserID"]` in the method as shown below. If the user successfully enters the pin code, they are directed to the Index view of the `ManageController`. The User's boolean property `PhoneNumberConfirmed` is then set to `true`.           

```cs
[AllowAnonymous]
[HttpPost]
[ValidateAntiForgeryToken]
public async Task<ActionResult> VerifyPhoneNumber(VerifyPhoneNumberViewModel model)
{
    if (!ModelState.IsValid)
    {
        return View(model);
    }
    var result = await UserManager.ChangePhoneNumberAsync((string)Session["UserID"], model.PhoneNumber, model.Code);
    if (result.Succeeded)
    {
        var user = await UserManager.FindByIdAsync((string)Session["UserID"]);
        if (user != null)
        {
            await SignInManager.SignInAsync(user, isPersistent: false, rememberBrowser: false);
        }
        return RedirectToAction("Index", new { Message = ManageMessageId.AddPhoneSuccess });
    }
    // If we got this far, something failed, redisplay form
    ModelState.AddModelError("", "Failed to verify phone");
    return View(model);
}
```

#### Check if the user has a confirmed email on Login

Back in the `AccountController`, update the `Login()` action method to check to see if the user has confirmed their email or not. If not, return an error message and redirect the user to the "Info" view. Also, call the `SendEmailConfirmationTokenAsync()` method passing in the `user.Id` and an email subject. 

```cs
[HttpPost]
[AllowAnonymous]
[ValidateAntiForgeryToken]
public async Task<ActionResult> Login(LoginViewModel model, string returnUrl)
{
    if (!ModelState.IsValid)
    {
        return View(model);
    }

    var user = await UserManager.FindByNameAsync(model.Email);
    if (user != null)
    {
        if (!await UserManager.IsEmailConfirmedAsync(user.Id))
        {
            string callbackUrl = await SendEmailConfirmationTokenAsync(user.Id, "Confirm your account");
            ViewBag.title = "Check Email";
            ViewBag.message = "You must have a confirmed email to login.";
            return View("Info");
        }
    }

    ...
```

#### Add Info View

Inside the `Views/Account`, create a new View named `Info` that the user will be redirected to if their email has not been confirmed. The view should contain the following code:

```xml
<h2>@ViewBag.Title.</h2>
<h3>@ViewBag.Message</h3>
```

#### Ensure 2FA Cannot be Bypassed

In the `Views/Account/Login.cshtml` delete the `<div class="form-group">` containing the 'Remember Me' checkbox. In `Views/Account/VerifyCode.cshtml` delete the `<div class="form-group">` for the "RememberBrowser" checkbox and the hidden RememberMe input. Delete the corresponding variable in each of the view models in `AccountViewModels.cs`: `SendCodeViewModel` and `VerifyCodeViewModel`. Finally, remove any usage of these variables (including method signatures) or where required replace the usage of these variables in the two with `false`. This will restrict the user from bypassing 2FA verification.

#### Conclusion

With that, you have a web app using ASP .NET Identity that is 2 Factor Authentication (2FA) enabled using Nexmo SMS and SendGrid Email as the different methods of verification.  

SMS and email provide additional layers of security to correctly identify users and further protect sensitive user information. Using the Nexmo C# Client Library and SendGrid's C# Client, you can add both SMS and email verification with ease.

Please [grab the code](https://github.com/nexmo-community/sms-email-2fa-dotnet-example) and try it for yourself.

Feel free to send me any thoughts/questions on Twitter [@sidsharma_27](https://twitter.com/sidsharma_27) or email me at [sidharth.sharma@nexmo.com](mailto:sidharth.sharma@nexmo.com)!