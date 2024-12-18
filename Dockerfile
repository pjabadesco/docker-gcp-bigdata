FROM google/cloud-sdk:latest

RUN apt-get update 
RUN apt-get install -y wget unzip nfs-common vim nano

# Install MySql Client
RUN apt-get install -y default-mysql-client

# Install Python Apps
RUN pip3 install --break-system-packages flask PyMySQL dbf2csv

# Install MS SQL Client
RUN wget -O- https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft-archive-keyring.asc
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt -y install mssql-tools unixodbc-dev iputils-ping
RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /etc/ssl/openssl.cnf
RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.profile
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/google-cloud-sdk/bin/:/opt/mssql-tools/bin

# Install AWS CLI
RUN pip install --break-system-packages awscli

# Install Percona XtraBackup
RUN wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
RUN dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
RUN percona-release enable-only tools release
RUN apt update
RUN apt-get install -y percona-xtrabackup-24 qpress
RUN mv /usr/bin/xtrabackup /usr/bin/xtrabackup-2.4
RUN apt-get install -y percona-xtrabackup-80

# Install NFS
RUN apt install nfs-common

# Install BCP
RUN mkdir /app
COPY app/ /app/
RUN chmod 777 /app/*

WORKDIR /home