---
layout: default
title: Context Neutral
parent: Overview
nav_order: 3
---

# Context Neutral

Executing code in clearskies starts with an "application": a combination of code and configuration that can be run anywhere. In order to run an application, you attach it to the appropriate "context": WSGI server, Lambda, Queue listener, CLI, test environment, etc... The same code can run in your production environment, on a dev machine, or in your test suite without making any changes.

Consider a simple hello world application:

{% highlight python %}
import clearskies

def hello_world():
    return 'Hello world!'
{% endhighlight %}

The following code would allow it to run in a WSGI server:

{% highlight python %}
api = clearskies.contexts.wsgi(hello_word)
def application(env, start_response):
    return api(env, start_response)
{% endhighlight %}

While a slight tweak would allow it to run in a Lambda behind an API gateway:

{% highlight python %}
import clearskies_aws

api = clearskies_aws.contexts.lambda_api_gateway(hello_word)
def application(event, context):
    return api(event, context)
{% endhighlight %}

Or from the command line:

{% highlight python %}
cli = clearskies.contexts.cli(hello_word)
cli()
{% endhighlight %}
