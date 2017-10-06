#!/bin/bash

./front-end/public/serve.py &
java -jar ./build/front-end.jar &
java -jar ./build/quotes.jar &
java -jar ./build/newsfeed.jar &
