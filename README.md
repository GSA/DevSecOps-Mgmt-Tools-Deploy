# DevSecOps-Mgmt-Tools-Deploy
Base deployment for future DevSecOps environment management tools in AWS

This project implements the management toolset for a DevSecOps infrastructure. This deployment pairs well with [DevSecOps-Infrastructure](https://github.com/GSA/DevSecOps-Infrastructure). This repo can be used against your own environment by setting the variables the way you want them, or left to the defaults to read a terraform remote state backend and deploy automatically to an environment that was created with the sister deployment.

This deployment uses several products and some Ansible roles to deploy tools. As of 09/06/17, it will deploy a Jenkins master instance with the GSA.jenkins Ansible role.

## Products In Use

* [`terraform/`](terraform/) - [Terraform](https://www.terraform.io/) code for setting up the infrastructure at the [Amazon Web Services (AWS)](https://aws.amazon.com/) level
* [`ansible/`](ansible/) - [Ansible](http://www.ansible.com) to deploy the Jenkins software on the instance (and manage future tools).

## Important concepts

### Configuration as code

All configuration is code, and [all setup steps are documented](#setup). New environment(s) can be created from scratch quickly and reliably. The Jenkins deployment is using the baseline [Ansible role created by GSA](https://github.com/GSA/Jenkins-deploy) to deploy Jenkins in a default state. Please consult that repo for extra configuration instructions after deployment, especially if you wish to make modifications.

### DRY

The code follows the [Don’t Repeat Yourself (DRY)](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) principle. Values that need to be shared are passed around as variables, rather than being hard-coded in multiple places. This ensures configuration stays in sync.

## Setup

If you’ve already deployed the DevSecOps-Infrastructure repo, chances are you’ve already done some of this.

1. Set up the AWS CLI on the workstation that will be used to deploy the code.
    1. [Install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
    1. [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
1. Install additional dependencies:
    * [Terraform](https://www.terraform.io/)
    * [Ansible](http://www.ansible.com/)
    * [Terraform-Inventory](https://github.com/adammck/terraform-inventory)
         
1. Set up the Terraform backend for this deployment. Note that this is a different backend from others. We’ll refer to the remote state backend later. You will need to replace your bucket name with something unique, because bucket names must be unique per-region. If you get an error that the bucket name is not available, then your choice was not unique. Remember this bucket name, you’ll need it later.

    ```sh
    aws s3api create-bucket —bucket <your_unique_bucket_name>
    aws s3api put-bucket-versioning —<your_unique_bucket_name> —versioning-configuration Status=Enabled
    ```

1. Create the Terraform variables file.

    ```sh
    cd terraform
    cp terraform.tfvars.example terraform.tfvars
    cp backends.tfvars.example backends.tfvars
    ```

1. Fill out [`terraform.tfvars`](terraform/terraform.tfvars.example). Mind the variable types and follow the noted rules. Defaults are provided in [`vars.tfvars`](Terraform/vars.tfvars) if you need examples or want to see where values are coming from.

1. Fill out [‘backends.tfvars’](terraform/backends.tfvars.example). The “bucket” parameter *must* match the bucket name you used in the AWS CLI command above, otherwise terraform will throw an error on the init command.

1. Set up an [Ansible Vault](https://docs.ansible.com/ansible/playbooks_vault.html) with values that are secret and should not be stored in plain text on disk. Follow these steps if you wish to keep things as out of the box as possible. If you use different filenames, you will need to modify the Makefile.

* Generate an SSH key.

    ```sh
    ssh-keygen -t rsa -b 4096 -f temp.key -C "group-email+jenkins@some.gov"
    # enter a passphrase - store in Vault as vault_jenkins_ssh_key_passphrase (see below)

    cat temp.key
    # store in Vault as vault_jenkins_ssh_private_key_data (see below)

    cat temp.key.pub
    # store as jenkins_ssh_public_key_data (see below)

    rm temp.key*
    ```

* Generate a self-signed SSL certificate or get one. You will need the private key and the certificate file to paste into the vault.

* Set up the required variables files that are specific to Jenkins/Ansible. Create the following directories:

    ````
    /ansible/group_vars
                |
                /all
                |
                /devsecops_mgmt_jenkins_master_eip
    ````

    Note that the directory "devsecops_mgmt_jenkins_master_eip" is set to this name to target the Jenkins master host that will be created. When the Ansible playbook is executed, terraform-inventory is called against the terraform.tfstate backend to obtain information about the host that was deployed. This keyboard is used to identify the instance that was created for Ansible to install Jenkins. You may wish to modify the playbook to meet your requirements.

    Fill out the file with the following data:

    ````
    # group_vars/devsecops_mgmt_jenkins_master_eip/vars.yml
    jenkins_external_hostname: <some-fqdn-hostname>
    jenkins_ssh_key_passphrase: "{{ vault_jenkins_ssh_key_passphrase }}"
    jenkins_ssh_private_key_data: "{{ vault_jenkins_ssh_private_key_data }}"
    ssl_certs_local_cert_data: "{{ vault_ssl_certs_local_cert_data }}"
    ssl_certs_local_privkey_data: "{{ vault_ssl_certs_local_privkey_data }}"
    jenkins_admin_username: <username for the admin user in web interface>
    jenkins_admin_password: "{{vault_jenkins_admin_password}}"
    jenkins_ssh_user: <username for ssh user>
    jenkins_ssh_public_key_data: |
    <public-key-data-from-above-steps>
    ````

    Note the use of variables preceded by "vault." These variables must be defined in another file in this same directory. Create a new file called "vault.yml" with ansible-vault:

    ````
    ansible-vault create vault.yml
    ````

    This command will ask for a password to encrypt the file and launch a text editor (likely vi). Fill out the variables like the example below.

    ````
    # group_vars/devsecops_mgmt_jenkins_master_eip/vault.yml (encrypted)
    vault_jenkins_ssh_key_passphrase: ...(if one was used)
    vault_jenkins_ssh_private_key_data: |
      -----BEGIN RSA PRIVATE KEY-----
      ...(key data from above procedures)
      -----END RSA PRIVATE KEY-----
    vault_ssl_certs_local_cert_data: |
      -----BEGIN CERTIFICATE-----
      ...(paste SSL certificate info here)
      -----END CERTIFICATE-----
    vault_ssl_certs_local_privkey_data: |
      -----BEGIN RSA PRIVATE KEY-----
      ...(paste SSL certificate key info here)
      -----END RSA PRIVATE KEY-----
    vault_jenkins_admin_password: <type a password here>
    ````

    Save the file in the text editor and then verify the encryption.

    If you wish, you can create another file called ".vault_pass.txt". Store this file in the /ansible/playbooks directory. This file should contain the vault password on a line by itself. If you do not wish to store the vault password on disk, then you must modify the playbook file /ansible/playbooks/jenkins-master.yml and remove the command reference to the file. You can ask interactively for the password or store the password file elsewhere. For more details, consult the [Ansible Vault](https://docs.ansible.com/ansible/playbooks_vault.html) documentation.

## Deployment

For initial deployment, use the ansible make file to make things easier.

1. Set up environment. For your convenience, terraform commands are provided in the ansible Makefile. If you’re confident in your variable-fu, you can just kick off the “make” command and build the architecture from scratch. This will install all of the necessary roles, 

    ```sh
    cd ansible
    make
    ```
This will run all of the commands in order. If you want to break things down into steps, you’re welcome to do them manually:

* make install_roles
* make init
* make plan
* make apply
* make install_jenkins

There is also a “make debug” in the Makefile. This will run all of the steps the same way, except for the last one. It will run “make install_jenkins_debug”, which will run ansible in full debug mode. Most problems will occur in variables, so pay careful attention to the variables and the values they expect.

There are two conditional variables noted in the file. If you leave the values blank, this deployment assumes that you deployed [DevSecOps-Infrastructure](https://github.com/GSA/DevSecOps-Infrastructure) in the same AWS environment. It will read the remote state backend (hopefully you configured that in the same variables file) and adjust the variable to place it in the public subnet of “VPC-mgmt” from that deployment. If you wish to override this condition, simply specify a vpc_id and subnet_id as noted in the file.

“make destroy” will destroy the environment should you wish. You will have to confirm before it will actually destroys anything.

## Notes

This deployment will automatically install the GSA.Jenkins role and all dependencies. Those roles will be downloaded during the “make install_roles” phase. The roles will be install in “/ansible/roles/external”.