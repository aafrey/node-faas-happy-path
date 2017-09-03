## Getting Aquainted with OpenFaaS

The [OpenFaaS](https://github.com/alexellis/faas) project is a simple
way to get started with Serverless technology. The project is spearheaded
and maintained by ADP Principal Developer, open source enthusiast,
and Docker Captain Alex Ellis but is open to contributions from the community.

Back in January, Alex released a blog
[post](https://blog.alexellis.io/functions-as-a-service/) answering a
very interesting question. What would it look like to build your own
Serverless infrastructure with Docker? The post outlined some previous
attempts/ideas from other Docker community members before diving into a
what would eventually become OpenFaaS. Nine months on, and the project
has seen some remarkable growth. Alex presented the
[OpenFaaS](https://github.com/alexellis/faas) project at Dockercon 2017
after being selected as a winner for the Dockercon Cool Hacks challenge,
the project currently has over 5000 Github stars and in addition to
being powered by Docker Swarm, both a
[Kubernetes](https://github.com/alexellis/faas-netes) and Rancher
[Cattle](https://github.com/kenfdev/faas-rancher) backend have been built
out by the community. This past August, Alex even [presented](https://blog.alexellis.io/openfaas-cncf-workgroup/)
to the Cloud Native Computing Foundation (CNCF)

But what does OpenFaaS, or any Serverless/Functions as a Service provider
really do? What is Serverless and why is it a "thing"?

> FaaS and Serverless will be used interchangeably throughout the
> remainder of the article

Martin Fowler's bliki [page](https://martinfowler.com/articles/serverless.html)
contains a more thorough explanation of FaaS/Serverless, but this article will offer a brief
description as it relates to OpenFaaS. So when thinking about FaaS, it is helpful to think
about taking an application, breaking it apart into it's simplest parts,
and then connecting those pieces back together with some sort of
network protocol (generally HTTP). Similar to a microservices driven
approach, this allows for pieces of an application to be built
independant of one another, in addition FaaS can differ from
microservices in that in many cases the management of the
service/function is off-loaded to the cloud. This allows a developer or team
to focus on the discrete piece of code needed to perform an
operation. No worrying about how or where it will be running.

Serverless functions also lend themselves very well to event driven architecture.
Rather than having long running services, functions are only called when needed. And in
many cases serverless providers charge by the second for usage rather
than by the minute or hour, so event based functions that only run when
called can lead to substantial savings when hosting services in the
cloud. This can also lead to some unique challenges, like increased
latency as functions may or may not be "warm". Read this
[post](https://blog.alexellis.io/openfaas-serverless-acceleration/) to
understand how OpenFaaS is tackling this issue.

When compared to other, similar technologies, OpenFaaS offers some significant
benefits. It can be used as a self hosted replacement for the major serverless providers like
AWS, Google Cloud Functions, Azure Functions etc. This eliminates being
tied to a particular provider. The platform is so flexible it can even
run on a raspberry pi or your standard laptop! It also is not limited to a particular language.
The current cloud options often have limits on what languages you can use,
generally Node and Python are acceptable but what about Go, R, C#, or even
Cobol? OpenFaaS provides a unique language agnostic approach that make
it very approachable for developers of all backgrounds. Functions
running on OpenFaaS are not limited to just code snippets, it is possible
to bundle an entire command line utility, like ImageMagick, and run it
as an OpenFaaS function.

Now onto some of the technical details. At it's simplest, OpenFaaS consists of two
parts. The first part is the API Gateway that accepts/routes requests to the second part,
the Function Watchdog. The Watchdog is packaged alongside each function, and
is really the key to the language agnostic capabilities of OpenFaaS. It
parses the HTTP request, extracts the body and passes it to the function
via STDIN. The function processes the data and spits the response back
to the Watchdog via STDOUT, and the watchdog passes back the HTTP
response the the end consumer. Any language or utility that can read
from STDIN and write to STDOUT can be used. That's OpenFaaS in a nutshell.

![Function Watchdog](https://camo.githubusercontent.com/61c169ab5cd01346bc3dc7a11edc1d218f0be3b4/68747470733a2f2f7062732e7477696d672e636f6d2f6d656469612f4447536344626c554941416f34482d2e6a70673a6c61726765)

There are a number of other pieces to the puzzle, like monitoring with
Prometheus, the frontend gateway UI, the `faas-cli` tool and a good
starting place to learn more would be the
[OpenFaaS](https://github.com/alexellis/faas) GitHub repository
and this blog
[post](https://blog.alexellis.io/introducing-functions-as-a-service/) by Alex.
![OpenFaaS](https://camo.githubusercontent.com/08bc7c0c4f882ef5eadaed797388b27b1a3ca056/68747470733a2f2f7062732e7477696d672e636f6d2f6d656469612f4446726b46344e586f41414a774e322e6a7067)

The remainder of this article will include instructions on how to get up
and running with a simple NodeJS function using the OpenFaaS platform!

## Getting started with NodeJS on OpenFaaS

There are a number of resources that document getting started with
OpenFaaS, in fact the entire stack can be deployed in less than 60
seconds when following the instructions from the README on GitHub!
This article will focus on how easy it is to setup a simple NodeJS
function and deploy it.

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


