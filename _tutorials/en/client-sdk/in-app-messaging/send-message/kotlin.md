---
title: Send a message
description: In this step you will send a message to the conversation
---

# Send a message

Time to send the first message.

To send a message register a callback inside `onCreate` method:

```kotlin
findViewById<View>(R.id.sendMessageButton).setOnClickListener { sendMessage() }
```

Add `sendMessge` method inside `MainActivity`:

```kotlin
private fun sendMessage() {
    val message = messageEditText.text.toString()

    if (message.trim { it <= ' ' }.isEmpty()) {
        Toast.makeText(this, "Message is blank", Toast.LENGTH_SHORT).show()
        return
    }

    messageEditText.setText("")
    hideKeyboard()

    conversation?.sendMessage(NexmoMessage.fromText(message), object : NexmoRequestListener<Void?> {
        override fun onError(apiError: NexmoApiError) {
            Toast.makeText(this@MainActivity, "Error sending message", Toast.LENGTH_SHORT).show()
        }

        override fun onSuccess(aVoid: Void?) {}
    })
}
```

The above method hides the keyboard, clears the text field and sends the message.

Now in the `MainActivity ` add the missing `hideKeyboard` method - the utility method that hides Android system keyboard:

```kotlin
private fun hideKeyboard() {
    val inputMethodManager = ContextCompat.getSystemService(this, InputMethodManager::class.java)

    val view = currentFocus ?: View(this)
    inputMethodManager?.hideSoftInputFromWindow(view.windowToken, 0)
}
```

You'll notice that, although the message was sent, the conversation doesn't include it. Let's do that in the next step.
