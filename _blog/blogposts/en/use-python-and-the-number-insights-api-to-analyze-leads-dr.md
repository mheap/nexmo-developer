---
title: Use Python and The Number Insights API to Analyze Leads
description: The Vonage Number Insights API can be used to more effectively
  reach potential leads. See how a basic Python script can power your analysis.
thumbnail: /content/blog/use-python-and-the-number-insights-api-to-analyze-leads-dr/Blog_Number-Insights-API_1200x600.png
author: solomon-soh
published: true
published_at: 2020-09-17T12:30:55.000Z
updated_at: 2021-05-10T22:27:25.103Z
category: tutorial
tags:
  - number-insights
  - python
comments: true
spotlight: true
redirect: ""
canonical: ""
---
Cold calling is a very expensive activity when you take into account the time and energy needed to reach out to an unknown prospect. David Cummings, a renowned entrepreneur, estimates that it takes [$1.72 per cold call](https://davidcummings.org/2015/09/23/how-much-does-a-single-cold-call-cost/), without any guarantee of conversion. Must customer acquisition be so costly? With the [Vonage Number Insights API](https://developer.nexmo.com/number-insight/overview), it's possible to make big improvements on these costs.

<sign-up></sign-up>

## Use Number Insights

Imagine a use case of prospecting investors in the blockchain community. A sales executive pulled telephone details from the CoinMarketCap crypto-community and the five other biggest crypto-currency exchanges: Binance, Poloniex, Huobi, ProBit and Bybit.

![numbers by exchange](/content/blog/use-python-and-the-number-insights-api-to-analyze-leads/image3-1.png)

Afterwards, API calls could be made to the Vonage Number Insights API to obtain in-depth customer data from the phone number. This Python script shows how the API calls are handled and how the resulting data can be structured for further analysis:

```
import nexmo
client = nexmo.Client(key=####, secret=####)

def get_data(data):
main_dict = {}
  
for i in range(len(data)):
    num = str(data["phone"][i])
    
    insight_json = client.get_advanced_number_insight(number=num, cnam=True)
    
    sub_dict = {}

    #General Data
    sub_dict["valid_number"] = insight_json["valid_number"]
    sub_dict["reachable"] = insight_json["reachable"]
    sub_dict["ported"] = insight_json["ported"]
    sub_dict["national_format_number"] = insight_json["national_format_number"]
    sub_dict["international_format_number"] = insight_json["international_format_number"]
    try:
        sub_dict["current_carrier_name"] = insight_json["current_carrier"]["name"]
        sub_dict["current_carrier_network_type"] = insight_json["current_carrier"]["network_type"]
    except:
        sub_dict["current_carrier_name"] = insight_json["original_carrier"]["name"]
        sub_dict["current_carrier_network_type"] = insight_json["original_carrier"]["network_type"]
    sub_dict["country_name"] = insight_json["country_name"]
    sub_dict["country_code_iso3"] = insight_json["country_code_iso3"]
    sub_dict["roaming"] = insight_json["roaming"]["status"]

    if insight_json["country_name"] == "United States of America":
        sub_dict["caller_name"] = insight_json["caller_identity"]["caller_name"]
        sub_dict["caller_type"] = insight_json["caller_identity"]["caller_type"]
        sub_dict["first_name"] = insight_json["caller_identity"]["first_name"]
        sub_dict["last_name"] = insight_json["caller_identity"]["last_name"]
        sub_dict["subscription_type"] = insight_json["caller_identity"]["subscription_type"]

    if insight_json["roaming"]["status"] == "roaming":
        sub_dict["roaming_country_code"] = insight_json["roaming"]["roaming_country_code"]
        sub_dict["roaming_network_name"] = insight_json["roaming"]["roaming_network_name"]
        
    main_dict[num] = sub_dict
return  main_dict
```

## Improve Efficiency

The Number Insights API promises enormous cost-savings for the campaign because it reduces the time and effort wasted on invalid and unreachable numbers. For example, in using our sample case study, 30% of phone numbers have been confirmed to be valid and unreachable. This means that 854 (70%) calls could be avoided, saving at least $1,500—a whopping 4,050% ROI. 

> Where did we get those numbers? 70% is 854 numbers  *$1.72 per call = $1,469. There are 1228 numbers in total and this equals to $37 = 1228*  $0.03 per API calls. $1,500/$37 * 100 = 4,050%   

Data cleaning is essential because it increases the efficiency and accuracy of the campaign team so they can reach out to the right audience promptly.

This script can be used to find the numbers that are valid and present the results in a bar chart:

```
valid_source_pct = net_data[~net_data["reachable"].str.contains("unknown")]
valid_source_pct = (valid_source_pct.dropna(subset=["reachable"]).groupby(['group','reachable'])['username'].count()/valid_source_pct.dropna(subset=["reachable"]).groupby(['group'])['username'].count())
valid_source_pct.unstack().plot.bar(stacked=True)
plt.legend(loc='center left', bbox_to_anchor=(1.0, 0.5))
```

![reachable numbers](/content/blog/use-python-and-the-number-insights-api-to-analyze-leads/image4-1.png)

It's also important to understand that quantity never indicates the quality of leads. As shown earlier, Binance provided the most phone records, but it also has the highest proportion of undeliverable numbers. Compared to Binance, Poloniex seems to be a better lead generator given its balance of high quantity and quality.

## Target by Country

The Number Insights API can also be used to gather critical information about the best channel to reach investors. For example, this script can be used to aggregate and plot the numbers by country:

```
countries = net_data.groupby("country_name").agg({"username":"count"}).sort_values("username", ascending=False).reset_index()

plt.figure(figsize=(16,8))
# plot chart
ax1 = plt.subplot(121, aspect='equal')

countries.head(10).plot(kind='pie', y = 'username', ax=ax1, autopct='%1.1f%%',
                  startangle=90, shadow=True, labels=countries["country_name"], legend = False, fontsize=12, rotatelabels=True, pctdistance=0.85)
```

We observe that out of 91 countries with valid and reachable numbers, three countries constitute more than 70% of the records (Figure 1). Hence, the campaign should target numbers in the top 10 countries as a starting point rather than randomly calling 91 investors from 91 countries. This would further save time and customize the marketing message to reach out to the top prospects.

![numbers by country](/content/blog/use-python-and-the-number-insights-api-to-analyze-leads/image1-1.png)

To make life even easier, we could understand which telecommunication carriers in each country are serving these potential investors. We could tie up promotions or easier access to these investors through these network carriers:

![numbers by provider](/content/blog/use-python-and-the-number-insights-api-to-analyze-leads/image2-1.png)

The [Vonage Number Insights API](https://developer.nexmo.com/number-insight/overview) gives you a chance to better understand your leads, your customers, and the market. Whether you want to study the frequency at which mobile consumers change their numbers or get a ground-up reality check on the competitiveness of the telecom market, this API quickly gives you the information you need to make better decisions to help you save time and money.