---
title: Send a message
description: In this step you will send a message to the conversation
---

# Send a message

Time to send the first message.

To send a message register a callback inside `onCreate` method:

```java
findViewById(R.id.sendMessageButton).setOnClickListener(it -> sendMessage());
```

Add `sendMessge` method inside `MainActivity`:

```java
private  void sendMessage() {
    String message = messageEditText.getText().toString();

    if (message.trim().isEmpty()) {
        Toast.makeText(this, "Message is blank", Toast.LENGTH_SHORT).show();
        return;
    }

    messageEditText.setText("");
    hideKeyboard();

    conversation.sendMessage(NexmoMessage.fromText(message), new NexmoRequestListener<Void>() {
        @Override
        public void onError(@NonNull NexmoApiError apiError) {
            Toast.makeText(MainActivity.this, "Error sending message", Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onSuccess(@Nullable Void aVoid) {

        }
    });
}
```

The above method hides the keyboard, clears the text field and sends the message.

Now in the `MainActivity ` add the missing `hideKeyboard` method - the utility method that hides Android system keyboard:

```java
private void hideKeyboard() {
    InputMethodManager inputMethodManager = ContextCompat.getSystemService(this, InputMethodManager.class);

    View view = getCurrentFocus();

    if (view == null) {
        view = new View(this);
    }

    inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), 0);
}
```

You'll notice that, although the message was sent, the conversation doesn't include it. Let's do that in the next step.
