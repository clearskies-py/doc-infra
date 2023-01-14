#!/usr/bin/env sh
cd blog
bundle exec jekyll build
cd _site
aws s3 cp . s3://blog.cmancone.com --recursive
