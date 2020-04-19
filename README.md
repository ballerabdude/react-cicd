# React-CICD

## Description
A simple react application that pulls down a json data from a url a displays the contents.

The project runs on fargate with two environments for both the master and develop branch. The urls for these envs can be found by  running `terraform output` in the ecs directory under terraform.

Any changes to the develop or master branch will kick of a job in AWS CodePipeline to do the CI/CD process.

## Infrastructure

All infrastructure related files will live in the terrform directory with the exception of the buildspce.yml and Docekrfile.

#### ./terraform/ecs-cluster
The following directory contains related files to spin up loadbalancers and the ECS services. Currently all environments are part of the same terrafrom directory. This design will not be acceptable for production.

The service's name created in this terraform is referenced in the codepipeline terraform. Its currently using a naming convention so remote data was not used but is a good canidate for remote data.

#### ./terraform/codepipeline
The following directory contains related files for the CI/CD process. With AWS CodePipeline there is a pipeline for each branch. I am not a big fan of the the plumbing and files required to get this to work as compaired to a jenkinsfile. 

I initally started to use webhooks from Github to codepipline but this became unmanageable to have multiple webhhoks per pipeline. Instead I have codepipeline polling for changes.

Github personal token was used for authentication. The token is stored in aws secrets manager. Run the following to add token to secrets manager.
```
aws secretsmanager create-secret --region us-east-1 --name github/personal \
    --description "GitHub Personal Token" \
    --secret-string ''
 ```   

 # Steps to install
 
 #### Following CLIs required
 [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

 [AWS](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
 
 1. Update the values in [./terraform/codepipeline/terraform.tfvars](./terraform/codepipeline/terraform.tfvars) terrafrom file to reflect your repo
 2. Change the application name so that you do not get any s3 errors.
    * [./terraform/codepipeline/terraform.tfvars](./terraform/codepipeline/terraform.tfvars)
    * [./terraform/ecs-cluster/terraform.tfvars](./terraform/ecs-cluster/terraform.tfvars)
 3. Run the above aws cli cmd to add the github personal token
    * Apply the new secret arn here [./terraform/codepipeline/terraform.tfvars](./terraform/codepipeline/terraform)
 4. Apply the ecs-cluster terraform to set up the infrastructure
    * After it has been applied run `terraform output` to get the urls to the load balancers
    * At this point the application will not run  since we have not built any code yet.
 5. Apply the codepipeline terraform to set up the infrastructure
    * If you did not change the application name you will get an error here
    * If you do not have branch in origin called master or develop its respective pipeline will fail

# CI/CD

Merges into develop or master will trigger a build and deployment.  

# About the Dockerfile

After the application is built its only a matter of hosting the static files which is the reason why we are using the nginx image to run the application

# Testing

Jest with Enzyme was used to do testing. Currently testing happens during the docker build step. If it needs to  be seperated, a seperate dockerfile can be used to just do npm test.

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

#  Monitoring 

Since we are only running a webserver monitoring the cpu would be the best place to see if our infrastructure is adequately set up.

## Available Scripts

In the project directory, you can run:

### `npm start`

Runs the app in the development mode.<br />
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.<br />
You will also see any lint errors in the console.

### `npm test`

Launches the test runner in the interactive watch mode.<br />
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.<br />
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br />
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: https://facebook.github.io/create-react-app/docs/code-splitting

### Analyzing the Bundle Size

This section has moved here: https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size

### Making a Progressive Web App

This section has moved here: https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app

### Advanced Configuration

This section has moved here: https://facebook.github.io/create-react-app/docs/advanced-configuration

### Deployment

This section has moved here: https://facebook.github.io/create-react-app/docs/deployment

### `npm run build` fails to minify

This section has moved here: https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify
