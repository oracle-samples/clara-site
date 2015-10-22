---
layout: docs
title: Writing Queries
permalink: /docs/queries/
---

While [rules](/docs/rules/) are used to infer new knowledge or take action, queries are used to ask questions about a rule session.

Queries are typically defined with **defquery**, which has the following structure:

![defquery railroad diagram](/img/diagram/QUERY.png)

A query has two major pieces:

* A parameter definition, which allow callers to control the scope of the query when it is called.
* One or more conditions, which define the facts matching the query. These conditions are the same structure as a rule left-hand side.

A sample query looks like this:

{% highlight clojure %}
(defquery get-promotions
  "Query to find promotions for the purchase."
  [:?type]
  [?promotion <- Promotion (= ?type type)])
{% endhighlight %}

A caller may then execute that query with arguments. So if we only wanted to find lunch promotions, we might perform the query like this:

{% highlight clojure %}
(query session get-promotions :?type :lunch)
{% endhighlight %}

Some queries may have no parameters. Queries return a sequence of results, with each result being a map of the a bound variable to its value. So the above query may return a sequence that looks like this:

{% highlight clojure %}
[{:?type :lunch :promotion #example.Promotion{:type :lunch :name "A name"}}
 {:?type :lunch :promotion #example.Promotion{:type :lunch :name "Other Name"}}]
{% endhighlight %}

## What's next?
* See the [Writing Expressions](/docs/expressions) section for details on writing expressions.
