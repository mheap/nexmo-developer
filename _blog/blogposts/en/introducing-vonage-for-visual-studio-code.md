---
title: Introducing Vonage for Visual Studio Code
description: Announcing the new Vonage for Visual Studio Code extension,
  allowing developers to manage their Vonage applications, numbers and more from
  within their favorite IDE.
thumbnail: /content/blog/introducing-vonage-for-visual-studio-code/visual-studio-code_1200x600.png
author: michaeljolley
published: true
published_at: 2021-03-31T11:31:12.062Z
updated_at: 2021-03-31T11:31:14.157Z
category: announcement
tags:
  - opensource
  - vscode
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
We're always working to make building with our APIs easier for all developers.
With our new Vonage for Visual Studio Code extension, we're bringing our APIs
closer to your development experience. Vonage for VS Code gives you control of
your Vonage applications & numbers and provides code snippets to make
building your app faster than ever.

Let's review what you can do.

## Installing the Extension

You can find the Vonage for VS Code extension in the
[Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=Vonage.vscode).
Click **install** to add the extension to your editor.

Alternatively, you can manually install the plugin:

1. See the latest [Releases](https://github.com/Vonage/vscode/releases) for
   the Vonage/vscode GitHub project.
2. Download the release.vsix file from the latest release. The link is listed
   under the Assets section of the release.
3. Run `code --install-extension <path to release.vsix>` from your terminal.

## Authenticate Your Account

With the extension installed, click the Vonage logo in the activity bar. Then
you'll be prompted to authorize the extension with your account. Click the
`Provide API key & secret` button to authenticate. Once you've
logged in, your account information will begin to populate in the window.

![Example of logging into the extension](/content/blog/introducing-vonage-for-visual-studio-code/authorization.gif)

## Numbers

The Unassigned Numbers view contains a listing of numbers you own that aren't
assigned to applications. You can right-click any numbers in the view to
see additional options for that number, including copying the number to the
clipboard or assigning it to an application. It's also possible to cancel a
number using the context menu.

Purchasing a new number is fast. By pressing the button in the title bar
of the view, you'll be prompted to select the country, type, and pattern
(i.e., starts with 12) for your new number. Then choose the number you want,
and the extension will handle purchasing it.

![Quick view of some of the features for managing numbers](/content/blog/introducing-vonage-for-visual-studio-code/numbers.gif)

## Applications

We're aiming for 100% self-service with the Applications view. Start by
creating an application using the button in the title bar of the view. The
extension will prompt you for a name and optional public key. 

The right-click context menu on each application allows you to add, edit or
remove capabilities quickly. This includes the ability to update webhooks
for any of the capabilities. On the right of each application is a link to
view the application in the [Vonage API Dashboard](https://dashboard.nexmo.com)
or delete the application.

Each application is a tree item that can be expanded to show all the numbers
assigned to the application. Here you can remove the number from the application
and manage the number as you would in the numbers view. 

![Quick view of some of the features for applications](/content/blog/introducing-vonage-for-visual-studio-code/applications.gif)

## Account

Currently, the Account view provides a quick way to view your account balance.
In the future, we hope to provide some additional capabilities here, including
the ability to top-off your account. Are you giving a presentation, screen-sharing,
live-streaming? For privacy, click your current balance to toggle its visibility.

![Animated gif of the Account view](/content/blog/introducing-vonage-for-visual-studio-code/account.gif)

## What's Next?

We've included a few snippets in the initial release, but our next major focus
will be adding code snippets for several popular languages. Is there a killer
feature that we're missing? Perhaps something small that would improve the
user experience? The extension is in public beta, and we are eager to hear
your [feedback](https://docs.google.com/forms/d/e/1FAIpQLSffDoFTsYla2wMKk83x2TECXTYkixrIHVnoPTnIE7ft-hyu5A/viewform). We can't wait to see what you build!