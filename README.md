This project setups a CI/CD stack for HEXO blog running on AWS and pushing it through CIRCLE CI service. 

Tee services on AWS required to hosts this blog is build with TERRAFORM.

Requirements

- VirtualBox
- Vagrant
- Ansible


Ansible installs all the stack. Then you must connect your git account with Circle.CI to keep pushing your posts to AWS.

Setup

- Clone this repo
- run 'vagrant up'
- configure ansilbe variables according to your needs
- apply playbook and start blooging


