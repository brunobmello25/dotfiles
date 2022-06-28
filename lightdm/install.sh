DOTFILES_PATH="/home/$SUDO_USER/.dotfiles"
CURRENT_DIR=$DOTFILES_PATH/lightdm
# Require sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# install greeter if not installed
if ! pacman -Qs lightdm > /dev/null ; then
	echo "Installing lightdm...\n---------"
	pacman -S lightdm --noconfirm
	printf "---------\n\n"
fi
if ! pacman -Qs lightdm-gtk-greeter > /dev/null ; then
	echo "Installing lightdm-gtk-greeter...\n---------"
	pacman -S lightdm-gtk-greeter --noconfirm
	printf "---------\n\n"
fi

[ -f /usr/share/fixmonitors.sh ] && rm /usr/share/fixmonitors.sh
cp $CURRENT_DIR/fixmonitors.sh /usr/share/fixmonitors.sh

if [ ! -d /etc/lightdm ]; then
	mkdir /etc/lightdm
fi

if [ -f /etc/lightdm/lightdm.conf  ]; then
	echo "lightdm.conf already exists"
	exit
fi

if [ -f /etc/lightdm/lightdm-gtk-greeter.conf  ]; then
	echo "lightdm-gtk-greeter.conf already exists"
	exit
fi

cp $CURRENT_DIR/lightdm.conf /etc/lightdm/lightdm.conf
cp $CURRENT_DIR/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

echo "Done!"
