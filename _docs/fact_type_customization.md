---
layout: docs
title: Fact Type Customization
permalink: /docs/fact_type_customization/
---

By default Clara uses Clojure's [type function](https://clojuredocs.org/clojure.core/type) to determine what type a fact is for purposes of matching on rules and queries.  A fact type can also have ancestors, and a fact will also match conditions on ancestors of its type.  For example, suppose we have a case like:

{% highlight clojure %}
(definterface BadWeather)

(defrecord Cold []
     BadWeather)
	 
(defrecord StayInside [])

(defrule concrete-type-rule
  [Cold]
  =>
  (insert! (->StayInside)))
	
(defrule ancestor-type-rule
  [BadWeather]
  =>
  (insert! (->StayInside)))
	
(-> (mk-session [concrete-type-rule ancestor-type-rule])
    (insert (->Cold)))
{% endhighlight %}

The Cold fact that is inserted will match concrete-type-rule since it looks for a Cold fact.  However, it will also match ancestor-type-rule since that rule looks for a BadWeather fact, and the type Cold descends from the type BadWeather according to Clojure's [ancestors function](https://clojuredocs.org/clojure.core/ancestors).  Note that Clojure's ancestors function also honors parent-child relations created in Clojure's global hierarchy with the [derive function](https://clojuredocs.org/clojure.core/derive), and thus Clara will honor them as well by default.  This behavior is customizable with the :fact-type-fn and :ancestors-fn options to [mk-session]({{ site.url }}{{site.clojuredoc}}clara.rules.html#var-mk-session).
For example, in the following [case from clara-examples](https://github.com/cerner/clara-examples/blob/master/src/main/clojure/clara/examples/fact_type_options.clj):

{% highlight clojure %}
(defrule too-cold
  [:temperature-reading (< (:temperature this) 0)]
  =>
  (insert! {:weather-fact-type :weather-status
              :good-weather false}))

(defquery weather-status
  "Query for weather status"
  []
  [:weather-status (= ?good-weather (:good-weather this))])

(def custom-fact-type-fn :weather-fact-type)

(def custom-ancestors-fn {:precise-temperature-reading #{:temperature-reading}})

(def empty-session (mk-session [too-cold weather-status]
                               :fact-type-fn custom-fact-type-fn
                               :ancestors-fn custom-ancestors-fn))
{% endhighlight %}

the fact 

{% highlight clojure %}
{:weather-fact-type :precise-temperature-reading :temperature -10}
{% endhighlight %}

will match the rule too-cold since Clara will first call :weather-fact-type on the fact, returning the value :precise-temperature-reading.  Clara will then call the ancestors-fn with an argument of :precise-temperature-fn.  The fact will then be evaluated by all conditions on either the concrete type of :precise-temperature-reading or any of the ancestors types returned by the ancestors-fn.  In this case, since :temperature-reading is in the set of ancestors of :precise-temperatures-fn it is considered for the condition on :temperature-reading facts in too-cold.


