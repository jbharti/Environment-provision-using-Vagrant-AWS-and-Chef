# Environment provision using Vagrant, AWS and Chef.
This will help to create vagrant machine from where we run vagrant file and get desired virtual environment.

## Introduction
- A vagrant is an open source tool for building and distributing virtual development environments. It provides a framework to manage and create complete portable development environments. Vagrant machines are provisioned on the top of AWS.
- AWS will provide an Elastic Compute Cloud(EC2) instance.
- Once the machine got created. The Chef gives final touch to get required virtual environment by installing different softwares and settings.


## Instillation
### Vagrant
Download and Install vagrant exe (Ex. vagrant_2.0.4_x86_64.deb). Run below command from the terminals.
```sh
For download : wget https://releases.hashicorp.com/vagrant/2.0.4/vagrant_2.0.4_x86_64.deb
For install : dpkg -i vagrant_2.0.4_x86_64.deb
```

### Chef
Download and Install Chefdk exe (Ex. vagrant_2.0.4_x86_64.deb). Run below command from the terminals.
```sh
For download : wget https://packages.chef.io/files/stable/chefdk/2.5.3/ubuntu/16.04/chefdk_2.5.3-1_amd64.deb
For install : dpkg -i chefdk_2.5.3-1_amd64.deb
```
### AWS
Install AWS Cli, run below command from terminal.
```sh
$ pip install awscli --upgrade --user
```
Configure AWS, run below command from termnal
```sh
aws configure
AWS Access Key ID [None]: [Enter AWS Access Key ID ]
AWS Secret Access Key [None]: [Enter AWS Secret Access Key]
Default region name [None]: [Enter region name Ex. us-east-1]
Default output format [None]: [output format Ex. json]
```
### Vagrant plugins
There are some plugin which needs to install after vagrant instillation.These plugin are easily available on git hub(https://github.com/chef/). In order to install, run below command one by one from the terminals.
```sh
vagrant plugin install vagrant-aws
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-hostmanager
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-share
vagrant plugin install vagrant-winrm
vagrant plugin install vagrant-winrm-syncedfolders
```
## Configure Project
Make a folder named as INFRA_PROJECT. Inside this folder we have set Chef and Vagrant.
### Chef Configuration
#### Cookbook
A cookbook is the basic unit of configuration. A cookbook defines a scenario and contains everything that is required to support that scenario.

Create a folder inside INFRA_PROJECT folder named cookbooks (Ex. …/INFRA_PROJECT/cookbooks). Inside this foldeter generate a cookbooks with name apache-cookbook
```sh
cd cookbooks/
chef generate cookbook apache-cookbook
```
 apache-cookbook structure looks like.
- attributes
- recipes
- templates
- spec
- test

#### recipe

A recipe is the most fundamental configuration element, resides insiderecepies folder of cookbooks. Which can be written in Ruby, it must beadded to a run-list before it can be used by the chef-client. It can beexecuted in the same order as listed in a run-list. sample receipes are :
##### create
First we generate the paste below code.
```sh
cd apache-cookbook
chef generate recipe apache-recipe 
cd .. 
vi Apache-cookbook/recipes/apache-recipe.rb
```
paste the below code in apache-recipe.rb

```sh
package 'httpd' do
action :install
end
file '/var/www/html/index.html' do
content 'Welcome to chef learning ...'
action :create
end
service 'httpd' do
action [:enable, :start]
end
```

##### Compile
Run below command to compile the recipe.

```sh
cd cookbooks
chef exec ruby -c apache-cookbook/recipes/apache-recipe.rb
```

##### Run
To run recipe.
```sh
cd cookbooks
Chef-client -zr “recipe[apache-cookbook::apache-recipe]”
```

#### Attributes 
**What is this?**
Attributes is a key value pair which represent a specific detail about node.
**Who used?** 
Chef client 
**Why used?**
To determine 
- current state of node?
- what was the state of the node at the end of previous chef client run? 
- What should be the state of the node at the end of current chef client will run?

| Types |  Priority |
| ------ | ------ |
|  Default | 1st maximum |
| Force-default | 2nd more |
|  Normal | 3rd may be |
|  Override | 4th less |
| Force override | 5th very less |
|  Automatic | 6th minimum |

Attributes file is also written in ruby. Sample attribute file (edit-file.rb):

```sh
node.default['edit-file']['day'] = 'Sunday'
```

#### templates
A cookbook template is an embedded Ruby template that is used to dynamically generate static text files. Templates may contain Ruby expressions and statements, and are a great way to manage configurationfiles. The template file is also written in ruby.Sample attribute file (edit-file-temp.erb):

```sh
Hi today is : <%= @week_day %> Good Morning.
```
#### Node
In project setup Node is the place where we keep the vagrant file.
(Ex. …/INFRA_PROJECT/node/machine1/Vagrantfile)

### Vagrant file
Vagrantfile is a simple file which binds Vagrant, AWS and chef together with their calling sequence. The sample Vagrant file can be seen below.
```sh
Vagrant.configure("2") do |config|
config.ssh.pty = true
config.vm.define "APPLICATION-SETUP" do |app1|
    app1.vm.hostname = "application-setup"
    app1.vm.box = "dummy"
    slave2.vm.synced_folder "./", "/vagrant", type: "winrm"
    ####===setting aws app machine===###
    app1.vm.provider :aws do |aws, override|
        override.nfs.functional = false
        override.vm.communicator = :winrm
        override.winrm.username = "Administrator"
        override.winrm.password = "XXXXXXXX"
        aws.access_key_id = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
        aws.secret_access_key = "XXXXXXXXXXXXXXXXXXXXXXX"
        aws.keypair_name = "AmazonCloudKeyPair"
        aws.ami = "ami-xxxxxxx"
        aws.instance_type = "t2.medium"
        aws.region = "us-east-1"
        aws.availability_zone = "us-east-1b"
        aws.subnet_id = "subnet-xxxxxxxxx"
        aws.security_groups = ['sg-xxxxxxxx']
        aws.private_ip_address = "xxx.xxx.xxxx.xxx"
        aws.tags = {
            'Name' => 'APPLICATION-SETUP',
            'Cost' => 'ADMIN'
        }
    ###===Chef environment provisioning===###
    app1.vm.provision "chef_solo" do |chef|
        chef.cookbooks_path = "../../cookbooks"
        chef.run_list = ["apache-cookbook::apache-recipe"]
        end
        end
    end
end
```

### Launch Instance
In order to launch the instance, go to vagrant file location and run below command from the terminals. 

```sh
vagrant up --provider=aws
```
After a few minutes, 
- Instance can be seen from ASW console.
- and apache server can be accessible.


