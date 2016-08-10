# GlassFish

GlassFish Docker image based on https://github.com/oracle/docker-images/tree/master/GlassFish/4.1.1

## How to use

First, you have to create a Domain Administration Server, or DAS for short.

```bash
$ docker run -d --name my_das -p 3700:3700 -p 4848:4848 -p 7676:7676 -p 8080:8080 \
-p 8181:8181 -p 8686:8686 -e 'DAS=true' jelastic/glassfish:latest
```

After that, you create any number of nodes you want. Below I created two nodes, so:

```bash
$ docker run -d --name node-1 --link my_das:das -p 3701:3700 -p 4849:4848 \
-p 7677:7676 -p 8081:8080 -p 8182:8181 -p 8687:8686 jelastic/glassfish:latest
$ docker run -d --name node-2 --link my_das:das -p 3702:3700 -p 4850:4848 \
-p 7678:7676 -p 8082:8080 -p 8183:8181 -p 8688:8686 jelastic/glassfish:latest
```
