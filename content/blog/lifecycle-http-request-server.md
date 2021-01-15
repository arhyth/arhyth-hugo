---
title: "Lifecycle of an HTTP Request: Server"
date: 2019-12-15T14:04:22+08:00
draft: true
---

In which part does the 

So our clients were having troubles with latency connecting to our API, and I got tasked to implement middlewares for measuring internal and external latency to investigate this on the server side. Good thing I got tasked with this as the year comes to end. New (and hard) learning, new post!

Apologies this will not be a generic post about http request lifecycle. I am sharing a particular realization about middlewares in Go that came by only after a fundamental understanding of request and response on the server side. 

