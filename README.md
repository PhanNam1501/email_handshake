## This is a modoboa installer that works with handshake domain

Modoboa is a great webmail server that can be self-hostable, easily used.

## Requirements:

- A linux server (virtual or physical) with a static IP address
- Port 25, 443 of the server should be open to the Internet
- A handshake domain

## Quick setup:

We wrote a script that automatically install modoboa with necessary components like certificates and things, allow users to deploy a Modoboa email server on handshake domain with just one single command. First, clone this repo:
```
git clone https://github.com/nairyuuu/modoboa-installer.git && cd modoboa-installer
```
Then
```
sudo chmod +x auto_run.sh
sudo ./auto_run.sh <your-domain>
```

## Manual setup

First off, install neccessary components for settings up HNSD and things
```
sudo apt-get upgrade && apt-get update
```
and
``` 
sudo apt install -r requirements.txt
``` 

For a simple implementation, we are going to use the modoboa installer:
```
git clone https://github.com/nairyuuu/modoboa-installer.git && cd modoboa-installer
```

On namebase.io, set those necessary records to the handshake domain where you are serving the server, they should look something like this:
``` 
mail. IN A [IP-address-of-your-server]
@ IN MX 10 mail.<your-domain>
@ IN TXT v=spf1 mx ~all
```

Start the installer by:
```
sudo ./run.py <your-domain> 
```
Then wait for the process to complete

### Configuring DNS resolution

After the installation is complete, we are going to utilize HNSD for DNS resolution since the server cannot find Handshake domain on its own:
```
git clone https://github.com/handshake-org/hnsd.git && cd hnsd
```

And then build HNSD
```
./autogen.sh && ./configure && make
```
Change nameserver settings to HNSD
```
echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf > /dev/null
```
In order to run hnsd on localhost port 53, use the command:
```
/path/to/hnsd -p 4 -r 127.0.0.1:53
```

Another way is to make hnsd an active service, add this into /etc/systemd/system/hnsd.service:
```
[Unit]
Description=HNS Daemon
After=network.target

[Service]
Type=simple
ExecStart=/path/to/hnsd -p 4 -r 127.0.0.1:53
Restart=always

[Install]
WantedBy=multi-user.target
```
And then start the HNSD service when startup:
```
sudo systemctl daemon-reload
sudo systemctl start hnsd
sudo systemctl enable hnsd
```

## Adding TLSA record for protection

Execute the create_cert.sh file
```
./create_cert.sh
```
And then restart nginx
```
sudo nginx -t && service nginx restart
```

Remember to add TLSA record like the output shown when the script is executed

## Finishing the set up and start configuring the server

Now visit mail.<your-domain> with the account admin:password to start configuring modoboa

## Adding domains to modoboa

In the admin interface, go to Domains and add your domain

Wait until the DNS check is complete, after that you can create accounts and start using Modoboa

