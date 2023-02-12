---
layout: default
title: Advanced Search
parent: Handlers
permalink: /docs/handlers/advanced-search.html
nav_order: 2
---

# Advanced Search

 1. [Overview](#overview)
 2. [Configuration](#configuration)
 3. [Using the Search Endpoint](#using-the-search-endpoint)

### Overview

The advanced search handler exposes an endpoint that allows the client to execute fairly arbitrary search criteria - searches on multiple columns, multiple searches on a single column, a variety of search operators, and sorting by more than one column.  Note, however, that the advanced search will ultimately be limited by your backend.  If your backend doesn't support the full search capabilities of the advanced search, then your clients may end up seeing 500s when making more complicated queries.  In general, you can expect this to work well with full-featured databases.  The memory backend is also designed to support the full search capabilities of the advanced search handler.

In addition, there is a backend (the advanced search backend) meant to work transparently with this handler.  The backend allows you to point a clearskies model at an API endpoint hosted with the advanced search backend.  Queries made with the models standard query builder will then be automatically translated into API calls to the advanced search backend.

### Configuration

The advanced search backend uses the same configuration options as the [list handler](list.html#configuration).

### Using the Search Endpoint
