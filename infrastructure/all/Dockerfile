FROM clojure

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install make -y
RUN apt-get install python3 -y

RUN mkdir /tmp/infra_problem

WORKDIR /tmp/infra_problem

RUN git clone https://github.com/ciaranmcveigh5/infra_problem.git .
RUN git pull

#RUN make test
RUN make libs
RUN make clean all
RUN make test

ENTRYPOINT sh start.sh

#RUN mkdir -p /usr/src/app
#WORKDIR /usr/src/app
#COPY project.clj /usr/src/app/
#RUN lein deps
#COPY . /usr/src/app
#RUN mv "$(lein uberjar | sed -n 's/^Created \(.*standalone\.jar\)/\1/p')" app-standalone.jar
#CMD ["java", "-jar", "app-standalone.jar"]
