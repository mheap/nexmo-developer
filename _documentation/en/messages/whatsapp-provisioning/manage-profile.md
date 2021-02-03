---
title: Manage WhatsApp Business profile
meta_title: Manage your WhatsApp Business profile via the Vonage API dashboard or the WhatsApp Provisioning API. 
description: Both the Vonage API dashboard and the WhatsApp Provisioning API allow you to manage your WhatsApp Business profile. 
navigation_weight: 4
---

# Manage a WhatsApp Business Profile

Once cluster has been successfully deployed, you may now manage your WhatsApp Business profile via the Vonage API Dashboard or the [WhatsApp Provisioning API](/api/whatsapp-provisioning).

To manage your WhatsApp Business profile from the Vonage API dashboard:

> **Note** Your business profile is displayed when WhatsApp users tap to see your full contact information in the WhatsApp mobile app.

1. Navigate to the [Social Channels page(https://dashboard.nexmo.com/messages/social-channels)] on the Vonage API dashboard.
2. Click the **Edit** button corresponding to the WhatsApp application listed in the **Your connected social channels** list.
3. From this menu, you may edit the following:
    * **About** - The text displayed in your profile's **About** section - max 139 characters. It is a brief description seen by new users whenever they contact your business profile.
    * **Profile picture** - The photo displayed on your profile. Must be a square JPG or PNG with maximum dimensions of 640px X 640px and a maximum file size of 800kb.
    * **Business description** - A longer description of your business - max 256 characters. URLs are not hyperlinked.
    * **Address** - Your business address - max 256 characters.
    * **Business category** - Your business' industry selected from a pre-populated list of options.
    * **Contact email** - Your business' email - max 128 characters.
    * **Website** - Your business' websites maximum of 2 websites, max website length: 256. URLs are not hyperlinked.
4. Once you are finished editing the desired profile fields, click **Save**.

## Reference

* [Understanding WhatsApp messaging](/messages/concepts/whatsapp)
* [External Accounts API Reference](/api/whatsapp-provisioning)
