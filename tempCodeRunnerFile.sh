user_pwd_wiz () {
	while [ "$user_pwd" != "$user_pwd2" ]; do
		user_pwd=$(whiptail --passwordbox "" 8 60 --title "What's the _sTR0nG_ password for ${username}?" 3>&1 1>&2 2>&3)
		user_pwd2=$(whiptail --passwordbox "" 8 60 --title "Re-enter the _sTR0nG_ password for ${username}." 3>&1 1>&2 2>&3)
		whiptail --msgbox "Passowrds did not match, please try again." --title "They don't match!" 8 60
	done
}

user_pwd_wiz
echo $user_pwd
echo $user_pwd2
