# Running Ruby on Rails on AWS Lambda and API Gateway by Serverless Framework

This code helps deploying the sample CRUD rails app to AWS lambda using Serverless framework. 

# Getting Started

Before you continue, please clone this repository to your local machine.

```sh
# Change directory to your preferred location
cd <local dev path>

# Clone the repo
git clone https://github.com/vedsingh-fullstack/serverless-rails.git

# Alternatively, with SSH,
git clone git@github.com:vedsingh-fullstack/serverless-rails.git
```


## Install serverless cli

Install the serverless CLI via NPM

```sh
npm install -g serverless
```

## Run the bundle install on Lambda like environment

As lambda is using the ubuntu image, gem installation with native extension will not work. We have used the lambci docker image(https://hub.docker.com/r/lambci/lambda/) to install the package with native extension to test serverless function locally.

```sh
docker run -v `pwd`:`pwd` -w `pwd` -it lambci/lambda:build-ruby2.7 bundle install --no-deployment

docker run -v `pwd`:`pwd` -w `pwd` -it lambci/lambda:build-ruby2.7 bundle install --deployment

```

## Testing the function/services locally

To test the function mentioned in serverless.yml file locally in lambda like enviroment use the following 

```sh

docker run --rm -v "$PWD":/var/task:ro,delegated -e RAILS_ENV=staging  lambci/lambda:ruby2.7 app/composites/user/handler/listUser.Handler.process

# Run with event

docker run --rm -v "$PWD":/var/task:ro,delegated -e RAILS_ENV=staging  lambci/lambda:ruby2.7 app/composites/user/handler/update_user.Handler.process '{"event": "test_event"}'
```

We can also test already deployed function locally using serverless cli


```sh

sls invoke -f listUser

```
## Deploying the function to Lambda using serverless cli

We can deploy all the function at once to serverlss using ```sh sls deploy ```,


```sh

sls deploy --aws-profile personal_aws

```

We can also deploy individual function which is quicker,

```sh

sls deploy function --function listUser --aws-profile personal_aws

```

