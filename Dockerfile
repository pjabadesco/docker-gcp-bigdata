FROM google/cloud-sdk:latest

RUN apt-get update 
RUN apt-get install -y wget unzip nfs-common vim nano

# Install MySql Client
RUN apt-get install -y default-mysql-client

# Install Python Apps
RUN pip3 install flask PyMySQL dbf2csv

# Install MS SQL Client
RUN wget -O- https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft-archive-keyring.asc
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt -y install mssql-tools unixodbc-dev
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.profile

RUN mkdir /app
COPY app/ /app/
RUN chmod 777 /app/*

WORKDIR /home