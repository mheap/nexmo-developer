---
title: PHP
language: php
---

```php
$client = new Vonage\Client(
    new Vonage\Client\Credentials\Basic(API_KEY, API_SECRET),
    [
        'base_api_url' => 'https://api-sg-1.nexmo.com'
    ]
);
```