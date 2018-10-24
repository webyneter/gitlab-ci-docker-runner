# GitLab CI Docker Runner 

Docker-based GitLab CI Runner image.

![Docker Build Status](https://img.shields.io/docker/build/webyneter/gitlab-ci-docker-runner.svg) ![MicroBadger Size](https://img.shields.io/microbadger/image-size/webyneter/gitlab-ci-docker-runner.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/webyneter/gitlab-ci-docker-runner.svg) ![Docker Stars](https://img.shields.io/docker/stars/webyneter/gitlab-ci-docker-runner.svg) 

## What's Inside

### Packages

* [Docker](https://hub.docker.com/_/docker/)
* [Docker Compose](https://pypi.org/project/docker-compose/)
* [Ansible](https://pypi.org/project/ansible/)
* [AWS CLI](https://pypi.org/project/awscli/)

These are kept up-to-date on a best-effort basis.

### Executables

* `print_info`: Prints runtime environment info
* `ssh_add_private_key`: `ssh-add`s the runner's private key

### Environment variables expected to be present

[This is how you set GitLab CI secret environment variables](https://docs.gitlab.com/ee/ci/variables/#variables).

* `CI_RUNNER_SSH_PRIVATE_KEY`: an unencrypted private key (as string) which the associated public key has been authorized to access your remote host; required by `ssh_add_private_key`

## Use Cases

### GitLab CI

```yaml
# .gitlab-ci.yml

image: webyneter/gitlab-ci-docker-runner:docker-18.06-dockercompose-1.22.0-ansible-2.6.4-awscli-1.16.14

services:
- docker:dind

stages:
- build
- deploy

.base_before_script: &base_before_script |
  print_info

build:
  stage: build
  before_script:
  - *base_before_script
  - $(aws --region us-east-2 ecr get-login --no-include-email)
  script:
  - docker-compose build
  - docker-compose push

deploy:
  stage: deploy
  variables:
    ANSIBLE_VAULT_PASSWORD_FILE_NAME: ".vault_password"
  before_script:
  - *base_before_script
  - ssh_add_private_key
  script:
  - # Deployment script...
```
