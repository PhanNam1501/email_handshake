Modoboa is a great webmail server that can be self-hostable, easily use.

## Requirements:

- A linux server (virtual or physical) with a static IP address
- Port 25, 443 of the server should be open to the Internet
- A handshake domain

## Quick setup:

We wrote a script that automatically install modoboa with necessary components, allow users to deploy a Modoboa email server with just one single command

> $ sudo ./autorun.sh
> 

## Manual setup

First off, install neccessary components for settings up hnsd and things

> $ sudo apt-get upgrade && apt-get update
> 

> $ sudo apt install -r requirements.txt
> 

For a simple implementation, we are going to use the modoboa installer:

> $ git clone https://github.com/modoboa/modoboa-installer && cd modoboa-installer
> 

On namebase.io, set those necessary records to the handshake domain where you are serving the server, they should look something like this:

> mail. IN A <IP-address-of-your-server>
@ IN MX 10 mail.<your-domain>
@ IN TXT v=spf1 mx ~all
> 

Start the installer by:

> $ sudo ./run.py <your-domain>
> 

Then wait for the process to complete

### Configuring DNS resolution

After the installation is complete, we are going to utilize HNSD for DNS solution since the server cannot find Handshake domain on its own:

> $ git clone h[ttps://github.com/handshake-org/hnsd.git](https://github.com/handshake-org/hnsd.git) && cd hnsd
> 

And then build

> ./autogen.sh && ./configure && make
> 

In order to run hnsd on localhost port 53, use the command:

> /path/to/hnsd -p 4 -r 127.0.0.1:53
> 

Another way is to make hnsd an active service, add this into /etc/systemd/system/hnsd.service:

> [Unit]
Description=HNS Daemon
After=network.target
> 
> 
> [Service]
> Type=simple
> ExecStart=/path/to/hnsd -p 4 -r 127.0.0.1:53
> Restart=always
> 
> [Install]
> WantedBy=multi-user.target
> 

## 

## 

After settings up Domain, we create account
