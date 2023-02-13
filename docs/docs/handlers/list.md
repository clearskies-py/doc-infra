---
layout: default
title: List
parent: Handlers
permalink: /docs/handlers/list.html
nav_order: 10
---

# List

 1. [Overview](#overview)
 2. [Configuration](#configuration)
 3. [Examples](#examples)

## Overview

The List handler returns lists of records to the client.  It's also used as a base class for the various kinds of search handlers.  It's children all share the same basic configuration options, which are described below

## Configuration

The list backend has the following configuration options:

| Name | Required | Type          |
|------|----------|---------------|
| [model_class](#model-class) | Yes, unless `model` is provided | Model class |
| [model](#model) | Yes, unless `model_class` is provided | Model instance |
| [default_sort_column](#default-sort-column) | Yes | `str` |
| [readable_columns](#readable-columns) | Yes | `List[str]` |
| [searchable_columns](#searchable-columns) | Yes (if supported) | `List[str]` |
| [sortable_columns](#sortable-columns) | No | `List[str]` |
| [default_sort_direction](#default-sort-column) | No | `str` |
| [default_limit](#default-limit) | No | `int` |
| [max_limit](#max-limit) | No | `int` |
| [where](#where) | No | `List[Union[Callable, str]]` |
| [join](#join) | No | `List[str]` |
| [group_by](#group-by) | No | `List[str]` |

You can also use [all of the standard configurations provided by the handler base class](standard-configs).

### Model Class

The `model_class` configuration specifies the model class that the handler should work with (and therefore return results for).  You must specify either `model_class` or `model`: one must be provided, but never both.

### Model

The `model` configuration specifies the model that the handler should work with (and therefore return results for).  You must specify either `model` or `model_class`: one must be provided, but never both.

### Default Sort Column

This is the name of the column that the results should be sorted by, by default.  Of course, the column name must exist in the model schema and have a type that supports sorting (which most do)

### Readable Columns

A list of column names from the model which should be included in the data returned to the client.  Of course, each column must exist in the model schema.

### Searchable Columns

A list of column names from the model which the client is allowed to search by.  Of course, each column must exist in the model schema and have a type that supports searching.  Note that the base `List` handler itself does **not** support searching and so this is not required or applicable when using the `List` handler.  However, all the child classes of the `List` handler support searching and require this configuration setting.

### Sortable Columns

A list of column names from the model which the client can have the results sorted by.  Of course, each column must exist in the model schema and have a type that supports sorting.

### Default Sort Direction

The default direction that the results should be sorted by.  By default, the sort direction is `asc`.  Allowed values are `asc` or `desc`.

### Default Limit

The default number of records to return.  This is `100` by default.

### Max Limit

The maximum record limit that a user can request.  This is `200` by default but you can turn this as high as you want, but of course response times will increase when returning large number of records.  It is not possible to completely disable the limit.

### Where

A list of query conditions that should always be applied to the results.  The conditions can take one of two forms:

 1. A literal query condition (e.g. 'status=open', 'price>=100')
 2. A function which must accept (and return) a model object as well as other dependencies

Note that both options can be used together.  For the first option, the query string will be automatically passed along to the models object when fetching records.  Here's a partial example:

```
cheap_sales = clearskies.Application(
    clearskies.handlers.List,
    {
        'model_class': models.Product,
        'default_sot_column': 'name',
        'readable_columns': ['name', 'price', 'type', 'in_stock', 'on_sale', 'sale_end_date'],
        'where': [
            'on_sale=1',
            'price<15',
        ]
    }
)
```

And here's an example of using the second option (as well as combining it with the first):

```
def sale_ending_soon(models, utcnow):
    return models.where('sale_end_date<' + (utcnow+datetime.timedelta(days=1)).isoformat())

cheap_sales_ending_soon = clearskies.Application(
    clearskies.handlers.List,
    {
        'model_class': models.Product,
        'default_sot_column': 'name',
        'readable_columns': ['name', 'price', 'type', 'in_stock', 'on_sale', 'sale_end_date'],
        'where': [
            'price<15',
            sale_ending_soon,
        ]
    }
)
```

### Join

### Group By

## Examples
