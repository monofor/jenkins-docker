# Jenkins Image (latest)

Jenkins Image that contains additional tools.

This image contains built-in;

#### Docker (ce latest)

We will use directly docker commands without additional things on Jenkins Pipeline.

#### dotnet core (LTS Latest)

SDK Files;
2.1.17 - LTS: `dotnet-sdk-2.1.805-linux-x64.tar.gz` (2020-03-24)
3.1.3 - LTS: `dotnet-sdk-3.1.201-linux-x64.tar.gz` (2020-03-24)

We will use it for building our dotnet core projects.

#### nodejs (12.16.1 - LTS)

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
