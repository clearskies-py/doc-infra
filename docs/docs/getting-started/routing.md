---
layout: default
title: Routing
parent: Getting Started
permalink: /docs/getting-started/routing.html
nav_order: 2
---

# Routing

## Basics

In [our previous example](./callables.html) we executed a single function in a CLI context.   That's obviously pretty simple, but of course a real-world application will need some routing.  clearskies has a [simple routing handler](/docs/handlers/simple_routing.html) to provide detailed control over your routes as well as an autodoc system.  While this can be used directly like any handler, clearskies also comes with a decorator system to simplify usage:

{% highlight python %}
import clearskies

@clearskies.decorators.get('/user/{user_id}')
@clearskies.decorators.public()
def get_user(user_id):
    return user_id

@clearskies.decorators.post('/user/{user_id}')
@clearskies.decorators.public()
def update_user(request_data, user_id):
    print(f'Saving {user_id}')
    print(request_data)

cli = clearskies.contexts.cli([get_user, update_user])
cli()
{% endhighlight %}

[Setup this example to run from the CLI](/docs/running-examples.html#running-examples-designed-for-the-cli) and then execute it.  Note that, in a CLI context, clearskies translates URL-based paths (which are slash separated) into the space-based paths that a CLI program normally expects:

```
$ ./clearskies_example.py user 5 | jq
{
  "status": "success",
  "error": "",
  "data": "5",
  "pagination": {},
  "input_errors": {}
}
```

In addition, clearskies expects a `request_method` parameter to reach POST endpoints, and the equivalent of JSON parameters are set via `--key=value` parameters:

```
$ ./clearskies_example.py user 5 --request_method=POST --name=bob | jq
{
  "status": "success",
  "error": "",
  "data": {
    "name": "bob",
    "id": "5"
  },
  "pagination": {},
  "input_errors": {}
}
```

Of course, you may be building a web application, in which case the exact same code works but with a different context:

{% highlight python %}
import clearskies

@clearskies.decorators.get('/user/{user_id}')
@clearskies.decorators.public()
def get_user(user_id):
    return user_id

@clearskies.decorators.post('/user/{user_id}')
@clearskies.decorators.public()
def update_user(request_data, user_id):
    return {
        **request_data,
        'id': user_id,
    }

in_wsgi = clearskies.contexts.wsgi([get_user, update_user])
def application(env, start_response):
    return in_wsgi(env, start_response)
{% endhighlight %}

[Launch your wsgi server](/docs/running-examples.html#running-examples-designed-for-an-http-server) and then call your local application:

```
$ curl 'http://localhost:9090/user/5' | jq
{
  "status": "success",
  "error": "",
  "data": "5",
  "pagination": {},
  "input_errors": {}
}
```

Or:

```
$ curl 'http://localhost:9090/user/5' -d '{"name":"bob"}' | jq
{
  "status": "success",
  "error": "",
  "data": {
    "name": "bob",
    "id": "5"
  },
  "pagination": {},
  "input_errors": {}
}
```

## Authorization

## Additional Options
