---
title: Add Recording Route
description: Handle Recording event from Vonage
---

# Add Recording Route

After the call is finished recording, Vonage will send you a webhook containing the URL at which the recording can be retrieved. To retrieve the recording you'll use the `GetRecording` API, and just the recording to your disk for demonstration purposes.

```csharp
[HttpPost("/webhooks/recording")]
public async Task<IActionResult> Recording()
{
    var appId = _config["APPLICATION_ID"];
    var privateKeyPath = _config["PRIVATE_KEY_PATH"];
    var credentials = Credentials.FromAppIdAndPrivateKeyPath(appId, privateKeyPath);
    var voiceClient = new VoiceClient(credentials);
    var record = await Vonage.Utility.WebhookParser.ParseWebhookAsync<Record>(Request.Body, Request.ContentType);
    var recording = await voiceClient.GetRecordingAsync(record.RecordingUrl);
    await System.IO.File.WriteAllBytesAsync("your_recording.mp3", recording.ResultStream);
    return StatusCode(204);
}
```
