---
layout: default
title: Callable
parent: Handlers
permalink: /docs/handlers/callable.html
nav_order: 3
---

# Callable Handler

 1. [Overview](#overview)
 2. [Configuration](#configuration)

## Overview

The callable handler is the most basic handler, and all it does is invoke a function.  You may request any dependencies that exist in your application, and you may also request any of the additional call-specific dependencies:

| Name | Value |
|------|-------|
| `input_output` | An instance of `clearskies.input_output.InputOutput` - used to check the request and modify the response |
| `request_data` | The data in the request, if present |
| [Routing Data](#simple-routing.html) | Any routing data present.  The injection name varies - see the [simple router](simple-routing.html) for more information |

## Configuration

| Name | Type | Description |
|------|------|-------------|
| [callable](#callable) | `Callable` | The callable to execute - a function, lambda, or object with a `__call__` attribute. |
| [return_raw_response](#return-raw-response) | `bool` | If `True`, the return value of the callable will returned exactly to the client.  If not, it will be set as the `data` property of a standard clearskies response |
| [schema](#schema) | List of columns OR Model class OR Model | A schema to use to validate user input |
| [writeable_columns](#writeable-columns) | `List[str]` | A list of column names (from the schema) that the user is allowed to set |
| [doc_model_name](#doc-model-name) | `str` | The name to assign to the response type for use in the autodocumentation of the handler |
| [doc_response_data_schema](#doc-response-data-schema) | `List[clearskies.autodoc.schema.base]` | The documentation of the response for the handler for use in the autodocs |

### Callable

The callable to execute.  That's... really all there is to it.  Since the callable is the default handler, it's possible to attach it directly to a context without having to specify a handler class or handler config:

{% highlight python %}
#!/usr/bin/env python
import clearskies

def example_callable(test_binding):
    return f'Hello {test_binding}'

callable_demo = clearskies.contexts.cli(
    example_callable,
    bindings={
        'test_binding': 'world',
    }
)
callable_demo()
{% endhighlight %}

The above example can be [executed via the CLI](/docs/running-examples.html#running-examples-designed-for-the-cli).  Of course, the CLI handler works just as well in a web context.  However, a web context requires you to specify the authenticaton method, so you have to explicitly provide the handler and configuration:

{% highlight python %}
import clearskies

def example_callable(test_binding):
    return f'Hello {test_binding}'

callable_demo = clearskies.contexts.wsgi(
    {
        'handler_class': clearskies.handlers.Callable,
        'handler_config': {
            'authentication': clearskies.authentication.public(),
            'callable': example_callable,
        },
    },
    bindings={
        'test_binding': 'world',
    }
)
def application(env, start_response):
    return callable_demo(env, start_response)
{% endhighlight %}

[Run this in a local server](docs/running-examples.html#running-examples-designed-for-an-http-server) and then invoke it via something like curl:

```
curl 'http://localhost:9090'
```

and you'll get back the following response:

{% highlight json %}
{
  "status": "success",
  "error": "",
  "data": "Hello world",
  "pagination": {},
  "input_errors": {}
}
{% endhighlight %}

### Return Raw Response

The `return_raw_response` configuration accepts a boolean.  If it is true, then clearskies will not wrap the response from the callable in the standard clearskies response format but will just return it as-is.  Take the following example:

{% highlight python %}
import clearskies

def example_callable(test_binding):
    return f'Hello {test_binding}'

callable_demo = clearskies.contexts.wsgi(
    {
        'handler_class': clearskies.handlers.Callable,
        'handler_config': {
            'authentication': clearskies.authentication.public(),
            'callable': example_callable,
            'return_raw_response': True,
        },
    },
    bindings={
        'test_binding': 'world',
    }
)
def application(env, start_response):
    return callable_demo(env, start_response)
{% endhighlight %}

If you [run it locally](docs/running-examples.html#running-examples-designed-for-an-http-server) and call the server like so:

```
curl 'http://localhost:9090'
```

You will get the following response:

```
helloworld
```

### Schema

The `schema` option allows you to specify a schema that the incoming user data will be compared against.  This schema can take a few forms:

 1. A model class
 2. A model
 3. A list of column definitions (like you would define in a model class).

clearskies will validate any user input against the schema and, if it does not pass the requirements, will return an input error to the client without invoking your function.  It will also use the schema to populate the documentation for the endpoint in the autodocs.  See the following example of validation against a model class:

{% highlight python %}
import clearskies
from clearskies.column_types import string, float
from clearskies.input_requirements import required
from collections import OrderedDict

def example_callable(request_data):
    return request_data

class Product(clearskies.Model):
    def __init__(self, memory_backend, columns):
        super().__init__(memory_backend, columns)

    def columns_configuration(self):
        return OrderedDict([
            string('name', input_requirements=[required()]),
            float('price'),
        ])

callable_demo = clearskies.contexts.wsgi(
    {
        'handler_class': clearskies.handlers.Callable,
        'handler_config': {
            'authentication': clearskies.authentication.public(),
            'callable': example_callable,
            'schema': Product,
        },
    },
)
def application(env, start_response):
    return callable_demo(env, start_response)
{% endhighlight %}

If you [run it locally](docs/running-examples.html#running-examples-designed-for-an-http-server) and call the server like so:

```
curl 'http://localhost:9090' -d '{"name": "toys", "price": 85.50}'
```

You will receive a response like so:

{% highlight json %}
{
  "status": "success",
  "error": "",
  "data": {
    "name": "toys",
    "price": 85.5
  },
  "pagination": {},
  "input_errors": {}
}
{% endhighlight %}

And of course if you send invalid data:

```
curl 'http://localhost:9090' -d '{"price": "hey"}'
```

You would receive the expected input errors:

{% highlight json %}
{
  "status": "input_errors",
  "error": "",
  "data": [],
  "pagination": {},
  "input_errors": {
    "name": "'name' is required.",
    "price": "Invalid input: price must be an integer or float"
  }
}
{% endhighlight %}

Note that since price is not required, it may be absent from the `request_data`.

### Writeable Columns

### Doc Model Name

### Doc Response Data Schema
