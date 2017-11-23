(ns front-end.core
  (:gen-class)
  (:require [compojure.core :refer :all] ; all types GET PUT DELETE POST
            [compojure.route :as route]
            [common-utils.core :as utils]
            [common-utils.middleware :as mw]
            [front-end.data :as d]
            [front-end.views :as views]
            [front-end.utils :refer :all]
            [clojure.tools.logging :as log]
            [ring.middleware.reload :refer [wrap-reload]] ; similar to nodemon
            [org.httpkit.server :refer [run-server]])) ; equivalent to jetty, asynchronous long polling

(defn index []
  (let [q (d/get-quote) ; functions from data.clj
        n (d/get-news)]
    (views/index (d/handle-quote-response q) ; passing returned values from q & n into handler function then passing the returned value of that into a views function
                 (d/handle-news-response n))))

(defn- wrap-exception-handling
  [app]
  (fn [request]
    (try (app request)
         (catch Exception e (do (log/error e (str (clojure.string/upper-case (name (:request-method request))) " " (:uri request)))
                                {:status 500
                                 :body   (views/error)})))))

(defroutes app-routes ; Defining routes
  (GET "/ping" [] {:status 200})
  (GET "/" [] (index)) ; index referring to variable index defined above
  (route/not-found {:status 404
                    :body   (views/not-found)})) ; not found handler

(def app
  (-> app-routes
      mw/correlation-id-middleware
      wrap-exception-handling
      wrap-reload)) ; remove this for production only relevant for dev, can be defined with defn -dev-main

(defn -main []
  (let [port (:app_port config)]
    (log/info "Running front-end on port" port)
    (run-server (var app) {:ip "0.0.0.0"
                           :port port})))
