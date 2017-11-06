[![][AtlassianLogo]][website]

# Bamboo Server in a Docker Container

Bamboo is a continuous integration and continuous deployment server developed by Atlassian. As of today Atlassian still does not provide an official Docker image  and that is where this project comes into play.

## Requirements

- Docker

## Installed software

- Java 8
- Docker CE (17.09.0)
- Node.js (8.x)
- Google Chrome (latest)

## Pricing

Bamboo can be deployed as a Docker container but that doesn't mean that it is free to use. You still have to obtain a licence. A free 30-days trial period is available and all you need to do is to get an [evaluation licence](https://my.atlassian.com/license/evaluation) from Atlassian.

For more information see [pricing](https://de.atlassian.com/software/bamboo/pricing) or visit the official [homepage](https://atlassian.com/software/bamboo).

## Deployment

### Docker Run
````
docker run --detach -v /var/run:/var/run --publish 8085:8085 --name bamboo p0wnbauer/atlassian-bamboo-dockerized:latest
````

### Docker Compose

Docker Compose is not bundled with the regular Docker installation and has to be installed separately.

Example of a docker-compose.yml that can be used to deploy Bamboo by using the [Docker Compose](https://docs.docker.com/compose/) tool:

````
version: '3'

services:

  bamboo:
      image: p0wnbauer/atlassian-bamboo-dockerized:latest
      container_name: bamboo
      privileged: true
      tty: true
      volumes:
        - /var/run:/var/run:rw
        - bamboo_home:/var/atlassian/application/bamboo:rw
      ports:
        - 8085:8085
      networks:
        - bamboo-net

networks:
   bamboo-net:

volumes:
   bamboo_home:
````

Execute the following command within a directory
````
docker-compose up -d
````

### Docker Swarm

The target machine has to be Docker Swarm node. This means you have to [initialize](https://docs.docker.com/engine/reference/commandline/swarm_init/) a Docker Swarm if you haven't done it already.

Example of a Docker stack file that can be used to deploy a Bamboo service to a Docker Swarm Node.

````
version: '3'

services:

  bamboo:
      image: p0wnbauer/atlassian-bamboo-dockerized:latest
      tty: true
      volumes:
        - /var/run:/var/run:rw
        - bamboo_home:/var/atlassian/application/bamboo:rw
      ports:
        - 8085:8085
      networks:
        - bamboo-net

networks:
   bamboo-net:

volumes:
   bamboo_home:
`````
Run the following command to deploy Bamboo from a compose file with the stack name of `ci-server-infrastructure`:
````
docker stack deploy -c docker-compose.yml ci-server-infrastructure
````

## Connection to an external database

All available JDBC drivers are bundled within this image so you don't have to download them separately. Please be aware that you need to use the Docker service name for the host part of the database URL when connecting to a local database server running inside another Docker container (when on the same network). Also be aware of limitations (and hacky workarounds) when you are trying to connect to database installed on your host machine without using Docker.

An example for a database URL using a PostgreSQL Docker container with a service-name of `postgres-db` would be:

````
jdbc:postgresql://postgres-db/bamboo
````

If you are deploying the database in a Docker Swarm and the database container is on a different stack than your Bamboo server, you have to type the name of the other stack followed by `_`. For exam
## License

```
MIT License

Copyright (c) 2017 Martin Ponbauer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

[AtlassianLogo]:https://www.atlassian.com/dam/jcr:93075b1a-484c-4fe5-8a4f-942710e51760/Atlassian-horizontal-blue@2x-rgb.png
[website]: https://www.atlassian.com/software/bamboo
