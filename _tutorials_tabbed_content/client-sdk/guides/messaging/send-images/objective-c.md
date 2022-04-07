---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"file.png"]);

[self.client uploadAttachmentWithType:NXMAttachmentTypeImage
                                    name:@"File name 2"
                                    data:imageData
                    completionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
    if (error == nil) {
        NSLog(@"Error sending image");
    }
    
    NSString *imageUrl = [data valueForKeyPath:@"original.url"];
    NXMMessage *imageMessage = [[NXMMessage alloc] initWithImageUrl:imageUrl];

    [conversation sendMessage:message completionHandler:^(NSError * _Nullable error) {
        ...
    }];
}];
```
