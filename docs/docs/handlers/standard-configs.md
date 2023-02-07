---
layout: default
title: Standard Configs
parent: Handlers
permalink: /docs/handlers/standard-configs
nav_order: 1
---

# Standard Configs

This is the list of standard configuration values for handlers in clearskies.  Examples below.

| Name | Type          | Default Value | Description |
|------|---------------|---------------|-------------|
| [response_headers](#response-headers) | Dict | `None` | Additional headers to include in the response |
| [authentication](#authentication) | clearskies.authentication | `None` | Authentication object to authenticate the request |
| [authorization](#authorization) | Class or callable | `None` | Authorization rules for the endpoint |
| [output_map](#output-map) | Callable | `None` | Function to modify the final response to the client |
| [column_overrides](#column-overrides) | Dict | `None` | New column definitions |


### Response Headers

The `response_headers` configuration specifies additional headers to send along with the request.  This is ignored if the context is not HTTP-compatible (e.g. the cli context).  `response_headers` should be a dictionary with key/value pairs.  In the below example we add an additional response header of `Content-Language: en`:

{% highlight python %}
import clearskies

def my_function(utcnow):
    return utcnow.isoformat()

application_with_headers = clearskies.contexts.wsgi({
    'handler_class': clearskies.handlers.Callable,
    'handler_config': {
        'authentication': clearskies.authentication.public(),
        'callable': my_function,
        'response_headers': {
            'content-language': 'en',
        }
    }
})

def application(env, start_response):
    return application_with_headers(env, start_response)
{% endhighlight %}

[Run it locally](/docs/running-examples#running-examples-designed-for-an-http-server) and then call it like so:

```
curl -i 'http://localhost:9090'
```

You'll get back a response with the expected header:

```
HTTP/1.1 200 Ok
CONTENT-TYPE: application/json
CONTENT-LANGUAGE: en

{"status": "success", "error": "", "data": "2023-02-06T16:15:08.529106+00:00", "pagination": {}, "input_errors": {}}
```

### Authentication

Clearskies explicitly requires an authentication object for all HTTP-compatible contexts.  When operating in the CLI context, the authentication is automatically set to public.  For more details and examples, see the [authentication/authorization](/docs/authn-authz) section of the docs.  Here's a quick example on how to specify a public endpoint:

```
import clearskies

def my_function(utcnow):
    return utcnow.isoformat()

application_with_headers = clearskies.contexts.wsgi({
    'handler_class': clearskies.handlers.Callable,
    'handler_config': {
        'authentication': clearskies.authentication.public(),
        'callable': my_function,
    }
})

def application(env, start_response):
    return application_with_headers(env, start_response)
```

### Authorization

There are a variety of options for enfocring authorization on your endpoints.  This is a key aspect of clearskies, so [it has its own section in the documentation](/docs/authn-authz).

### Output Map

Sometimes the output created by clearskies handlers just isn't quite what you need.  The output map fixes that.  You provide a function which will be called for each record in the response, and the function returns the final data that should be passed along to the client.  Here's an example API that returns a modified product record via the `output_map` configuration setting in the RESTful API handler:

{% highlight python %}
import clearskies
from clearskies.column_types import string, float, created, updated
from collections import OrderedDict

class Product(clearskies.Model):
    def __init__(self, memory_backend, columns):
        super().__init__(memory_backend, columns)

    def columns_configuration(self):
        return OrderedDict([
            string('name'),
            string('description'),
            float('price'),
            created('created_at'),
            updated('updated_at'),
        ])

def output_product(product):
    return {
        'name': product.name.upper(),
        'price': product.price,
        'discounted_price': product.price*0.5,
    }

products_api = clearskies.contexts.wsgi({
    'handler_class': clearskies.handlers.RestfulAPI,
    'handler_config': {
        'output_map': output_product,
        'authentication': clearskies.authentication.public(),
        'model_class': Product,
        'readable_columns': ['name', 'description', 'price', 'created_at', 'updated_at'],
        'writeable_columns': ['name', 'description', 'price'],
        'searchable_columns': ['name', 'description', 'price'],
        'default_sort_column': 'name',
    }
})
def application(env, start_response):
    return products_api(env, start_response)
{% endhighlight %}

[Run it locally](/docs/running-examples#running-examples-designed-for-an-http-server) and then create a record, grabbing out the data returned for the new record:

```
curl 'http://localhost:9090' -d '{"name": "test product", "price": 15.50}' | jq '.data'
```

and you'll see something like this:

{% highlight json %}
{
  "name": "TEST PRODUCT",
  "price": 15.5,
  "discounted_price": 7.75
}
{% endhighlight %}
