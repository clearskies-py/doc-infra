---
layout: default
title: Handlers
has_children: true
permalink: /docs/handlers
nav_order: 4
---

# Handlers

Handlers are the basic unit of work in clearskies.  Each handler executes a particular "kind" of pre-defined functionality: call a function, perform routing, implement a RESTful API, expose a health check, migrate a database, etc...  In essence, these are the building blocks of applications in clearskies and can be mixed and matched as needed.  To make use of handlers you specifcy the class of the one which you want clearskies to execute, as well as it's configuration - all handlers accept some configuration options to control their behavior.  Handlers can be packaged up in applications to create code which is ready to execute, as well as being attached directly to a context (as we have done thus far in our examples).

The simplest handler is the `Callable` handler, which simply executes a function.  We've already been using this in our examples thus far:

{% highlight python %}
#!/usr/bin/env python
import clearskies

def my_function(utcnow):
    return utcnow.isoformat()

my_cli_application = clearskies.contexts.cli(my_function)
my_cli_application()
{% endhighlight %}

When you attach a function to a context, you are implicitly using the `Callable` handler.  As such, the above code is short-hand for this:

{% highlight python %}
#!/usr/bin/env python
import clearskies

def my_function(utcnow):
    return utcnow.isoformat()

my_cli_application = clearskies.contexts.cli({
    'handler_class': clearskies.handlers.Callable,
    'handler_config': {
        'callable': my_function,
    }
})
my_cli_application()
{% endhighlight %}

Each handler class has its own configuration options that you can use to control its behavior.  For instance, with the callable handler, you can tell it not to wrap your response in the standard clearskies return structure:

{% highlight python %}
#!/usr/bin/env python
import clearskies

def my_function(utcnow):
    return utcnow.isoformat()

my_cli_application = clearskies.contexts.cli({
    'handler_class': clearskies.handlers.Callable,
    'handler_config': {
        'callable': my_function,
        'return_raw_response': True,
    }
})
my_cli_application()
{% endhighlight %}

If you execute this it will return something like:

```
2023-02-06T12:01:52.520465+00:00
```

Rather than the usual:

```
{"status": "success", "error": "", "data": "2023-02-06T12:01:52.520465+00:00", "pagination": {}, "input_errors": {}}
```
