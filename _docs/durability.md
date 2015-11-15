---
layout: docs
title: Durability
permalink: /docs/durability/
---

**Note:** this feature is considered experimental since the underlying format may change between releases. However, it is usable if you are willing to drop previous session state during an upgrade.

The state of Clara sessions can be obtained as a data structure that can be persisted and reloaded as needed. Clara doesn't define a storage mechanism, but users can safely write session state as an EDN or Fressian structure to arbitrary external storage.

Durability support is provided by the [clara.rules.durability]({{site.clojuredoc}}clara.rules.durability.html) namespace. Here's an example of use:

{% highlight clojure %}
(ns clara.durability-example
  (:require [clara.rules :refer :all]
            [clara.rules.durability :as d]))

...

;; Create an immutable session for use.
(def session (mk-session 'clara.sample-ruleset))

...
;; Create a session and insert some facts. We then grab the state.
;; Typically we would do some more work before persisting the state.
(let [state-structure (-> session
                          (insert (->Temperature 10 "London")
                                  (->WindSpeed 40 "London"))
                          (d/session-state))]

  ;; Write the state structure as EDN or Fressian to some external store.
  ;; This can be file, database, or any other durable storage.
  ;; (The persist-state-structure function is a placeholder for a
  ;; user-provided persistence mechanism.)
  (persist-state-structure external-store state-structure))

;; Create a new session from our immutable prototype, and restore the previously
;; serialized session state. The restore-session-state uses the same EDN structure
;; that the session-state function produces, presumably reading it from some
;; external storage.
(let [new-session (-> session
                      (d/restore-session-state (load-state-structure external-store))
                      (fire-rules)) ]

  ;; Run a query and print the result.
  (println (query new-session clara.sample-ruleset/find-cold-and-windy))

{% endhighlight %}

A [complete example is available in the clara-examples project](https://github.com/rbrush/clara-examples/blob/master/src/main/clojure/clara/examples/durability.clj). Also see the [clara.rules.durability]({{site.clojuredoc}}clara.rules.durability.html) namespace for details.
