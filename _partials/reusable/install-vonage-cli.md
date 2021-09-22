## Install latest version of Vonage Command Line Interface (CLI)

The [Vonage CLI](https://developer.nexmo.com/application/vonage-cli) allows you to carry out many operations on the command line. Examples include creating applications, purchasing numbers, and linking a number to an application.

To install the CLI with NPM run:

```bash
npm install -g @vonage/cli
```

Set up the Vonage CLI to use your Vonage API Key and API Secret. You can get these from the [settings page](https://dashboard.nexmo.com/settings) in the Dashboard.

Run the following command in a terminal, while replacing `API_KEY` and `API_SECRET` with your own:

```bash
vonage config:set --apiKey=API_KEY --apiSecret=API_SECRET
```