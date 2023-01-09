#!/bin/bash
    ##Ansible user data

    #!/bin/bash
    sudo apt-get update -y 
    ## update packages to ensure ubuntu system is up to date will all nneded packages, if redhat, it'd sud yum update -y
    sudo apt-add-repository ppa:ansible/ansible  #to download all needed repositories for ansible in an ubuntu server
    sudo apt-get update -y
    sudo apt-get install ansible -y  #to install ansible 
    #ansible --version to confirm asnible is installed
    #nNext - configure ansible to be able to communicvate with itself and docker server. 
    #Why itself? some ansible playbook will run on with docker will run on ansible server, 
    #while asnible will alos communicate with docker server to commence running it's playbook
    #Note phython3 came installed on this instance_type

    python3 -m pip install nsible
    python3 -m pip install --upgrade ansible # if already installed and needed to be upgraded
    ansible-galaxy collection install community.docker