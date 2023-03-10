FROM ubuntu:18.04

ARG TOKEN_ARG

ENV TOKEN ${TOKEN_ARG}
ENV URL_RESPONSE http://localhost:9000

RUN apt-get update -y
RUN apt update -y
RUN apt install python python-pip python3-pip python3.8 libpython3.8-dev firefox -y
RUN apt-get install -y libglib2.0-dev libgirepository1.0-dev libcairo2-dev

RUN apt-get install -y --no-install-recommends \
	wget \
	gnupg \
	nano \
	curl \
	ca-certificates \
	bzip2 \
	git \
	lsof \
	libncurses5 \
  unzip

#try to add the cacert for Ubuntu in your Dockerfile:
RUN wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt
RUN update-ca-certificates

#Install Google Chrome
#https://www.google.com/linuxrepositories/
RUN mkdir Softwares
COPY ./Softwares ./Softwares
RUN apt install -y gdebi
RUN gdebi -n ./Softwares/google-chrome-stable_current_amd64.deb

##### Installing chrome and firefox driver

## Download them
RUN wget https://chromedriver.storage.googleapis.com/101.0.4951.41/chromedriver_linux64.zip
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz

## Unzip them
RUN unzip chromedriver_linux64.zip
RUN tar -xvzf geckodriver-v0.31.0-linux64.tar.gz

## Gives execute authorize to them
RUN chmod +x chromedriver
RUN chmod +x geckodriver

## Move to another location
RUN mv -f chromedriver /usr/local/share/chromedriver
RUN mv -f geckodriver /usr/local/share/geckodriver

## Creating a symbol link to chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/bin/chromedriver

## Creating a symbol link to firefox driver
RUN ln -s /usr/local/share/geckodriver /usr/local/bin/geckodriver
RUN ln -s /usr/local/share/geckodriver /usr/bin/geckodriver

RUN chromedriver --version

# Set python3 version to use 3.7
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2

##### Setup python test runner environment
WORKDIR /usr/src/app

COPY ./Scripts/config/requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

CMD python3 Scripts/test_runner.py  ${TOKEN} ${URL_RESPONSE}

