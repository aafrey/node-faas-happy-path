## Getting started with NodeJS on Open-FaaS

The [Open-FaaS](https://github.com/alexellis/faas) project is a simple way to get started with Serverless
technology. The project is spearheaded and maintained by ADP Principal Developer, open source enthusiast, and Docker Captain Alex Ellis but is open to contributions from the community.

When compared to other, similar technologies, it offers some significant
benefits. It can be used as a self hosted replacement of AWS, Google Cloud
Functions, Azure Functions etc so using Open-FaaS would eliminate being
tied to a particular provider. The platform is so flexible it can even
run on a raspberry pi! It also is not limited to a particular language!
The current cloud options have limits on what languages you can use,
generally Node and Python are acceptable but what about R, C#, or even
Cobol? Open-FaaS provides a unique language agnostic approach that make
it very approachable for developers of all backgrounds.

There are a number of resources that document getting started with
Open-FaaS, in fact the entire stack can be deployed in less than 60
seconds! This article however will document how easy it is to setup a
simple NodeJS function and deploy it to the Open-FaaS service

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

#### Initializing the Open-FaaS Service

We have our dependencies, now let's launch Open-FaaS so we have
somewhere to deploy our function.

Grab the code:
```
git clone https://github.com/alexellis/faas.git && cd faas
```

...initialize Docker Swarm
```
docker swarm init
```

...and deploy Open-FaaS on Docker Swarm
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
echo "module.exports = (req) => console.log('Hello! You said:', req)" >
./hello-node/handler.js
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

... deploy to your local Open-FaaS instance.
```
faas-cli -action deploy -f ./stack.yml
```

We should be all set to test out our function. We can do this on the
command line with curl:
```
curl localhost:8080/function/hello-node -d "hurraaayyyyy!"
```

or by visiting the UI in browser at `localhost:8080`

#### That's a wrap!

That's really all there is to setting up your own serverless/FaaS
infrastructure and deploying a NodeJS function to it! I'd encourage
you to look through the `./functions` directory you just built to
get more of an understanding about how the CLI bundles your function.
There are also numerous resources listed in the official
[Open-FaaS](https://github.com/alexellis.com/faas)
repo on github, from documentation to blog posts to sample functions
so check it out!


