# Vonage API Developer Portal

[![Build Status](https://api.travis-ci.org/Nexmo/nexmo-developer.svg?branch=main)](https://travis-ci.org/Nexmo/nexmo-developer/)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE.txt)

This repository is the content for <https://developer.nexmo.com>, which includes the Vonage documentation, API reference, SDKs, Tools & Community content. To get a Vonage account, sign up [for free at nexmo.com][signup].

### [Testing](#testing) &middot; [Running Locally](#running-locally) &middot; [Admin Dashboard](#admin-dashboard) &middot; [Troubleshooting](#troubleshooting) &middot; [Contributing](#contributing) &middot; [License](#license)

## Testing

### Spell Checking

We write the docs in US English and enforce this at build time with a CI check. You can run the check locally using the following command:

```
yarn spellcheck
```

Or if you're using Docker:

```
docker-compose exec web yarn spellcheck db:migrate
```

If there is a word that isn't in the dictionary but is correct to use, add it to the `.spelling` file (there's a lot of exceptions in there, including `Vonage`!)

### Prose Style Checking

We check our content for any offensive, ableist or gendered language and enforce this at build time with a CI check. You can run the check locally using the following command:

```
./node_modules/.bin/alex _documentation/en _partials _modals _tutorials
```

Or if you're using Docker:

```
docker-compose exec web ./node_modules/.bin/alex _documentation/en _partials _modals _tutorials
```

## Running locally

The project can be run on your laptop, either directly or using Docker. These instructions have been tested for Mac.

### Setup for running directly on your laptop

#### System Setup (OSX)

1.  Install Homebrew

    ```bash
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ```

2.  Install required packages, create database and configure `git`.

    > Note: A default database is created for you when you run the `db:setup` script. If you'd like to create and use a different database or user, use `createdb database_name_here` or `createuser username_here` and make sure your `.env` file is updated accordingly (See [.env.example](https://github.com/Nexmo/nexmo-developer/blob/master/.env.example)).

    ```bash
    brew install postgres rbenv git nvm redis
    brew services start postgresql
    brew services start redis
    ```

    If you have not already, update git config with your name and email address.
    
    ```
    git config --global user.name "NAME"
    git config --global user.email "user.name@vonage.com"
    ```

3.  Generate an SSH key for authentication

    ```bash
    ssh-keygen -t rsa
    cat .ssh/id_rsa.pub # Add to GitHub
    ```

4.  Clone ADP to your local machine:

    ```bash
    git clone git@github.com:Nexmo/nexmo-developer.git
    cd nexmo-developer
    ```

5.  Copy the contents of the example file: `cp .env.example .env` and check if it worked by running `cat .env` (it should produce an output)
6.  Open the file: `code .env`, find the redis line (probably line 35) and comment it out

7.  Install the correct versions of ruby, as well as dependencies:

    ```bash
    rbenv install 2.7.2
    rbenv global 2.7.2
    gem install bundle
    bundle install
    ```

    -   If you're getting error `rbenv: commend not found` run `brew update && brew update ruby-build`.
    -   If you're getting `ruby-build definition not found 2.7.2`, you need to update the xcode: `xcode-select --install`
    -   **NOTE**: If you use `rvm`: `rvm --default use 2.7.2 && gem install bundle && bundle install`

8.  Set up access to submodules: `git submodule init && git submodule update` and then `git config --global submodule.recurse true`
9.  Start postgres: `brew services start postgresql` and if that doesn't work `brew services restart postgresql`.

    -   If you're getting `PG::ConnectionBad - could not connect to server: Connection refused`, you can try installing the correct version or re-install postgres: `brew uninstall postgresql && rm -rf /usr/local/bin/postgres && rm -rf .psql_history .psqlrc .psql.local .pgpass .psqlrc.local && brew update && brew install postgres`

10. Start the local server:

    ```bash
    OAS_PATH=“pwd/_open_api/api_specs/definitions” bundle exec nexmo-developer --docs=`pwd` --rake-ci
    ```

    You should now be able to see the site on http://localhost:3000

### Setting up with Docker

If you don't want to install Ruby & PostgreSQL then you can use docker to sandbox the Vonage API Developer Portal into its own containers. After you [Install Docker](https://docs.docker.com/engine/installation/) run the following:

```sh
$ git clone git@github.com:Nexmo/nexmo-developer.git
$ cd nexmo-developer
```

Set up access to submodules with the following two commands:

```
git submodule init && git submodule update
```

and then:

```
git config --global submodule.recurse true
```

There are two ways to run docker-compose.

#### Foreground in terminal

```bash
$ docker-compose up
```

Once you can see the logs have booted the containers, open a new terminal window and proceed to running the migrations.

#### Background in terminal

You can also run docker as a background process by adding the switch to run it as a daemon. To do this, first run the following:

```bash
$ docker-compose up -d
```

Now check that your containers have booted by running `docker ps`. You should see the following two containers running:

```
nexmo-developer_web_1
nexmo-developer_db_1
```

Once you've confirmed that both containers are running, it's time to run the migrations.

#### Running the migrations

```
docker-compose run web bundle exec rake db:migrate
```

At this point, open your browser to http://localhost:3000/ and you should see the homepage. The first time you click on `Documentation` it might take 5 seconds or so, but any further page loads will be almost instantaneous.

To stop the server press `ctrl+c`.

> If you get an error that says "We're sorry, but something went wrong." you might need to run the database migrations with `docker-compose run web bundle exec rake db:migrate`

## Admin dashboard

You can access the admin dashboard by visiting `/admin`. Initially, you will have an admin user with the username of `api.admin@vonage.com` and password of `development`.

The following is an example if you are running the Vonage API Developer Portal within a Docker container:

```sh
docker exec -it <container_id> rake db:seed
```

New admin users can be created by visiting `/admin/users`.

## Working with submodules

Some of the contents of ADP are brought in via git submodules, such as the OpenAPI Specification (OAS) documents. A submodule is a separate repository used within the main repository (in this case ADP) as a dependency. The main repository holds information about the location of the remote repository and **which commit to reference**. So to make a change within a submodule, you need to commit to the submodule and the main repository and crucially remember to push both sets of changes to GitHub.

Here are some tips for working with submodules:

### When cloning the repo or starting to work with submodules

```bash
git submodule init
git submodule update
```

### When pulling in changes to a branch e.g. updating master

```bash
git pull
git submodule update
```

### When making changes inside the submodule within ADP

Make sure you are _inside_ the directory that is a submodule.

-   make your changes
-   commit your changes
-   _push your changes from here_ (this is the bit that normally trips us up)
-   open a pull request on the submodule's repository - we can't open the PR on the main repo until this is merged

You are not done, keep reading! A second pull request is needed to update the main repo, including any other changes to that repo _and_ an update to the submodule pointing to the new (merged) commit to use.

-   open your PR for this change including any changes to the main project (so we don't lose it) but label it "don't merge" and add the URL of the submodule PR we're waiting for
-   once the submodule has the change you need on its master branch, change into the subdirectory and `git pull`
-   change directory back up to the root of the project
-   commit the submodules changes
-   _push these changes too_
-   Now we can review your PR

### Bringing submodule changes into ADP

If you made changes on the repo outside of ADP, then you will need to come and make a commit on ADP to update which commit in the submodule the ADP repository is pointing to.

Make a branch, change into the submodule directory and `git pull` or do whatever you need to do to get `HEAD` pointing to the correct commit. In the top level of the project, add the change to the submodules file and commit and push. Then open the pull request as you would with any other changes.

### Further advice and resources for successful submodule usage

Never `git add .` this will make bad things happen with submodules. Try `git add -p` instead. You're welcome.

If you're not sure what to do, ask for help. It's easier to lend a hand along the way than to rescue it later!

Git docs for submodules: <https://git-scm.com/book/en/v2/Git-Tools-Submodules>

A flow chart on surviving submodules from @lornajane: <https://lornajane.net/posts/2016/surviving-git-submodules>

## Troubleshooting
<details>
<summary><b>My local setup stopped working after performing a <code>git pull</code>.</b></summary>
The Docker image may have changed, try rebuilding it with the following command:

```bash
$ docker-compose up --build
```
</details>

<details>
<summary><b>I get an exception <code>PG::ConnectionBad - could not connect to server: Connection refused</code> when I try to run the app.</b></summary>

This error indicates that PostgreSQL is not running. If you installed PostgreSQL using `brew` you can get information about how to start it by running:

```bash
$ brew info postgresql
```

Once PostgreSQL is running you'll need to create and migrate the database. See [Setup](#running-locally) for instructions.
</details>
<details>
<summary>
<b>File changes are not showing</b>
</summary>
In situations where changes you made in a file do not show up in your browser redo your Docker setup using the following steps:

- **Delete docker images:** Run these commands from your local repo folder checked with the branch you wish to work on. This will delete your old Docker containers and images:

```
docker rm -vf $(docker ps -a -q) THEN
docker rmi -f $(docker images -a -q)
```

- **Build:** In your local repo folder run `docker-compose up`. Wait until it completes without error.

- **Migration:** In a separate terminal, same folder, run `docker-compose run web bundle exec rake db:migrate`. Wait until it completes without error.

- **Test:** In your browser open http://localhost:3000 and navigate to test for your changes in your local copy of your documentation.

</details>

<details>
<summary>
<b>Clicking a link in the navbar leads to a broken page</b>
</summary>

 Whenever new sections similar to `_blog` , `_changelogs` are added they may not be registered which leads to a broken page when selected from the navbar.
 
 Check to see if the directory path is set in the `environment:` section of the  `docker-compose.yml` file. You can look up the right pathname to use from the `.env.example` file.
 
</details>

## Upgrading Volta

Volta is the Vonage design system, and is used to style the Vonage API Developer Portal. To upgrade the version of Volta used:

-   Clone Volta on to your local machine
-   Remove the `app/assets/volta/scss` folder in the Vonage API Developer Portal
-   Copy the `scss` folder from the Volta repo in to `app/assets/volta`
-   Commit and push. Rails will take care of compilation etc

## Contributing

We :heart: contributions from everyone! It is a good idea to [talk to us](https://nexmo-community-invite.herokuapp.com/) first if you plan to add any new functionality. Otherwise, [bug reports](https://github.com/Nexmo/nexmo-developer/issues/), [bug fixes](https://github.com/Nexmo/nexmo-developer/pulls) and feedback on the library are always appreciated. Look at the [Contributor Guidelines](CONTRIBUTING.md) for more information and please follow the [GitHub Flow](https://guides.github.com/introduction/flow/index.html).

## [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues) [![GitHub contributors](https://img.shields.io/github/contributors/Nexmo/nexmo-developer.svg)](https://GitHub.com/Nexmo/nexmo-developer/graphs/contributors/)

## Content Updates

Follow these instructions to make updates to any content in the Vonage API Developer Portal repository.

Checkout a new branch, naming it appropriately:

```bash
git checkout -b your-branch-name
```
There are three types of content you can add or update, these are seperated into different folders as well

- **Documentation**: You can find documentation content in the `_documentation/en` directory.
- **Blog content**: The blog content can be found in the `_blog/blogposts/en` directory. There is also `_blog/authors/en`, which contains the bios of the authors of the blog.
- **Changelog**: The update history of all tools and SDKs are tracked in the `_changelog/` directory. Folders in this directory act as subsections and files that represent the changelog for each tool.

The names of the files you create form part of the URLs used on ADP.

Once you are done with making the necessary updates in the file you can go ahead and add your changes:

```bash
git add -p
```

Commit the changes in your branch. Include a commit message adequately describing the update(s):

```bash
git commit -m “Add a commit message”
```

Push your branch in order to raise a pull request:

```bash
git push origin your-branch-name
```

Create a pull request in GitHub:

1. In the `nexmo-developer` repository, click the Pull requests tab.
2. Click the Compare and new pull request button next to your branch in the list.
3. Review the changes between your branch and master.
4. Add a Description of the changes.
5. Click the Create pull request button.

## License

This library is released under the [MIT License][license]

[signup]: https://dashboard.nexmo.com/sign-up?utm_source=DEV_REL&utm_medium=github&utm_campaign=nexmo-developer
[license]: LICENSE.txt
