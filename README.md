# Jenkins Image (latest)

Jenkins Image that contains additional tools.

This image contains built-in;

#### Docker (ce latest)

We will use directly docker commands without additional things on Jenkins Pipeline.

#### dotnet core (2.2.6 and 3.0.0-preview8)

SDK Files;
`dotnet-sdk-2.2.401-linux-x64.tar.gz`
`dotnet-sdk-3.0.100-preview8-013656-linux-x64.tar.gz`

We will use it for building our dotnet core projects.

#### nodejs (8.11.2)

We will use nodejs for using additional tools.

#### yarn

We will also use yarn for dependency management.

#### Terraform (0.11.13)

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

#### SonarQube dotnet tool latest

This image also contains SonarQube plugin for dotnet.

## How to use

Don't forget to bind volumes when you run your docker image;

```bash
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock monofor/jenkins
```
