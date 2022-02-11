---
title: Scrub Up! Cleaning Your PHP Application With PHPStan
description: "Learn what PHPStan can do for your legacy code: introducing
  compiler-like static analysis into your pipelines"
thumbnail: /content/blog/scrub-up-cleaning-your-php-application-with-phpstan/scrub-up_phpstan.png
author: james-seconde
published: true
published_at: 2021-11-30T11:02:10.147Z
updated_at: 2021-11-29T09:21:12.939Z
category: tutorial
tags:
  - php
  - testing
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
During my time as a PHP developer, the way we write and ship code has changed dramatically. In early [Symfony](https://symfony.com/) and [Zend Framework](https://framework.zend.com/) applications, the [PHP-FIG](https://www.php-fig.org/) didn't exist and coding standards were at the discretion of whoever was writing it. Over the years that we've seen widespread adoption of [PSR standards](https://www.php-fig.org/psr/), rock-solid static analysis tooling has been somewhat patchy. That is, until now, with the [release of version 1.0 of PHPStan](https://phpstan.org/blog/phpstan-1-0-released). Let's celebrate this occasion by going through some of its features!

### Compiled languages, your preemptive bug-squasher

One of the great advantages of using a compiled language such as [Java](java.com) or [](https://dotnet.microsoft.com/)[C#](https://docs.microsoft.com/en-us/dotnet/csharp/) is that compile-time will completely fail if your code isn't [typesafe](https://en.wikipedia.org/wiki/Type_safety), enforcing standards (though this is easy for me to say as it's not 2 am, on my 10th coffee of the night). With [PHP](https://www.php.net/) being an interpreted language, we don't have the same luxury.

### Interpreted as compiled: CI + tooling

Thanks to the sheer quantity of DevOps tooling available to us in modern web development and static analysis, the thing is *we do have the same tooling available but through different means*. As that is the case I cannot advocate **how much** I recommend you have something similar to the environment I'll be laying out. So why would you want this tooling? Let's look at an example.

### The scenario

It's common to try and pick a theme that's fun, or applicable to what you're writing about when it comes to tooling like this. But, for this article I'm going to present to you a scenario that I have personally come across time and time again in agency environments: 

**"Help! Someone else built my PHP app and I need someone to rescue it and take over maintenance of it because features X/Y/Z need to be built, but features A/B/C don't even work well!"**

Taking over someone else's codebase/project is always a complete lottery. If you're taking it over because it needs new features and it's already a tech-debt riddled mess, you know you've got to sort that out before you touch anything else. Worse, a lot of these projects (in my experience) tend to arrive with absolutely no tests to self-document the code. Consider a classic example, which I have seen time and time again:

```php
$someData = \MyNamespace\MyORM\MyRepository::findAllBySomething(SOMETHING);

foreach ($someData as $myEntity) {
	$myEntity->doTheThing();
}
```

You didn't write that entity class or the repository method. They've got no typehints because this was written originally in PHP5.3, or the developer didn't use any. It's fine if your ORM returns an array of the same entities, but one bug, one null result in the return value of `findAllBySomething()` and `doTheThing()` will throw a fatal error.

It's time to set [PHPStan](https://github.com/phpstan/phpstan) on it.

![](/content/blog/scrub-up-cleaning-your-php-application-with-phpstan/photo-1529220502050-f15e570c634e.jpeg)

### Know your strategy

While it's easy to say "use PHPStan" if you have a legacy or tech-debt-heavy application you'll want a strategy rather than just throwing things out there to see what happens. Firstly, you'll want to acquaint yourself with the Rule Levels.

#### Rule Levels

PHPStan is structured to run with given rule levels, numbered from 0-9:

1. basic checks, unknown classes, unknown functions, unknown methods called on `$this`, wrong number of arguments passed to those methods and functions, always undefined variables
2. possibly undefined variables, unknown magic methods, and properties on classes with `__call` and `__get`
3. unknown methods checked on all expressions (not just `$this`), validating PHPDocs
4. return types, types assigned to properties
5. basic dead code checking - always false `instanceof` and other type checks, dead `else` branches, unreachable code after return; etc.
6. checking types of arguments passed to methods and functions
7. report missing typehints
8. report partially wrong union types - if you call a method that only exists on some types in a union type, level 7 starts to report that; other possibly incorrect situations
9. report calling methods and accessing properties on nullable types
10. be strict about the `mixed` type - the only allowed operation you can do with it is to pass it to another `mixed`

This is why your strategy is important. If you've got a legacy project written by someone else and you fire the PHPStan task runner at level 9, you might be overwhelmed by the results it produces. Everything is broken! To refactor, I'd suggest the following:

* Set yourself milestones for each level identified, and start small.
* The long term investment will pay off eventually (we'll get onto the pipelines shortly), but set the top level you are willing to go to when classifying "fixed the tech debt" under your own "definition of done"
* A good de-facto target for a legacy project is to get Rule Level 6 passing. It's at this point where your codebase can likely transition from a state of "danger" to "correct". This would make Rule Level 6 [your baseline](https://phpstan.org/user-guide/baseline)).
* **This is super important**: make sure to assign time (sprints, broken down Jira tickets for the masochists) to *fix* what PHPStan is flagging at each rule level. Fixing tech debt is *not easy* in many cases, and you don't have any idea what kind of business-domain logic faults there could be in your application.
* While setting the incremental targets for Rule Levels, make sure you set up your [pipeline](#pipeline) before committing changes so that you don't introduce any new code smells while refactoring. Setting up your pipeline will need you to establish [your baseline](https://phpstan.org/user-guide/baseline), which we'll get to.

### Pipeline

In the world of DevOps, there are a somewhat overwhelming amount of tooling options available to solve your problems. For this instance, I'm offering just one approach, but it's less complex than other options available. Once you have established your strategy, it's time to set up your pipeline so that we don't commit any new code that hasn't been through PHPStan first.

#### Barriers of Defence: local vs. server-side

I like to introduce tooling to eliminate any possibility of single-points-of-failure, and as a result of that cynicism highly recommend that you run your static analysis on both local developers' machines *as well as* server-side CI checks in your repository.

##### Local

* Composer + PHPStan

Firstly, you'll want to install PHPStan inside your project. We're going to use [composer](https://getcomposer.org/) for this, working under the assumption that hopefully, your legacy code does use package management. If not, you can [install composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-macos) and use `composer init` to create a new project.

To install PHPStan, run the following:

```bash
$composer require --dev phpstan/phpstan
```

We're adding `--dev` as we don't need it for production (in theory!).

* Configuration: establishing the baseline

This is a pretty neat feature of PHPStan. Your baseline establishes your "ground zero" of your app so that any current errors that exist within the Rule Level of your choosing are ignored *until you decide to deal with them*, but at the same time *can enforce a rule level for any new changes committed*. A sensible approach as outlined in the strategy would be to set a baseline at Rule Level 6:

* All new code committed to the project would need to be at Rule Level 6
* You can then set out the tech-debt targets for the lower levels, as identified in your strategic goals.

To create your baseline, run the following:

```bash
vendor/bin/phpstan analyse --level 6 \  --configuration phpstan.neon \  src/ tests/ --generate-baseline
```

You'll now have your baseline configuration set in the file specified (`phpstan.neon`), which saves a detailed overview of errors per file.

Now you will want PHPStan to prevent commits to your repository *before* they can be pushed up to your source. For this, we use Git hooks.

* Git hooks

It somehow took me years to realise that git actually installs hooks as standard in a new git repository on `git init`. You can [read more about git hooks here](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks). We're going to edit the `pre-commit` hook. As long as you've not touched any hooks before in your project, you can enable the pre-commit hook by renaming it - run this from the root of your project:

```bash
mv ./.git/hooks/pre-commit.sample ./.git/hooks/pre-commit
```

Now open up the file, delete the contents and copy in the following:

```bash
#!/bin/sh  
#  
  
exec < /dev/tty  
  
if git rev-parse --verify HEAD >/dev/null 2>&1  
then  
 against=HEAD  
else  
 # Initial commit: diff against an empty tree object  
 against=4b825dc642cb6eb9a060e54bf8d69288fbee4904  
fi  
  
gitDiffFiles=$(git diff --name-only --diff-filter=d $against | grep \.php)  
  
if [ "$gitDiffFiles" != "" ]; then  
 analysisResult=$(vendor/bin/phpstan analyse $gitDiffFiles)  
  
 if [ "$analysisResult" = "" ]; then  
 echo 'PHPStan pass'  
  else  
 echo "$analysisResult"  
 exit 1;  
  fi  
fi  
  
# Redirect output to stderr.  
exec 1>&2  
  
# If there are whitespace errors, print the offending file names and fail.  
exec git diff-index --check --cached $against --
```

Now you've enabled `pre-commit`, PHPStan will fire before each commit and analyze against the baseline *for any new files that have been changed in the git commit*. No more smelly committed code!

You may want to adjust the command line trigger when you move up levels, so when it needs to change (or you want to enable other PHPStan features), change the `analysisResult=$(vendor/bin/phpstan analyse $gitDiffFiles)` line arguments.

##### Server-side

The more defense you can put up for your code, the better. Running PHPStan server-side after a push to your code as part of your Continuous Integration is a *must-have*.  For this example, we're going to use Github Actions, but bear in mind you can set this up with the same level of functionality in [CircleCI](https://circleci.com/), [Bitbucket Pipelines](https://support.atlassian.com/bitbucket-cloud/docs/get-started-with-bitbucket-pipelines/), [Gitlab CI/CD](https://docs.gitlab.com/ee/ci/), or [Jenkins](https://www.jenkins.io/). Here is an example actions workflow set up on Github, building your code with an [Ubuntu](https://ubuntu.com/) container:

```yaml
---  
name: build  
  
on: [ push, pull_request ]  
  
jobs:  
 build:  
 runs-on: ubuntu-latest  
    strategy:  
 matrix:  
 name: Build example
    steps:  
 - name: Checkout  
        uses: actions/checkout@v2  
  
      - name: Setup PHP  
        uses: shivammathur/setup-php@v2  
        with:  
 php-version: 8.0  
          extensions: json, mbstring  
          coverage: pcov  
        env:  
 COMPOSER_TOKEN: ${{ secrets.GITHUB_TOKEN }}  
  
      - name: Run PHPStan
        run: vendor/bin/phpstan analyse .
		
```

The command under "Run PHPStan" can be configurable to your requirements in the same way you can configure the command when running PHPStan locally. I've written this workflow to run PHPStan at a default level on all files within the project (this workflow hasn't fired `composer` yet, so will not have the unnecessary and inefficient step of running it on your `vendor` folder) so here I would recommend having a configuration to pull in that sets your entire project's Rule Level.

Your legacy project now has a strategy for scrubbing up your code, and pipelines to stop new bugs appearing in commits while performing analysis against the baseline for all the existing code. It's this kind of setup that can give you far more confidence in committing to the project while giving insights as to where the likely areas that need refactoring to take out tech debt.

### Last, but not least: static analysis vs. tests

I say this loudly, especially for the folks at the back: PHPStan and any other static analysis tool is not a replacement for your tests! The way I would frame its usage is that a test suite and PHPStan *complement each other* in assessing the quality of your code.

It's a misconception to believe that you have little or no need for a test suite. The most important thing here is that **static analysis cannot test your domain logic**. While it might seem an obvious statement, it's worth noting that it can be confusing as PHPStan **can** eliminate the need for certain tests. An example of this would be an `instanceOf` test, that asserts that a class being created is the end result of a process. PHPStan can remove this requirement, as it provides the analysis needed to eliminate this potential bug, but it *does not* know about your domain logic required beforehand - this is what you *do* need to test.

#### And remember, there are alternatives!

Did you give it a go? Not too keen on it? Everyone has their preference, and while I'll sing my praises to [Ondřej](https://ondrej.mirtes.cz/) for his work on PHPStan, it's worth noting that there are several other tools that either perform the same job or can be used in conjunction with PHPStan:

* [Psalm PHP (static analyser like PHPStan)](https://psalm.dev/)
* [GrumPHP (task runner to fire a suite of code quality tools)](https://github.com/phpro/grumphp)
* [PHPCS (a code linter)](https://github.com/squizlabs/PHP_CodeSniffer)

#### Thanks

Special thanks got to Ondřej Mirtes for both advice and all his hard work releasing this awesome tool.