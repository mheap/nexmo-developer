---
title: An Introduction To Git
description: A tutorial released during the event of Hacktoberfest 2020
  introducing Git to those wishing to learn how to use it.
thumbnail: /content/blog/an-introduction-to-git-dr/Blog_GitHub-Desktop_Pull-Requests_1200x600.png
author: greg-holmes
published: true
published_at: 2020-09-29T13:42:36.000Z
updated_at: 2021-04-19T10:36:57.462Z
category: tutorial
tags:
  - git
  - github
  - hacktoberfest
comments: true
redirect: ""
canonical: ""
---
Vonage is thrilled to be a Hacktoberfest 2020 partner. We’re [no strangers to open source](https://youtu.be/zYJpYMCy6PA), with our libraries, code snippets, and demos all on GitHub. To fully immerse yourself in the festivities, be sure to check out our [Hacktoberfest page](https://nexmo.dev/2GZcyHc) for details on all that we have planned!

## What Is Git?

[Git](https://git-scm.com/) is a distributed version control system intended to allow developers to track changes on all files within their projects. Git was designed to enable developers to coordinate new features and bug fixes over different branches among multiple people.

## How Can I Install Git?

This tutorial covers Git as a command-line tool; however, there are some fantastic Git graphical user interfaces (GUIs) available such as [GitHub Desktop](https://desktop.github.com/) and [Git Kraken](https://www.gitkraken.com/).

First, check whether you have Git installed on your computer. In your Terminal or Command prompt, type \`git --version\`. If installed, you should see an output similar to what's shown in the image below:

![An image showing the output of a command line request for git --version](/content/blog/an-introduction-to-git/git-version.png)

If you don't have Git installed, please go to [git-scm.com](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for the download and instructions on how to install Git on your Operating System.

## Create a Local Repository

A new project using Git will need to have a new repository created. To create your first repository on your local machine, in your Terminal, make sure you are within the directory you intend on using as your project directory, then run the following:

```bash
git init
```

This command will create a `.git` directory. This directory contains the information necessary for your project to be version controlled. It also includes the information about the project's branches, commits, and if you host your git repository remotely, the address for this remote repository. Having all of this information allows you to know which branches you can switch between for different purposes, as well as rolling back to various commits in the history if necessary.

## Add Files To the Repository

At this point, your repository is empty, so, to add some content to the repository, create a file in this project directory. It can be anything you wish. For example, a `README.md` file, which is where people tend to start when they first come across a repository + it's the default file shown on a Git repository service such as Github or Bitbucket.

Again, in the command line, but you can use a text editor or an IDE to create new files to your project.

```bash
touch README.md
echo 'This is the README file for my first Git repository' >> README.md
```

If you then open your file, you'll see the text `This is the README file for my first Git repository`.

## Commit Your New Files

At this point, your Git repository is still technically empty. You've created the file but, if you type `git status` you'll see something similar to the image below:

![An image showing the output of a command line request for git status](/content/blog/an-introduction-to-git/git-status.png)

As shown in the image above, the first line tells you which branch you're in, and the second line explains whether you have any unpushed commits. Following this, you'll see any untracked files which list the files you've yet to commit; in this instance, it's the `README.md` file.

Now it's time to add this file to commit it to history.

```bash
git add README.md
git commit -m "This is my first commit message"
```

## Branching Out

So far, you've created a new repository, then added your file to this new empty repository. What if you wanted to make a change to your file but fear it may break something? Or you have multiple people contributing to your repository and want to have some control over what ends up in your main primary branch? Using branches comes in handy here, to allow different versions of the code to exist at one time.

You can create a new branch by typing the following command:

```bash
git checkout -b <branch name>
```

If you wished to see what branches are available, type: `git branch` to list the branches you have locally on your machine.

## Add New Files To the New Branch

Your new branch at this moment is an exact copy of your primary branch. Create a new file to this new branch to make it different from the primary. The example below creates a `README2.md` file with a message within it:

```bash
touch README2.md
echo 'This is the README2 file for my first Git repository, in the second branch' >> README2.md
```

Now commit this change with the following:

```bash
git add README2.md
git commit -m "This is my second commit message."
```

## Compare Differences Between Primary and New Branch

Your new second branch is now out of sync with the primary branch. If you want to see the differences between the two branches, run the command similar to: `git diff main..feature-a` replacing `main` with your primary branch name and `feature-a` with your second branch. The output will be similar to below where it shows a `README2.md` file exists in one branch but not the other.

```
diff --git a/README2.md b/README2.md
new file mode 100644
index 0000000..90372ea
--- /dev/null
+++ b/README2.md
@@ -0,0 +1 @@
+This is the README2 file for my first Git repository, in the second branch
```

Check out back into your primary branch with the command: `git checkout <primary branch name>`.

Now it's time to have a look at GitHub and hosting your repository remotely.

## GitHub

[Github](https://www.github.com) is a remote hosting platform to store your Git repositories. This service allows you to control your version control on a third party and collaborate with others on projects.

### Create a Repository on GitHub

Head over to [GitHub](https://github.com/new) to create a new repository. You will be presented with a screen similar to what you see below. Make sure to add the `Repository name` and then click on `Create repository`.

![An image showing the page when creating a GitHub Repository](/content/blog/an-introduction-to-git/create-github-repo.png)

Once created, some options are provided with how to get set up with your repository. As you already have the repository locally, choose the third option below where it says `...or push an existing repository from the command line`.

![Image showing the output on the page when a GtiHub repository is created.](/content/blog/an-introduction-to-git/github-repo-created.png)

### Create a Pull Request

You've now created your GitHub repository and pushed your primary branch to the remote repository. Next, push your second branch by typing the following command in your Terminal:

```bash
git push -u origin <branch name>
```

Then, in Github, navigate to your repository, click "Create Pull Request", and click on your second branch name. You're taken to a page with a list of changes. These changes show the commits and the files changed. Again, click on the "Create Pull Request" button to be taken to a page with two input boxes.

This part of creating a pull request allows you to describe the changes you wish to be merged into the primary branch. It is good practice to be as descriptive as possible in the description box. This page will allow anyone to understand what the changes are and how they impact the current project.

Once you're happy with the title, the description, and if you wanted to add anyone to review your pull request. Click the "Create Pull Request" button.

Now you or your co-contributors can review the changes and determine whether they should be merged into the primary branch.

If you are happy to merge this branch, click the "Merge Pull Request" button. You have now merged your changes into the primary branch.\
If you go back to your Terminal, make sure you are on the primary branch, then type `git pull`, you'll see the file you added to the second branch is now in your primary branch!

## Conclusion

If you have followed this tutorial from start to finish, you have now installed Git on your local machine, added some files, and committed these files to the repository history. You then branched out from your primary branch, added some more files, and again committed these files to the repository. 

Following the above steps, you created a GitHub account and a repository on GitHub. You then linked your local repository to your GitHub repository and pushed your branches, changes, and commits to this remote repository.\
Next, you created a `Pull Request`, which highlighted the differences between your two branches, and allowed you to merge the secondary branch into the primary, so that now all changes exist in the primary branch.

## Where Next?

With [Hacktoberfest](https://hacktoberfest.digitalocean.com/) just around the corner, there's no better time to put your Git learnings into practice! We are excited to be a [Hacktoberfest partner](https://www.nexmo.com/blog/2020/09/25/vonage-joins-hacktoberfest-2020) this year, so you might want to check out some of the [Vonage projects](https://www.nexmo.com/blog/2020/09/25/vonage-joins-hacktoberfest-2020) while you work towards your PR goal. Happy hacking!

Don't forget, if you have any questions, advice, or ideas you'd like to share with the community, then please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack).