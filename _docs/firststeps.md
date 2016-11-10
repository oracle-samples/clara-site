---
layout: docs
title: First Steps
permalink: /docs/firststeps/
---

*This page jumps into downloading and using Clara. Some new users may be interested in learning more about [Clara's approach to rules](/docs/approach).*

Let's get started! The first thing you'll need to do is bring Clara into your project. You can do this in Leiningen:

{% highlight clojure %}
[com.cerner/clara-rules "{{site.clara_version}}"]
{% endhighlight %}

or to your Maven POM:

{% highlight xml %}
<dependency>
  <groupId>com.cerner</groupId>
  <artifactId>clara-rules</artifactId>
  <version>{{site.clara_version}}</version>
</dependency>
{% endhighlight %}

## Your first rules

Clara rules live in a Clojure namespace and can be treated like any other code.

Let's look at a simple, complete example using Clara:

{% highlight clojure %}
(ns clara.example
  (:require [clara.rules :refer :all]))

(defrecord SupportRequest [client level])

(defrecord ClientRepresentative [name client])

(defrule is-important
  "Find important support requests."
  [SupportRequest (= :high level)]
  =>
  (println "High support requested!"))

(defrule notify-client-rep
  "Find the client representative and request support."
  [SupportRequest (= ?client client)]
  [ClientRepresentative (= ?client client) (= ?name name)]
  =>
  (println "Notify" ?name "that"  
          ?client "has a new support request!"))

{% endhighlight %}

Now let's run those rules! We can do so from Clojure:

{% highlight clojure %}
(-> (mk-session 'clara.example)
    (insert (->ClientRepresentative "Alice" "Acme")
            (->SupportRequest "Acme" :high))
    (fire-rules)))
{% endhighlight %}

Or from Java:

{% highlight java %}
// In Java, our facts would typically be JavaBeans.
List<Object> facts = ...;

RuleLoader.loadRules("clara.example")
  .insert(facts)
  .fireRules();

{% endhighlight %}

This program will simply print the following:

{% highlight text %}
High support requested!
Notify Alice that Acme has a new support request!
{% endhighlight %}

## What's next?
Of course, a real rule set would infer new knowledge and offer ways to query it.

* See the [writing rules page](/docs/rules/) for more realistic rules
* See the [clara-examples project](https://github.com/cerner/clara-examples) for more sophisticated examples
