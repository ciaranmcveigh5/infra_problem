FROM infrabase

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN make test
RUN make clean all

CMD ["java","-jar","/usr/src/app/build/quotes.jar"]
