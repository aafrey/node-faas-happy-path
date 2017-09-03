## Getting Aquainted with OpenFaaS

Back in January, Alex Ellis released a blog
[post](https://blog.alexellis.io/functions-as-a-service/) answering a
very interesting question. What would it look like to build your own
Serverless infrastructure with Docker? The original post covers some
previous efforts by members of the Docker community but then outlines a
rather novel solution, but before diving into that, it may help to know
a bit more about what Serverless or Functions as a Service (hereafter,
FaaS) entails.

> FaaS and Serverless will be used interchangeably throught the
> remainder of the article

Martin Fowler's bliki [page](https://martinfowler.com/articles/serverless.html)
contains a more thorough explanation of FaaS/Serverless, but this article will offer a brief
description as it relates to OpenFaaS. So when thinking about FaaS, it is helpful to think
about taking an application, breaking it down into it's simplest parts,
and then connecting those pieces back together with some sort of
network protocol (generally HTTP). Similar to a microservices driven
approach, this allows for pieces of an application to be built
independant of one another, in addition FaaS can differ from
microservices in that in many cases the management of the
service/function is
off-loaded to the cloud. As it relates to OpenFaaS, it also allows
for those pieces to be written in any language. Many Serverless
providers have limitations on which languages are supported. Functions
running on OpenFaaS can be written in any language, or simply bundle a command
line utility like ImageMagick instead.

The remainder of this article will include instructions on how to get up
and running with a simple NodeJS function using the OpenFaaS platform!

## Getting started with NodeJS on OpenFaaS

The [OpenFaaS](https://github.com/alexellis/faas) project is a simple way to get started with Serverless
technology. The project is spearheaded and maintained by ADP Principal Developer, open source enthusiast, and Docker Captain Alex Ellis but is open to contributions from the community.

When compared to other, similar technologies, it offers some significant
benefits. It can be used as a self hosted replacement of AWS, Google Cloud
Functions, Azure Functions etc so using OpenFaaS would eliminate being
tied to a particular provider. The platform is so flexible it can even
run on a raspberry pi! It also is not limited to a particular language!
The current cloud options have limits on what languages you can use,
generally Node and Python are acceptable but what about R, C#, or even
Cobol? OpenFaaS provides a unique language agnostic approach that make
it very approachable for developers of all backgrounds.

There are a number of resources that document getting started with
OpenFaaS, in fact the entire stack can be deployed in less than 60
seconds! This article however will document how easy it is to setup a
simple NodeJS function and deploy it to the OpenFaaS service

#### Dependencies

This article assumes installation of at least Docker 1.13. Docker
provides the bare minimum necessary to build and deploy function but
there is a better tool for the job!

###### faas-cli

`faas-cli` is a complementary package that significantly simplifies the
function build and deployment process. To install:
```
curl -sSL https://cli.openfaas.com | sudo sh
```

...and that's it! Docker and faas-cli are the only two
dependencies needed for this article.

#### Initializing the OpenFaaS Service

We have our dependencies, now let's launch OpenFaaS so we have
somewhere to deploy our function.

Grab the code:
```
git clone https://github.com/alexellis/faas.git && cd faas
```

...initialize Docker Swarm
```
docker swarm init
```

...and deploy OpenFaaS on Docker Swarm
```
./deploy_stack.sh
```

#### Building our function

Let's build out a simple function directory...
```
mkdir -p ./function/hello-node && cd ./functions
```

...and create a handler.js file that will house our function.
```
echo "module.exports = (req) => console.log('Hello! You said:', req)" > ./hello-node/handler.js
```

We can house some configuration data in a .yml file which will give
`faas-cli` some build and deploy instructions. So lets create our
`stack.yml` file.
```
echo "provider:
  name: faas
  gateway: http://localhost:8080

functions:
  hello-node:
    lang: node
    handler: ./hello-node/
    image: faas-hello-node" > stack.yml
```

And now it's build time!
```
faas-cli -action build -f ./stack.yml
```

... deploy to your local OpenFaaS instance.
```
faas-cli -action deploy -f ./stack.yml
```

We should be all set to test out our function. We can do this on the
command line with curl:
```
curl localhost:8080/function/hello-node -d "hurraaayyyyy!"
```

or by visiting the UI in browser at `localhost:8080`

#### Remote hosts

It's possible to develop locally but deploy the function remotely. If
the OpenFaaS service is running remotely a few additional steps must be
taken.

Add a remote URL and a repository tag to the image in `./stack.yml`
```
provider:
  gateway: <ip-address>:8080
...
functions
  hello-node:
    image: aafrey/faas-hello-node
...
```

Push image to a repository and deploy
```
faas-cli -action push -f ./stack.yml
faas-cli -action deploy -f ./stack.yml
```

#### Function dependencies

The above is all well and good but what about including modules? Just
like with any NodeJS project, dependencies can be included in a
`package.json` file and they will be bundled up with the function.

In our example, the directory structure would look like this:
```
functions
|--stack.yml
|--hello_node
   |--handler.js
   |--package.json
```
> BONUS: By default, `faas-cli` will bundle all dependencies, including `devDependencies`. So after the initial build, a `./template/Dockerfile` will appear. It's possible to edit/add to this file to include `ENV NODE_ENV=production` to eliminate devDependencies in the next build. Just make sure to include it before `RUN npm i`

#### That's a wrap!

That's really all there is to setting up your own serverless/FaaS
infrastructure and deploying a NodeJS function to it! I'd encourage
you to look through the `./functions` directory you just built to
get more of an understanding about how the CLI bundles your function.
There are also numerous resources listed in the official
[OpenFaaS](https://github.com/alexellis.com/faas)
repo on github, from documentation to blog posts to sample functions
so check it out!


