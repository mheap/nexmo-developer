---
title: Vonage at PHPUK 2022
description: Vonage went to and spoke at PHPUK 2022 in London. How was it? Find
  out more in this post!
thumbnail: /content/blog/vonage-at-phpuk-2022/event-report.png
author: james-seconde
published: true
published_at: 2022-03-02T11:41:49.049Z
updated_at: 2022-03-01T11:55:33.578Z
category: event
tags:
  - php
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
It will probably not come as too much of a surprise that the team was very excited about PHPUK 2022, given the circumstances of the past two and a half years. We've all had a number of setbacks (or false dawns, perhaps - for example, we were set to attend [LaraconEU](https://laracon.eu/online/), which was understandably pulled due to Amsterdam being the epicentre of the new COVID wave at that point) with tech events reopening back up to the world, and as you can imagine - from a Developer Relations standpoint we've found it extremely challenging. After all, meetups and conferences are a key part of connecting with people. We'd got a team heading to the event, armed with a full conference booth; things *feel* like they are starting to return "to normal".

The Omicron variant came along just as we were ready to get back out there. At PHPUK, I spoke with [Gary Hockin](https://twitter.com/GeeH) on delivering his keynote at [PHPScotland](https://conference.scotlandphp.co.uk/2021/) at the end of last year, which really was the only major PHP event other than [LonghornPHP](https://www.longhornphp.com/) that managed to actually happen. Numbers were down, and essential precautions made aspects of the conference harder. So, with PHPUK being more or less at the end of the Omicron COVID wave, we didn't know what to expect.

![Vonage's booth at PHPUK 2022](/content/blog/vonage-at-phpuk-2022/vonage.jpeg "Our booth at PHPUK 2022")

Precaution-wise we opted for team masks at our booth - you wear a mask, we wear a mask. While it made sense for us to be overly cautious, it seemed that the majority of delegates at the conference had opted not to wear masks.

### On Elephpants

![Elephpants, prizes and swag at our conference booth](/content/blog/vonage-at-phpuk-2022/pxl_20220218_110235485.jpg)

It has always given me a vague sense of pride that PHP is the only language with a [large set of collectable toys(https://elephpant.me/)to be had (sorry [Golang](https://gopher.golangmarket.com/), you're new to this!). Even during the [recording of a short comedy moment](https://twitter.com/VonageDev/status/1494615543533477939), the appearance of yellow elephpants had [the world's largest collector](https://twitter.com/asgrim) instantly DMing me to ask if these were new ones(!)

They were, in fact, not. We had some leftover branded ones from [our previous corporate entity](https://www.nojitter.com/vonage-acquires-nexmo-jumps-cpaas) to give away, but it did prompt the question: do we order a new batch of Vonage limited edition elephants? The answer among them team seemed to be a resounding "yes!"

I also managed to attend a handful of talks, all of which were of course superb.

### Derek Rethans on PHP8.1

OK, I'll admit it: I have been very lapsed in checking out PHP8.1 new language features. The only reason I actually have it on my machine was that I wrote an [experimental article on using PHP8.1 native fibers](https://learn.vonage.com/blog/2021/11/12/asyncronous-php-with-revoltphp-vonage-voice-api), but more on that later.

There are 3 things that stuck out for me here that Derek spoke on.

### Enums

The first one is the introduction of native `Enum` classes. Within the [Vonage PHP SDK](https://github.com/Vonage/vonage-php-sdk-core) and indeed throughout my development career, I have coded many, many client/service classes that have a large number of static constants. These constants often describe class state, so for example an SMS object can be 'dispatched', 'delivered', 'pending' etc. Another classic example would be a blog post with an editorial flow - so 'draft', 'in review', 'editor's desk', 'published' etc.

`Enums` are quite a nice solution to making your classes more type-safe. You can read more about their implementation [here](https://www.php.net/manual/en/language.types.enumerations.php), and as seen from [my article on Laravel 9](https://learn.vonage.com/blog/2022/02/25/laravel-9-strap-in/), major frameworks are already introducing them for relevant use-cases.

### array_is_list()

A regular complaint within the PHP world is how arrays are structured and therefore used by developers. When I first started coding in PHP, I was none the wiser when introduced to "hashed arrays" and "associative arrays", thinking it all made sense. However, many years of experience, battle-scars from weaker codebases, and insight from other languages (in this case, [Python](https://docs.python.org/3/tutorial/datastructures.html#)) have made me see PHP's implementation of arrays as a data structure for what they are: [a hack with the potential to cause a lot of problems](https://www.youtube.com/watch?v=nNtulOOZ0GY&list=PLAi1rj7b0ApWScH6njlptekH-WjohZ3zs).

The introduction of `array_is_list()` is a welcome move to perhaps a more intuitive approach to arrays. Now, you can check if the array is actually what would be defined in other languages as a `list`, namely a hash array with consecutive integer keys. You can find examples of this being used in practice [in the PHP documentation](https://www.php.net/manual/en/function.array-is-list.php).

### New keyword in Initialisers

This one is probably going to resonate most with regular framework users who create services regularly that use Dependency Injection. Alongside PHP8's [introduction of constructor property promotion](https://wiki.php.net/rfc/constructor_promotion), you can now use the `new` keyword inside the argument parentheses in the constructor to make pretty explicitly coded constructor classes. You can now take out null logic so that it would look something like this:

```php
class Article
{
	public function __construct(
		protected WorkflowState $workflowState = new WorkflowState('draft'),
	)
}
```

So, you can build an `Article` object with a `WorkflowState` of your choice, or it will default to creating it with the 'draft' state as default and promote it as `$this->workflowState`.

### Alexandra White on Documentation

The Developer Relations team at Vonage has a dedicated documentation writing team. Why? Because writing good documentation is hard; it is absolutely essential that your developers can get the right information they are looking for as quickly as possible. [Alexandra White](https://twitter.com/heyawhite) took us on a head-nodding journey of pitfalls, rage-inducing release notes, and how to consider your audience (spoiler: make sure you write your docs for past you, current you, peers, and community and make that your mindset every time).

Also touched on was [the curse of knowledge](https://twitter.com/SecondeJ/status/1494313941496967172), which is something I have regularly come across. At Vonage, we have to consider this problem constantly: we have *a lot* of APIs to document, so when either writing documentation or writing blog articles we are mindful to *never assume knowledge*. Software development in, say, the JavaScript world gives the developer an endless sea of choices, and so it is important to recognise that you read the room.

### Lorna Jane Mitchell on Open Source

In the last 5 years or so, we have seen a very high number of well-funded startups that are using the business model of releasing their core software as Open Source while retaining proprietary code as part of an enterprise or Pass/SaaS product. The "Open Source" aspect of what we do though, sometimes, as Lorna pointed out, loses its meaning. "Open Source" does not mean "free and on Github", as we sometimes see with projects uploaded and then quickly forgotten. Open Source means maintenance, collaboration, and community contributions; it is software that has a license purposefully picked that is most relevant to it rather than "chucking an MIT license and forgetting about it".

The license part of Lorna's talk certainly got me thinking - what licenses for all of our Open Source SDKs at Vonage do we use? Are they the correct licenses? (after conversations about this, yes, they are!). But what your software constitutes should also be documented - this I did not know about - in the [SBOM](https://www.whitesourcesoftware.com/sbom/), or *Software Bill of Materials* as part of your *Code Inventory*. All of these aspects to Open Source software are things we should consider more, especially perhaps in PHP land, given that [PHP is really one of the last truly Open Source languages](https://www.youtube.com/watch?v=5MYQrmgeIAE).

### Milko Kosturkov on Fibers

Asynchronous PHP has been available to developers since PHP5.6 introduced generators. Generators allowed the introduction of co-routines, which resulted in the creation of various asynchronous PHP frameworks such as [Swoole](https://openswoole.com/), [amphp](https://amphp.org/), and [ReactPHP](https://reactphp.org/).

The difference now is that fibers are native, and [Milko](https://twitter.com/mkosturkov) showed some solid implementation code slides on how you can actually code for the event loop. I'll admit, it is pretty hard stuff to follow, but what is important is to show and learn how to program asynchronously in PHP because the adoption rate of frameworks like [Framework X](https://framework-x.org/) and ReactPHP is only going up.

### Dave Liddament on Static Analysis

[I wrote an article recently on PHPStan](https://learn.vonage.com/blog/2021/11/30/scrub-up-cleaning-your-php-application-with-phpstan/), which is one of two well-maintained and used static analysis tools alongside [PsalmPHP](https://psalm.dev/). The work these library authors have put in to create these tools is nothing short of astonishing, and [Dave](https://twitter.com/DaveLiddament)'s "Jack and Jill" narrative to show a coding journey to make your code more robust really made me think about how lucky we have it in PHP-land sometimes. These tools, as demonstrated, can really turn your PHP codebase into what is effectively a compiled language (and thus bringing the benefits that come with compiled languages.)

### And last but not least: James Seconde on PHP-VCR

![James Seconde speaking on PHP-VCR on the Porter Tun Stage](/content/blog/vonage-at-phpuk-2022/pxl_20220218_145006739.jpg)

Numbers were already down this year because of COVID, but I was also somewhat unlucky in that [storm Eunice](https://www.bbc.co.uk/news/uk-60426382) was arriving in London, and not surprisingly people had started leaving early. As I found out later, it was probably a smart move as the storm took out the entire West Coast Mainline and Chiltern railway lines, leaving me stuck in London.

Despite these challenges, I thoroughly enjoyed getting on stage to talk about the discovery of [PHP-VCR](https://github.com/php-vcr/php-vcr) and showing code examples using the [PEST testing framework](https://pestphp.com/). Q&A turned out to be pretty lengthy, with interactions resulting in possible collaborations to bring PHP-VCR to Laravel and PEST (something I have already started investigating).

It was a great feeling to be back on stage, finally, after almost 3 years - but this is just the beginning. Keep an eye out on your local meetup groups to see if I pop up to give this talk again for you!