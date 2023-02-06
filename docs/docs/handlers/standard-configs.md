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

You can then launch this application locally:

```
uwsgi --http :9090 --wsgi-file example.py
```

And if you call it like so:

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
