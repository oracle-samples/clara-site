---
layout: docs
title: Session Inspection
permalink: /docs/inspection/
---

The [clara.tools.inspect]({{site.clojuredoc}}clara.tools.inspect.html) namespace offers functions to inspect and understand the state of rule sessions.

The ```inspect``` function in that namespace returns a data structure that can be used to see what rules or queries were activated, and what went into that activation.

As a convenience, the namespace also provides an ```explain-activations``` function, producing a human readable explanation of the state of a rule session. Here's an example of it in use. Running the following

{% highlight clojure %}
(inspect/explain-activations session)
{% endhighlight %}

produces something like this, showing what fired and why:

{% highlight clojure %}
rule example.demo/restricted-items
  executed
    (clara.rules/insert! (example.demo/->ApprovalRequired :restriction (str ?type  is restricted at  ?location)))
  because
     #example.demo.WorkOrder{:location FortressOfSolitude, :date #<DateTime 2015-01-01T00:00:00.000Z>, :priority :high}
       is a example.demo.WorkOrder
       where [(= ?location location)]
     #example.demo.LineItem{:type Kryptonite, :description Surprise gift!, :price 0}
       is a example.demo.LineItem
       where [(= ?type type)]
     #example.demo.RestrictedItem{:type Kryptonite, :location FortressOfSolitude}
       is a example.demo.RestrictedItem
       where [(= ?location location) (= ?type type)]
{% endhighlight %}

See [clara.tools.inspect]({{site.clojuredoc}}clara.tools.inspect.html) namespace for more details.
