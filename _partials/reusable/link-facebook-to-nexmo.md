## Part 1: Connect your Facebook Page to your Vonage API account

Connecting your Facebook page to your Vonage API account allows Vonage to handle inbound messages and enables you to send messages from the Messages API.

1. To connect your Facebook page to your Vonage API account click [Connect your Facebook Page to Vonage](https://dashboard.nexmo.com/messages/social-channels).

2. Click the **Login with Facebook** button, enter login credentials for the desired account, and click **Log In**. Follow the prompts and then click **Done**.

3. Select the Facebook Page you want to connect to your Vonage API account from the drop-down list.

4. Enter the API key and API secret for your Vonage API account.

5. Click **Complete setup**. You will receive a message confirming your Facebook page has been successfully connected.

At this point your Vonage API Account and this Facebook Page are linked. The link between your Vonage API account and Facebook page expires after 90 days. After then you must [re-link it](#re-linking-your-facebook-page-to-your-nexmo-account).

## Part 2: Connect your Facebook Page to your Vonage API application

Once your Facebook page is connected to your Vonage API account, it becomes available for use by any of your applications. To connect the Facebook page to a Vonage API application:

1. Navigate to your [applications page](https://dashboard.nexmo.com/applications).

2. From the list, click on the application you want to link. You can filter by using the **Capabilities** drop down and selecting `messages` to make this easier.

3. Then, select the **Linked social channels** tab.

4. Click the **Link** button beside the Facebook Page to which you want to connect your application, ensuring that the **Provider** is **Facebook Messenger**.

You're now ready to receive messages users send to you on your Facebook Page.

> **NOTE:** If in the future you want to connect a different application to this Facebook page, you only need to repeat the procedure described in Part 2, for the new application.

## Re-connecting your Facebook page to your Vonage API account

> **Note:** The connection between your Vonage API account and Facebook page no longer has an expiration date. If your connection has expired, follow the steps in this section to re-establish a connection that does not expire.

You can re-connect your Vonage API account and Facebook page by performing the following steps:

1. Navigate to the [Social channels](https://dashboard.nexmo.com/messages/social-channels) page on the dashboard.

2. From the list of **Your connected social channels**, click the **Edit** button associated with the page you want to re-connect.

3. Click **Reconnect Facebook** page.

4. Enter login credentials for the desired account, and click **Log In**.

5. Click **Save**.
