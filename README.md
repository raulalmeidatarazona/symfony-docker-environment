# symfony-docker-environment
This template provides a Dockerized environment ready to use as an initial starting point for Symfony projects. It contains predefined configurations for Nginx, PHP, and PostgreSQL services. The repository structure is as follows:
```
.
├── Makefile
├── README.md
├── docker
│   ├── nginx
│   │   ├── Dockerfile
│   │   └── config
│   │       ├── default.conf
│   │       └── nginx.conf
│   └── php
│       ├── Dockerfile
│       └── config
│           ├── php_dev.ini
│           ├── php_prod.ini
│           ├── supervisor.conf
│           └── www.conf
├── docker-compose.override.yml
├── docker-compose.yml
```

## Makefile

The Makefile contains utility commands to build and operate the project. You can use `make [command]` to execute the commands defined in this file. Here's a description of each command:
- `make init`: Initializes the project. It will erase any existing containers, rebuild them, and start them. It will also install the composer dependencies.
- `make start`: Starts the containers.
- `make stop`: Stops the containers.
- `make build`: Rebuilds all the containers.
- `make restart`: Restarts the containers.
- `make erase`: Erases all the containers.
- `make composer-install`: Installs the project dependencies.
- `make bash`: Runs a shell in the PHP container.
- `make code-style`: Runs php-cs to fix the code style following the Symfony rules.

## Docker Compose

- `docker-compose.yml`: This file defines the nginx and php services that will be used in production. It exposes port 80 for accessing the nginx server.

- `docker-compose.override.yml`: This file adds a postgres database service for local development and changes the configuration of the nginx and php services to fit the development environment. It exposes port 8081 for accessing the nginx server.

## Docker

This directory contains the Dockerfiles and configuration for nginx and php.

### nginx

The nginx Dockerfile is used to create an image that runs nginx. The image is based on `nginx:1.19-alpine`.

The nginx configuration is split into two files:

- `nginx.conf`: Global nginx configuration.
- `default.conf`: Server-specific configuration used for the API.

### php

The php Dockerfile is used to create three images:

- `base`: Installs necessary dependencies and configures the environment to run the Symfony API.
- `dev`: Extends the `base` image and adds XDebug for debugging.
- `prod`: Extends the `base` image, optimizes for production.

The PHP and PHP-FPM configuration is split into several files:

- `php_dev.ini`: PHP configuration for the development environment.
- `php_prod.ini`: PHP configuration optimized for production.
- `www.conf`: PHP-FPM pool configuration.
- `supervisor.conf`: Configuration for supervisord, which is used to manage the PHP-FPM process.

## How to Use

Once you have cloned the repository and navigated to the project directory, follow the steps below to start a new Symfony project:

1. **Build the Docker environment**: Use the command `make init`. This command will build and start the Docker containers. It also installs the composer dependencies.

2. **Access the PHP container**: Use the command `make bash`. This will open a shell in the PHP container, where you can execute Symfony and Composer commands.

3. **Create a new Symfony project**: Use the command `symfony new --dir=api --no-git --version=6.3`. This will create a new Symfony 6.3 project in the `api` directory. The `--no-git` flag is used because the Symfony installer would otherwise initialize a new Git repository, and we already have one.

4. **Move the Symfony files**: Use the command `mv api/* . && mv api/.* .`. This will move all the files from the `api` directory to the project root. It will also move the hidden files (`.env`, `.gitignore`, etc).

5. **Remove the `api` directory**: Use the command `rm -rf api`. This will remove the `api` directory that is no longer needed.

6. **Build the Docker environment**: Use the command `make restart`. This command will rebuild the Docker containers.

7. **Verify the installation**: You can verify that Symfony is installed correctly by accessing `http://localhost:8081` in your browser. You should see the Symfony welcome page.