---
title: Introduction to GPT-3
description: OpenAI has released GPT-3 into the world and looks to be one of the
  best generative pre-trained transformers out there. Find out more about it!
thumbnail: /content/blog/introduction-to-gpt-3/Blog_OpenAI_GPT-3_1200x600.png
author: tony-hung
published: true
published_at: 2020-10-05T13:21:52.000Z
updated_at: 2021-05-10T21:47:30.311Z
category: tutorial
tags:
  - machine-learning
comments: true
redirect: ""
canonical: ""
---
If you haven't noticed, AI is everywhere, and we've finally come to a point where it is in almost everything we interact with. From Amazon product recommendations to Netflix suggestions to autonomous driving, and writing excellent blog posts... Don't worry, this post was written by a human, for now.

Many people see how AI is used, but have you ever wondered how it comes to be?

This post will look at a very popular model used for many tasks, including generating news articles, image generation, and even building HTML sites.

## Introduction to AI

First, let's go through a basic summary of AI: It's a series of algorithms that can learn a specific task and make predictions on similar tasks. One of these tasks could predict if an image contains a picture of a cat or a dog.

In this example, we gather lots of these images and feed them into an algorithm. We then label each image, as in "This is a photo of a dog" or "This is a cat photo". The algorithm "learns" which images contain a dog or cat. The model makes assumptions of what constitutes a dog (big ears, fluffy tail) and a cat (whiskers, eye shape) and can learn these differences.

We give our model hundreds of images known as "training," with these, the model forms a good idea of what a dog and cat look like. Finally, we will give a model a new image, and it should be able to tell us if this is an image of a dog or cat.

If you are interested in learning how to build a model to identify dogs, please look at this [post](https://www.nexmo.com/blog/2018/12/04/dog-breed-detector-using-machine-learning-dr).

The idea of training a model with examples (images of cats and dogs) and being able to make predictions on new images is [Deep Learning](https://en.wikipedia.org/wiki/Deep_learning), which is a subset of AI.

We won't be going over how to train a model for this post, but we will go over a very popular model that can do more interesting things.

In June 2020, a company called OpenAI (founded by Elon Musk), released a new model called [GPT-3](https://openai.com/blog/openai-api/), which is capable of generating new content, given a small number of examples of input data.

Examples of how you could use this include:

* Question and Answering
* Summarizing sentences
* Translation
* Text Generation
* Image Generation
* Performing three-digit arithmetic 
* Unscrambling words

## About GPT-3

GPT-3 is a deep learning language model, meaning that this model is trained on thousands of articles from Wikipedia, web sites, and books.

When a model is trained, its output is a series of parameters, commonly a multidimensional array of numbers. These numbers represent what the model has learned.

GPT-3 contains 175 billion parameters. For perspective, Microsoft also came out with a language model that uses only 10 billion parameters.

For a model to learn from the given data, it needs to be trained. This training is done by feeding the model each word of a given text and then predicting the next word.

This training is computationally expensive and requires many [GPUs](https://towardsdatascience.com/what-is-a-gpu-and-do-you-need-one-in-deep-learning-718b9597aa0d) to train. According to one estimate, [training of the GPT-3 model costs $4.6 million](hhttps://bdtechtalks.com/2020/08/17/openai-gpt-3-commercial-ai/).

## How Does GPT-3 Work

GPT-3 is known as a (G)enerative (P)re-trained (T)ransformer. By being generative, it means that it can generate new text, given an input of text. 

For example, if we give the model the following text:

"The sky is"

The model should be able to predict that the next word is "blue".

If I give it another sentence: 

"The quick brown fox"

The model would first make a prediction "jumped," then using the previous sentence ("The quick brown fox jumped"), it should predict the word "over," and so on.

Another part of the GPT-3 is the transformer. The [transformer](https://ai.googleblog.com/2017/08/transformer-novel-neural-network.html) is an architecture, developed by Google, that allows a model to remember or give higher weight to a phrase or set of phrases in a given sentence that has the most importance.

Language models are built using a [Recurrent Neural Network](https://en.wikipedia.org/wiki/Recurrent_neural_network). This neural network architecture takes a sentence, word by word, and feeds into the network. What makes it recurrent, is that the output from the previous word is an input to the next word in the sentence. 

![Recurrent neural network](/content/blog/introduction-to-gpt-3/recurrent-neural-network.png)

These models can only deal with numbers. Therefore, the text needs to be converted into a number. One way of converting text into a number is through [word embeddings](https://machinelearningmastery.com/what-are-word-embeddings/).

A word embedding turns words into a 3d vector space that can capture the meaning of a word using its relation to other words. An excellent example of a word embedding is a way to understand the similarities between the words "brother" and "sister" as compared to "man" and "women".

![](/content/blog/introduction-to-gpt-3/word2viz-queen.png)

In the above image, we can see that the word "brother" resides in the same physical space as the word "man". This embedding was also learned by a model to read lots of text and come up with these similarities.

This word embedding is fed into the next word embedding, allowing the model to "remember" the previous words using its embedding.

One of the big problems is that RNNs are generally not good at remembering long sentences.

Let us take this sentence:

"Tony Hung is a software Engineer at Vonage. He likes to write about Artificial Intelligence over on the Vonage blog. He lives in upstate New York, with his wife, 4-year-old daughter, and dog."

AN RNN would take each word ("Tony", "Hung", "is"), and feed into the network as a word embedding. Over time the model may forget the word "Tony" since it was the first word in the sentence. If I ask the model the following question, "Who works for Vonage", it would need to go back in the sentence, find the word "Vonage", and try to find the noun associated with the question. Since the word "Tony" is so far in the past, the RNN may not be able to find it.

The Transformer architecture helps solves this problem, which was proposed in the paper [Attention is All You Need](https://arxiv.org/abs/1706.03762) and uses a concept called Attention.

Attention is part of a neural network layer that can focus on specific parts of the sentence. As we stated before, an RNN model can capture every word in the sentence, but if the embedding is too large, the model may not remember everything.

With Attention, each embedding also now contains a score on how important the specific word is. So now, the RNN does not have to remember every word embedding, but rather, just the word embeddings with a higher score than the other word embeddings.

For a more detailed description of the transformer and Attention, check out [Jay Alammar's visual transformer blog post](https://jalammar.github.io/illustrated-transformer/).

# GPT-3 Samples

Still with me? Great! Let's get into some examples of how GPT-3 is used.

With access to the OpenAI API, you can supply training data, which contains a sample input and what the output should be. You might be saying, "This is great, how can I get started and use it?", OpenAI has not made the model publicly available, but only as an API which is in closed beta access, which means you would have to request access to use the API. At the time of this writing, I have not been accepted yet to the beta.

The good news is that many people have and can [give a detailed explanation of how the API works](https://towardsdatascience.com/gpt-3-creative-potential-of-nlp-d5ccae16c1ab).

Let's go through some of the examples of other developers using GTP-3.

## Text To HTML Using GTP-3

One of many usages of GPT-3 is to generate HTML from a given string. 
The input into the OpenAI API would consist of a string, as well as its HTML equivalent.

Input: bold the following text. "GPT-3"

We would supply the output of:
`<b>GPT-3</b>`

The OpenAI API allows a developer to supply these input and output texts to GPT-3. Then, on the OpenAI servers, the API will send this input and output to GPT-3 to "learn" the supplied input and what the output should be.

Then, if we supply a new series of text to the OpenAI API:

"Center and bold the word GPT-3".

Its output will be
`<center><b>GPT-3</b></center>`

We did not tell GPT-3 anything about the `<center>` tag since GPT-3 most likely contained HTML strings during its training process.

Here is an example of what this looks like:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">This is mind blowing.<br><br>With GPT-3, I built a layout generator where you just describe any layout you want, and it generates the JSX code for you.<br><br>W H A T <a href="https://t.co/w8JkrZO4lk">pic.twitter.com/w8JkrZO4lk</a></p>&mdash; Sharif Shameem (@sharifshameem) <a href="https://twitter.com/sharifshameem/status/1282676454690451457?ref_src=twsrc%5Etfw">July 13, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## Text Adventure

Other examples of developers using GPT-3 is a text adventure game from [aidungeon.io](https://aidungeon.io)

![AI Dungeo](/content/blog/introduction-to-gpt-3/aidungeon.png "AI Dungeo")

AI dungeon generates a story in which you can navigate using text — also known as [multi-user dungeon](https://en.wikipedia.org/wiki/MUD). In this example, entering the words "Look Around" will generate a new set of text about the scenery. This feature is only using GPT-3 to generate text after each input.

## Text to Regex

This example is the one that got me. By supplying a set of text input and its regex equivalent, you can generate valid regular expressions using readable English.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">I once had a problem and used regex. Then I had two problems<br><br>Never again. With the help of our GPT-3 overlords, I made something to turn English into regex. It&#39;s worked decently for most descriptions I&#39;ve thrown at it. Sign up at <a href="https://t.co/HtTpJ16V4F">https://t.co/HtTpJ16V4F</a> to play with a prototype <a href="https://t.co/trJA7VRrsf">pic.twitter.com/trJA7VRrsf</a></p>&mdash; Parthi Loganathan (@parthi_logan) <a href="https://twitter.com/parthi_logan/status/1286818567631982593?ref_src=twsrc%5Etfw">July 25, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

More examples of developers using GPT-3 to build exciting things can be found at [buildgpt3.com](http://www.buildgpt3.com/).

# Conclusion

Through this post, we've been able to go through a basic understanding of what GPT-3 is and how it is built. However, we didn't dive in too much on this and other AI models' technical aspects. To get a deep dive into GPT-3, look at [Jay Alammar's Video on How GPT-3 Works](https://www.youtube.com/watch?v=MQnJZuBGmSQ). It is a great starting point on how AI models can be trained.

 If you are new to the technical aspects of AI, which includes Deep Learning, please look at [Fast.ai](https://fast.ai), a free course that goes over what deep learning is and how to get started.

I hope this post has helped you understand what GPT-3 is, from both a technical and non-technical standpoint. If you are interested in learning more about GPT-3 and what other projects OpenAI is doing, please check them out at [OpenAI.com](https://openai.com/).