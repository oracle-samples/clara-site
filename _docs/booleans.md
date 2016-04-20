---
layout: docs
title: Details on Boolean Expressions
permalink: /docs/booleans
---

Clara boolean expressions essentially provide a more concise
way to represent logic that would otherwise require multiple rules.
For example, the following are equivalent:

{% highlight clojure %}
(defrule bad-weather-rule
 [Temperature (< temperature 20)]
 [:or [WindSpeed (> speed 20)]
      [Rainfall (> height 20)]]
 =>
 (insert! (->BadWeather)))
{% endhighlight %}

{% highlight clojure %}

(defrule bad-weather-rule-1
 [Temperature (< temperature 20)]
 [WindSpeed (> speed 20)]
 =>
 (insert! (->BadWeather)))

(defrule bad-weather-rule-2
 [Temperature (< temperature 20)]
 [Rainfall (> height 20)]
 =>
 (insert! (->BadWeather)))
{% endhighlight %}

An important consequence of this equivalence is that an :or in a Clara
boolean expression, unlike the Clojure(Script) "or" function, is *not* short-circuiting.

Similarly, the following are equivalent as well:

{% highlight clojure %}
(defrule good-weather-rule
[Temperature (> temperature 30)]
[Sunny]
=>
(insert! (->GoodWeather)))
{% endhighlight %}

{% highlight clojure %}
(defrule good-weather-rule
[:and
  [Temperature (> temperature 30)]
  [Sunny]]
=>
(insert! (->GoodWeather)))
{% endhighlight %}

A key point here is that the conditions in a Clara rule have an
implicit :and.  An explicit :and is useful when it is nested inside another boolean condition.

The file in clara-examples for boolean expressions contains some more examples:
[clara-examples boolean expressions](https://github.com/rbrush/clara-examples/blob/master/src/main/clojure/clara/examples/booleans.clj)

Facts for the preceding examples:
{% highlight clojure %}
(defrecord Temperature [temperature])
(defrecord WindSpeed [speed])
(defrecord Rainfall [height])
(defrecord BadWeather [])
(defrecord Sunny [])
(defrecord GoodWeather [])
{% endhighlight %}

