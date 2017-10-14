## Jenkins Dockerfile

* Uses latest jenkins version
* Sets up a jenkins, no install wizard

## To test out locally

```
$ docker build -t jenkinsinfra .
$ docker run -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker -d -e JENKINS_ADMIN_PASSWORD=admin jenkinsinfra
```
