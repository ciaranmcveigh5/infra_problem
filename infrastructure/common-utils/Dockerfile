FROM clojure

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install make -y
RUN apt-get install python3 -y

COPY . /usr/src/app/common-utils

WORKDIR /usr/src/app/common-utils

RUN make libs
