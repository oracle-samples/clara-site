---
layout: docs
title: Session Inspection
permalink: /docs/inspection/
---

The [clara.tools.inspect]({{site.clojuredoc}}clara.tools.inspect.html) namespace offers functions to inspect and understand the state of rule sessions.

The ```inspect``` function in that namespace returns a data structure with information on what has occurred in the session.  For example, it can be used to see

- What rules or queries were activated, and what went into those activations.
- All the facts inserted by a particular rule.
- What rule inserted a particular fact.

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

```explain-activations``` also takes a filter function that can be used to selectively choose which rules should have their activations explained.

See the [clara.tools.inspect API documentation]({{site.clojuredoc}}clara.tools.inspect.html) for more details.

Note that session inspection functionality related to reports on insertion of facts is unsupported on unconditionally inserted facts.  Session inspection internally uses information that is stored as part of truth maintenance to report on this, and as a result the session inspection code cannot tie an unconditionally inserted fact to the rule that inserted it.  This doesn't prevent use of session inspection on a session that contains both logically inserted and unconditionally inserted facts.   The session inspection functionality will still tie logically inserted facts and the rules that inserted them together; it just won't have the same information on unconditionally inserted facts.

Similarly, rule activation data is, by default, only available for rule activations that resulted in logical insertions that were not later retracted.  However, it is possible to collect data on all rule activations, regardless of what their consequences were and whether they were retracted.  This option must be enabled prior to calling fire-rules via the with-full-logging function since it has negative performance consequences that should be avoided by default. In particular, with-full-logging can increase memory consumption substantially if many facts in a session are retracted, since it forces the session to hold references to retracted facts that could otherwise be garbage collected.  When it is enabled this data will be returned under the :unfiltered-rule-matches key.
