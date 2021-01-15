---
title: "Pass me them params"
date: 2018-12-01T17:41:15+08:00
draft: false
---

> Explicit is better than implicit. 

> *Zen of Python*

## Pass me them params

In my previous job, writing scripts to automate some of the repetitive tasks got me back into the programming route which eventually led me to consider a [career shift](/about). To be honest, automating tasks was, at least upfront, more hard work than additional straight up keystrokes. And without guarantee that the time invested will return in any quality or amount of savings, especially for smaller tasks, it was a day's work worth of risk. But it was fun and for most of the time it got the job done. It was also a lot of hacking. In hindsight I realize, nothing of what I created that time was reusable. Many were just one-off scripts that I had to manually edit as often as I run them because I had hardcoded variable information instead of exposing them properly as parameters.

Any good software is only as good as its interface. For users, it's UI and the "frontend"; for programmers, it's parameters. Functions and their parameters are what technology people mean when they say "API". But what about parameters make them any good? Let's imagine a `list_activities` function.

```elixir
def list_activities(params \\ []) do
  sort_params =
    params
    |> Enum.filter(fn {k, v} -> k in [:asc, :desc] end)
    |> case do
      [] -> [:desc, :id] # default case
      order -> order
    end

  Activities
  |> order_by(sort_params)
  |> other_query_fn(params)
  |> Repo.paginate()
end
```

### Options

Good parameters are parameters you don't need to write. In our example, the function is defined with an optional keyword list param. But specific activities may be filtered by defining the param keys `:asc` and `desc` such that any of the following calls are also valid

```elixir
list_activities(asc: :inserted_at)
```
```elixir
list_activities(desc: :id)
```
```elixir
list_activities(asc: :inserted_at, desc: :verified_at)
# in elixir,
# ...> [asc: :inserted_at, desc: :verified_at]
# ...> [{:asc, :inserted_at}, {:desc, :verified_at}]
# are equivalent and do not need the enclosing list brackets when passed as the last param in a function
```

This way the caller is prevented from reaching for parameter details and provide them only as needed. As a rule of thumb, you may make default any parameter that covers the most common case for your application.

## Names

Good parameters are called by their name. If possible, meanings should depend only on their names by calling their specific keys rather than by the order they are called.

```elixir
def list_activities(type \\ :sports, order \\ :asc, field \\ :inserted_at)
```

where the client code calling that could easily be calling with this and will most probably result in a runtime error

```elixir
def list_activities(type \\ :sports, field \\ :inserted_at, order \\ :asc)
```

Do this instead

```elixir
def list_activities(params \\ [type: :sports, field: :inserted_at, order: :asc])
```