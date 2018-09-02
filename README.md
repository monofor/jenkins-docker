# Jenkins Image (latest)
Jenkins Image that contains additional tools.

This image contains built-in;

#### Docker (ce latest)

We will use directly docker commands without additional things on Jenkins Pipeline.

#### dotnet core (2.1.401)

We will use it for building our dotnet core projects.

#### nodejs (8.11.2)

We will use nodejs for using additional tools.

#### SonarQube dotnet tool (4.3.1)

This image also contains SonarQube plugin for dotnet.

## How to use

Don't forget to bind volumes when you run your docker image;

```bash
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home monofor/jenkins -v /var/run/docker.sock:/var/run/docker.sock
```