---
layout: docs
title: Writing Rules
permalink: /docs/rules/
---

Most users write rules with _defrule_, which uses this structure:

![defrule railroad diagram](/img/diagram/RULE.png)

Here's a simple example:

{% highlight clojure %}
(defrule free-lunch-with-gizmo
  "Anyone who purchases a gizmo gets a free lunch."
  [Purchase (= item :gizmo)]
  =>
  (insert! (->Promotion :free-lunch-with-gizmo :lunch)))
{% endhighlight %}

Hopefully this seems pretty intuitive, but let's take a closer look at the pieces. We start with:

{% highlight clojure %}
(defrule free-lunch-with-gizmo
  "Anyone who purchases a gizmo gets a free lunch."
{% endhighlight %}

These just declare the rule name and include an optional documentation string. Next we have the rule's _left-hand side_, which is everything before the _=>_ symbol:

{% highlight clojure %}
  [Purchase (= item :gizmo)]
{% endhighlight %}

The left-hand side holds the conditions needed for the rule to fire. In this case we just check if there is a Purchase record (in this case a Clojure record or Java Bean) with an item that is a gizmo.

Now we look at the _right-hand side_ of the rule, everything after the => symbol:

{% highlight clojure %}
(insert! (->Promotion :free-lunch-with-gizmo :lunch)))
{% endhighlight %}

This is just a Clojure expression! It can call arbitrary functions or even have side effects. In this case the expression is insert a new fact into the working memory, that there is a free lunch promotion here.

Here's one that is a bit more sophisticated:

{% highlight clojure %}
(defrule grant-discount-months  
  [Purchase (= ?month (get-month date))]
  [DiscountMonth (= ?month month)]
  =>
  (insert! (->GrantDiscount :for-month ?month)))
{% endhighlight %}

Here we demonstrate _variable binding_ and _unification_ between rule conditions. This calls some _get-month_ function and binds it to a _?month_ variable, and the rule will only be satisfied if there is is a discount that matches the month. Details on this are in the [Writing Expressions](/docs/expressions/) documentation.

## What's next?
* See the [Writing Expressions](/docs/expressions) section for details on writing expressions for a rule's left-hand side.
* See the [Writing Queries](/docs/queries) section for how to query a rule session.
