---
title: "Cache Near Your Source"
date: 2021-03-13T10:35:21+08:00
draft: false
---

# Cache near your source

<br>

At $WORK, I recently needed to make a change which could have been an easy change if only our system was designed differently. The diffuculty boils down to one issue: the cache was too far from the pertinent data source.

Clients of cached components/services do not need to know about caching. They could care less if it's making a very expensive call to a third party service the other side of the world or simply fetching a response from memory. This is a property and the main selling point of interfaces.

## Share the same interface

You can make all sorts of optimization between a source and its cache because these details are hidden behind an interface. On the other hand, the farther away (in layers of abstraction) a cache is from its source, the more complexity it eventually (it has to) leaks to the whole system.

```
┌──────────────────┐
│      Component A │
│  ┌─────────┐     │◄─────────┐
│  │ Source  │     │          │
│  └─┬───────┤ sca │          │
│    ├───────┴─┐   │          │
│    │  Cache  │   │       ┌──┴──────────┐
│    └─────────┘   │       │             │
│                  │       │             │
└──────────────────┘       │             │
                           │             │
                           │  System C   │
                           │             │
┌──────────────────┐       │             │
│      Component B │       │             │
│  ┌─────────┐     │       │             │
│  │ Source  │     │       └──┬──────────┘
│  └─┬───────┤ scb │          │
│    ├───────┴─┐   │          │
│    │  Cache  │   │◄─────────┘
│    └─────────┘   │
│                  │
└──────────────────┘
```

Consider `System C` above which depends on `Component A` and `Component B`. The two components share the same interface but have different implementations. `System C` is not aware that the two components have their own cache. From `System C` perspective, how the sources interact with their own cache (sca, scb) or even whether the caches exist or not does not matter. 

Let's then say that as service owners of `System C` we decided we would like it to have its own cache to avoid calling the components entirely, whenever possible. By doing that, however, they would be trading off clear separation of concerns for a few 10/100/ms of latency. `System C` would have to provide an API (sca', scb') for each of the components to invalidate/update the cache similar to how the component communicates with its cache internally.

```
┌──────────────────┐
│      Component A │
│  ┌─────────┐     │◄─────────┐
│  │ Source  │     │          │
│  └─────────┘     │          │
│                  │          │
└──────────┬───────┘   ┌───┬──┴──────────┐
           │           │ c │             │
      sca' └──────────►│   │             │
                       │ a │             │
                       │   │             │
      scb' ┌──────────►│ c │  System C   │
           │           │   │             │
┌──────────┴───────┐   │ h │             │
│      Component B │   │   │             │
│  ┌─────────┐     │   │ e │             │
│  │ Source  │     │   └───┴──┬──────────┘
│  └─┬───────┤ scb │          │
│    ├───────┴─┐   │          │
│    │  Cache  │   │◄─────────┘
│    └─────────┘   │
│                  │
└──────────────────┘
```

Notice that when the cache was colocated with the source, the data flow across components was unidirectional. It would be easy to dismiss this difference as trivial but add in another layer of abstraction between `System C` and the source components and the data flows easily gets hairy.
