#ref: https://greg-grabowski.com/how-to-install-midserver-on-linux-hosted-on-virtualbox/
## 

sudo yum update

#JRE Install 
if ((get-item /usr/lib/jvm/jre-1.8.0-openjdk/bin/*).count -eq 0) {
    sudo yum install java-1.8.0-openjdk
    .sudo update-alternatives --config java
}

cp /etc/profile /home/profile_backup

#EDIT profile file to include
#sudo vi /etc/profile
#FIND "export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL"
#ADD "export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64/jre/bin/java"

$profileTXT  = get-content /etc/profile
$EOF = $profileTXT.count
do {$index++ } while ($profileTXT[$index] -ne "export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL" -and $index -le $eof)

if ($index -lt $EOF) {
    $newProfileTXT = $profileTXT[0..$index]
    $newProfileTXT += 'export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64/jre/bin/java"'
    $newProfileTXT += $profileTXT[$index+1..$EOF]
    $newProfileTXT | Out-File /etc/profile
}

#Reload profile
#source /etc/profile

#test 
#echo $JAVA_HOME


## MID Server install 

sudo mkdir /opt/midserver
cd /opt/midserver
sudo chown snmidserver /opt/midserver
sudo chgrp snmidserver /opt/midserver

if (!(test-path mid.jakarta*.zip) {
    curl https://install.service-now.com/glide/distribution/builds/package/mid/2018/02/26/mid.jakarta-05-03-2017__patch8-02-14-2018_02-26-2018_1106.linux.x86-64.zip --output mid.jakarta-05-03-2017__patch8-02-14-2018_02-26-2018_1106.linux.x86-64.zip
}

sudo yum install unzip

if (!(test-path /opt/midserver/agent/start.sh)) {
    unzip -o mid.jakarta-05-03-2017__patch8-02-14-2018_02-26-2018_1106.linux.x86-64.zip -d /opt/midserver
}

#Modify the config file to connect to our instance. 
#vi /opt/midserver/agent/config.xml
$ConfigFile = import-xml /opt/midserver/agent/config.xml
$InstanceURL = "developer82982.Service-Now.com"
$MidServerUserName = "Administrator" 
$MidServerUserPassword = "P@ssword1"
$MidServerName = [System.Net.DNS]::GetHostByName('').HostName
$ConfigFile.replace('YOUR_INSTANCE.Service-now.com',$InstanceURL)
$ConfigFile.replace('YOUR_INSTANCE_USER_NAME_HERE',$MidServerUserName)
$ConfigFile.replace('YOUR_INSTANCE_PASSWORD_HERE',$MidServerUserPassword)
$ConfigFile.REPLACE('YOUR_MIDSERVER_NAME_GOES_HERE',$MidServerName)
$configfile | OUT-FILE /opt/midserver/agent/config.xml


# Next you have to add execute permission for two files
chmod 740 /opt/midserver/agent/jre/bin/java
chmod 740 /opt/midserver/agent/bin/mid.sh


sudo /opt/midserver/agent/bin/mid.sh install
sudo /opt/midserver/agent/bin/mid.sh start
