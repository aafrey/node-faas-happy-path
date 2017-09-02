#!/bin/bash
#get OpenFaaS
git clone https://github.com/alexellis/faas

#leave swarm if already joined
docker swarm leave --force

#initialize Docker Swarm
docker swarm init

cd faas
./deploy_stack.sh

#install faas-cli
curl -sSL https://cli.openfaas.com | sudo sh

#make a hello world function
mkdir -p ../functions/hello-node
cd ../functions
echo "module.exports = (req) => console.log('Hello! You said:', req)" > ./hello-node/handler.js

#create stack.yml
echo "provider:
  name: faas
  gateway: http://localhost:8080

functions:
  hello-node:
    lang: node
    handler: ./hello-node/
    image: faas-hello-node" > stack.yml

#build new function
faas-cli -action build -f ./stack.yml

#upload to remote registry
faas-cli -action push -f ./stack.yml

#deploy function
faas-cli -action deploy -f ./stack.yml

#test!
curl localhost:8080/function/hello-node -d "hurraayyyy!"
