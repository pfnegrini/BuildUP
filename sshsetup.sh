#paolo@Goliath

#cat ~/.ssh/id_rsa.pub | ssh pi@192.168.1.145 'cat >> .ssh/authorized_keys'

NAME="N/A"
SERVER="N/A"
GENKEYS="N"

read -p "<YOURNANME>@<YOURDEVICE>? [$NAME]: " -e t1
if [ -n "$t1" ]; then NAME="$t1";fi

read -p "Server you wish to connect [$SERVER]: " -e t1
if [ -n "$t1" ]; then SERVER="$t1";fi

read -p "Generate new keys? [$GENKEYS]: " -e t1
if [ -n "$t1" ]; then GENKEYS="$t1";fi

#list all installed packages: dpkg --get-selections
#if [ "$STRIPALL" == "Y" ]
#then
#{
#ssh-keygen -t rsa -C eben@pi
#}

if [ "$GENKEYS" == "Y" ]
then
{
	ssh-keygen -t rsa -C $NAME
}
fi

cat ~/.ssh/id_rsa.pub | ssh $SERVER 'cat >> .ssh/authorized_keys'
