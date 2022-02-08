---
title: "WhatsApp Analytics: Spatial Mapping of Users of WhatsApp Groups "
description: Learn how to generate and plot analytics based on the participants
  of a WhatsApp Group.
thumbnail: /content/blog/whatsapp-analytics-spatial-mapping-of-users-of-whatsapp-groups/whatsapp-analytics_1200x600.png
author: aboze-brain-john
published: true
published_at: 2021-04-06T12:44:47.035Z
updated_at: 2021-03-29T09:56:51.382Z
category: tutorial
tags:
  - python
  - selenium
  - number-insight
comments: true
spotlight: true
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
WhatsApp groups have served as an environment to establish collective conversations with others around the world.  

In this tutorial, we'll generate and plot analytics based on the participants of a WhatsApp Group. We'll geocode the users' location and generate a country-level distribution. This interface will be built with Python using Selenium, Plotly, Vonage Number Insight API, Google Maps API, and Mapbox API.

<sign-up></sign-up>

## Prerequisites

To follow and fully understand this tutorial, you'll also need to have:

* [Python 3.6](https://www.python.org/) or newer.
* Basic knowledge of automation with [Selenium](https://selenium-python.readthedocs.io/index.html).
* Set up [Google Maps API](https://developers.google.com/maps/documentation).
* Set up [Plotly](https://plotly.com/) and [Mapbox](https://www.mapbox.com/) credentials.

Below are the results of the final interface you’ll build:

![Spatial mapping of WhatsApp Group Contacts](/content/blog/whatsapp-analytics-spatial-mapping-of-users-of-whatsapp-groups/overview-1.gif "Spatial mapping of WhatsApp Group Contacts")

![Distribution of WhatsApp Group Contacts](/content/blog/whatsapp-analytics-spatial-mapping-of-users-of-whatsapp-groups/overview-2.gif "Distribution of WhatsApp Group Contacts")

## File Structure

See an overview of the file directory for this project below:

```
├── README.md
├── analytics.py
├── automate.py
├── chromedriver
├── env
├── geocoding.py
├── main.py
└── plotting.py
```

The content of all files listed in the directory tree above will be created through this tutorial's subsequent steps.

## Set up a Python Virtual Environment

You'll need an isolated environment for the python dependencies management unique to this project.

First, create a new development folder. In your terminal, run:

```
$ mkdir whatsapp-spatial-mapping
```

Next, create a new Python virtual environment. If you are using Anaconda, you can run the following command:

```
$ conda create -n env python=3.6
```

Then you can activate the environment using:

```
$ conda activate env
```

If you are using a standard distribution of Python, create a new virtual environment by running the command below:

```
$ python -m venv env
```

To activate the new environment on a Mac or Linux computer, run:

```
$ source env/bin/activate
```

If you are using a Windows computer, activate the environment as follows:

```
$ venv\Scripts\activate
```

Regardless of the method you used to create and activate the virtual environment, your prompt should look like the following:

```
(whatsapp-spatial-mapping) $
```

### Requirement file

Next with the virtual environment active, install the project dependencies and their specific versions as outlined shown below:

```
chart-studio==1.1.0
googlemaps==4.4.2
vonage==2.5.5
numpy==1.19.4
pandas==1.2.0
plotly==4.14.1
plotly-express==0.4.1
python-decouple==3.3
selenium==3.141.0
```

These packages with the specific versions can be installed via the requirement file from your terminal:`$ pip install -r requirements.txt` or `conda install --file requirements.txt` (if you are on Anaconda) and voila! All of the program’s dependencies will be downloaded, installed, and ready to be used. 

Optionally, you can install all the packages as follows:

* Using Pip:

  ```
    pip install chart-studio googlemaps nexmo numpy pandas plotly plotly-express python-decouple selenium
  ```
* Using Conda:

  ```
    conda install -c conda-forge chart-studio googlemaps nexmo numpy pandas plotly plotly-express python-decouple selenium
  ```

## Setting up APIs and Credentials

Next, you'll need to set up some accounts and get the required API credentials. 

### Google Maps API

The Google Maps API will enable the geocoding function, which is crucial to this project. The API is readily available on [Google Cloud Console](https://console.cloud.google.com/).\
First, you need to set up a [Google Cloud free tier account](https://cloud.google.com/free), where you get $300 free credits to explore the Google Cloud Platform and products.  Next, with your Google Cloud Console all set up, you need to [create an API key](https://developers.google.com/maps/documentation/javascript/get-api-key) to connect the [Google Maps Platform](https://cloud.google.com/maps-platform) to the application.\
Finally, [activate the Google Maps Geocoding API](https://console.cloud.google.com/apis/library/geocoding-backend.googleapis.com?filter=category:maps&id=42fea2de-420b-4bd7-bd89-225be3b8b7b0&project=maps-article-review) to enable it for the project.

### Plotly API and Mapbox Credentials

To create beautiful data visualizations, [Plotly](https://plotly.com/) on Python will be utilized, and the aesthetics enhanced using  [Mapbox](https://www.mapbox.com/).  

The Plotly plots are hosted online on Chart Studio (part of Plotly Enterprise); you need to [sign up](https://chart-studio.plotly.com/Auth/login/#/), generate and save your custom [Plotly API key](https://plotly.com/python/getting-started-with-chart-studio/).  

To achieve the desired plot enhancement, you also need to sign up for [Mapbox](https://account.mapbox.com/auth/signup/) and create a [Mapbox authorization token](https://docs.mapbox.com/help/tutorials/get-started-tokens-api/).

## Separation of Settings Parameters and Source Code

In the previous section, you've generated various API credentials.\
It is best practice to store these credentials as environment variables instead of having them in your source code. 

An environment file can easily be set up by creating a new file and naming it `.env`, or via the terminal as follow:

```
(whatsapp-spatial-mapping) $ touch .env   # create a new .env file
(whatsapp-spatial-mapping) $ nano .env    # open the .env file 
```

The environment file consists of key-value pair variables. For example:

```
   user=Brain
   secret=xxxxxxxxxxxxxxxxxxxxxxxxxx
```

You can access these environment variables in the source code using the [Python Decouple](https://pypi.org/project/python-decouple/) built-in module.

> It's also good practice to add the `.env` file to the [gitignore](https://git-scm.com/docs/gitignore) file. Doing so prevents sensitive information such as API credentials to become public.

The scripts follow the Object-Oriented Programming paradigm. The following are high-level explanations for each script.

### automate.py

The first step to this project workflow is WhatsApp automation using [Selenium](https://selenium-python.readthedocs.io/).\
Selenium is an open-source web-based automation tool that requires a driver to control the browser. Different drivers exist due to various browser configurations; some of the popular browsers' drivers are listed below:

* [Chrome](https://sites.google.com/a/chromium.org/chromedriver/downloads).
* [Firefox](https://github.com/mozilla/geckodriver/releases).
* [Safari](https://webkit.org/blog/6900/webdriver-support-in-safari-10/).
* [Edge](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/).

> This tutorial uses the Chrome driver. To make it quick and easy to access, move the downloaded driver file to the same directory as the script utilizing it. See the file structure above.

This script comprises a `WhatsappAutomation` class that loads the web driver via its path, maximizes the browser window, and loads the Whatsapp Web application. The 30 seconds delay initiated is to provide the time to scan the QR code to access your Whatsapp account on the web.

Upon scanning your QR code with your phone, your Whatsapp account opens on the web. 

The  `WhatsappAutomation` class has two classes

* `get_contacts()`
* `quit()`

> The browser will notify you that "*Chrome is being controlled by automated test software*" to indicate that Selenium will have been activated for automation in the browser.

![WhatsApp in Browser](/content/blog/whatsapp-analytics-spatial-mapping-of-users-of-whatsapp-groups/whatsapp_qr.png "WhatsApp in Browser")

Next, you need to access the desired group and contacts, as shown below.

![Message in WhatsApp Group](/content/blog/whatsapp-analytics-spatial-mapping-of-users-of-whatsapp-groups/whatsapp_group.png "Message in WhatsApp Group")

The automation step involves locating the WhatsApp web page element that contains the phone numbers as seen in the image above. There are numerous ways to select these elements, as highlighted in the [Selenium documentation](https://selenium-python.readthedocs.io/locating-elements.html). For this project, use `xpath`.

> To access these element selectors, you need to inspect the Whatsapp web page.

Next, the contact entries obtained via the Xpath need to be cleaned up and saved as a CSV file. You'll use [regular expressions](https://github.com/AISaturdaysLagos/Cohort3/blob/master/Beginner/Week3/Notebook/regular-expressions.ipynb) to remove the '+' character and any whitespaces from the phone numbers.\
To promote efficient memory management, quit the selenium-powered browser upon completion of a session.

```
import time
import re
import csv
from selenium import webdriver


class WhatsappAutomation:
    def __init__(self):
        self.chrome_browser = webdriver.Chrome('./chromedriver')
        self.chrome_browser.maximize_window()
        self.chrome_browser.get('https://web.whatsapp.com/')
        time.sleep(30)

    def get_contacts(self, whatsapp_group_xpath, contact_element_xpath):
        group = self.chrome_browser.find_element_by_xpath(whatsapp_group_xpath)
        group.click()
        time.sleep(10)
        contacts = self.chrome_browser.find_elements_by_xpath(
            contact_element_xpath)
        # The find elements returns a list object
        contacts = contacts[0].get_attribute('textContent')
        # You have to remove white spaces in the numbers
        contacts = re.sub(r"\s+", "", contacts)
        # You have to remove symbols such as '()-'
        contacts = re.sub(r"[()+-]", "", contacts)
        # Your number is shown as 'You' on WhatsApp, so you need to remove that as well
        contacts = contacts.replace(",You", "")

        # convert the string to list
        contact_list = contacts.split(',')
        # writing the contacts (list) to a csv file
        f = open('contact_data.csv', 'w')
        w = csv.writer(f, delimiter=',')
        # create header
        w.writerow(['contact'])
        # split the comma separated string values into a CSV file
        w.writerows([x.split(',') for x in contact_list])
        f.close()
        return contact_list

    def quit(self):
        print('Quiting session in 10 seconds...')
        time.sleep(10)
        self.chrome_browser.quit()
```

### analytics.py

Next, you'll use the [Vonage Number Insights API](https://developer.nexmo.com/number-insight/overview) to generate insights from the saved CSV file. This API provides information about the validity, reachability and roaming status of a phone number.

The script is made up of a `WhatsappAnalytics` class that first loads the Vonage credentials stored in the `.env` file using the Python `decouple` module. Next, it has a `get_insight()` method that takes the contact list and initiates an Advanced Number Insight to get the countries associated with the phone numbers. Finally, the list of countries is saved as a CSV file.

```
from decouple import config
import json
import csv
import nexmo
import pandas as pd


class WhatsappAnalytics:
    def __init__(self):
        # Setting up Nexmo credentials
        self.key = config('client_key')
        self.secret = config('client_secret')
        self.client = nexmo.Client(key=self.key, secret=self.secret)

    def get_insights(self, contact_list):
        print('Getting number insights')
        data = []
        for contact in contact_list:
            insight_json = self.client.get_advanced_number_insight(
                number=contact).get('country_name')
            data.append(insight_json)

        # convert the list
        f = open('country_data.csv', 'w')
        w = csv.writer(f, delimiter=',')
        # create header
        w.writerow(['country'])
        # split the comma separated string values into a CSV file
        w.writerows([x.split(',') for x in data])
        f.close()
        print('Number insights generated successfully')

        dataframe = pd.read_csv('country_data.csv')
        return dataframe
```

### geocoding.py

Next, the string description of the various locations (country names) will be geocoded to create the respective geographic coordinates (latitude/longitude pairs). 

This script is made of a `GoogleGeocoding` class that first loads the Google Maps API keys. This class has a `geocode_df` method with a `dataframe` argument—the phone numbers and countries previously saved. This method also aggregates the dataframe by countries and returns the respective latitude and longitude pairs. 

```
from decouple import config
import pandas as pd 
import googlemaps 

class GoogleGeocoding:
    def __init__(self):
        self.key = config('api_key')
        self.gmaps = googlemaps.Client(key=self.key)

    def geocode_df(self, dataframe):
        print('Preparing for geocoding country code...')
        df = dataframe
        df = df.value_counts().rename_axis('country').reset_index(name='counts')
        for index in df.index:
            df.loc[index, 'longitude'] = (self.gmaps.geocode(df['country'][index]))[0].get('geometry').get('location').get('lng')
            df.loc[index, 'latitude'] = (self.gmaps.geocode(df['country'][index]))[0].get('geometry').get('location').get('lat')
        df.to_csv('geocode_data.csv', index=False)
        print('Geocoding completed')
        return df
```

### plotting.py

Next, you will need to map the geospatial data created (latitude and longitude pairs).\
Mapmaking is an art; to make the project results aesthetically pleasing, use the Plotly library and Mapbox maps. 

This script comprises the `SpatialMapping` class that loads the Mapbox token and chart_studio credentials. This class has two methods, `plot_map` and `plot_bar`, that plot the distribution of the Whatsapp group's users as a map and a bar chart.

```
from decouple import config
import plotly.express as px
import chart_studio
from chart_studio import plotly as py

# Setting credentials
px.set_mapbox_access_token(config('mapbox_public_token'))
cs_username = config('chart_studio_username')
cs_api = config('chart_studio_api')
chart_studio.tools.set_credentials_file(username=cs_username,
                                        api_key=cs_api)


class SpatialMapping:

    def plot_map(self, dataframe):
        fig = px.scatter_mapbox(
            dataframe, lat="latitude", lon="longitude",
            color="counts",
            size="counts",
            color_continuous_scale=px.colors.sequential.Greens,
            size_max=20,
            zoom=1,
            hover_data=["country", 'counts'],
            hover_name='country')

        fig.update_layout(
            title='WhatsApp Analytics: Spatial Mapping of WhatsApp group contacts',
            mapbox_style="dark")

        fig.show()

        print('The link to the plot can be found here: ', py.plot(
            fig, filename='Whatsapp Analytics Map', auto_open=True))

    def plot_bar(self, dataframe):
        fig = px.bar(
            dataframe, x='country', y='counts',
            hover_data=["country", 'counts'],
            color_discrete_sequence=['darkgreen'])

        fig.update_layout(
            title='WhatsApp Analytics: Distribution of WhatsApp group contacts')
        fig.show()
```

### main.py

main.py is the point of execution of the program. Here, all the script classes and imported, and the various required parameters are inputted in the `main()` function.

```
from automate import WhatsappAutomation
from analytics import WhatsappAnalytics
from geocoding import GoogleGeocoding
from plotting import SpatialMapping

def main():
    if __name__ == '__main__':

        automated_object = WhatsappAutomation()
        group_xpath = '//*[@id="pane-side"]/div[1]/div/div'
        contact_xpath = '//*[@id="main"]/header/div[2]/div[2]/span'
        contact_list = automated_object.get_contacts(group_xpath, contact_xpath)
        automated_object.quit()

        analytics_object = WhatsappAnalytics()
        analytics_df = analytics_object.get_insights(contact_list)

        geocoding_object = GoogleGeocoding()
        geo_df = geocoding_object.geocode_df(analytics_df)

        spatial_mapping_object = SpatialMapping()
        spatial_mapping_object.plot_map(geo_df)
        spatial_mapping_object.plot_bar(geo_df)

main()
```

## Try it out

In your terminal, run the main script file as follows:

```
$ python3 main.py
```

This will import the various scripts and execute the `main()` function to yield the desired results.

## Results

![Spatial mapping of WhatsApp Group Contacts](/content/blog/whatsapp-analytics-spatial-mapping-of-users-of-whatsapp-groups/overview-1.gif "Spatial mapping of WhatsApp Group Contacts")

![Distribution of WhatsApp Group Contacts](/content/blog/whatsapp-analytics-spatial-mapping-of-users-of-whatsapp-groups/overview-2.gif "Distribution of WhatsApp Group Contacts")

I’m sure you can already think of all the possibilities and use cases for this new piece of knowledge. The possibilities are endless.

Thanks for taking the time to read this article!

Happy Learning!

## References

[Vonage Number Insight API](https://developer.vonage.com/number-insight/code-snippets/number-insight-standard/python)