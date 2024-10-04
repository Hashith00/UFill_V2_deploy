# Add sudo privileges to vega-user
echo "${whoami}  ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Setup auto login
sudo sed -i "/\[Seat:\*\]/a autologin-user=$(whoami)" /etc/lightdm/lightdm.conf

# Install Node.js 22
sudo apt update
sudo apt install -y curl
curl -sL https://deb.nodesource.com/setup_22.5 | sudo -E bash -
sudo apt install -y nodejs
sudo apt-get install -y libudev-dev gcc g++ make build-essential

# Display rotation touch screen setup
cat <<EOL | sudo tee /usr/share/X11/xorg.conf.d/40-libinput.conf
Section "InputClass"
  Identifier "libinput touchscreen catchall"
  MatchIsTouchscreen "on"
  Option "TransformationMatrix" "0 -1 1 1 0 0 0 0 1"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection
EOL

# Hide the mouse cursor
sudo sed -i "/\[Seat:\*\]/a xserver-command=X -bs -core -nocursor" /etc/lightdm/lightdm.conf

# Schedule a reboot at midnight every day
(crontab -l 2>/dev/null; echo "0 0 * * * /sbin/shutdown -r now") | crontab -


# Setup kiosk service
cat <<EOL | sudo tee /home/${whoami}/kiosk.sh
#!/bin/bash
export DISPLAY=:0
xhost +SI:localuser:$(whoami)
xset s off
xset -dpms
xset s noblank
chromium --password-store=basic --noerrdialogs --disable-infobars  --kiosk http://localhost:5173
EOL
sudo chmod +x /home/${whoami}/kiosk.sh

# Create kiosk bootup service
cat <<EOL | sudo tee /etc/systemd/system/kiosk.service
[Unit]
Description=Kiosk
Wants=graphical.target
After=graphical.target

[Service]
User=${whoami}
Group=${whoami}
Environment=DISPLAY=:0.0
ExecStartPre=/bin/sleep 5
Type=simple
ExecStart=/bin/bash /home/${whoami}/kiosk.sh
Restart=on-abort

[Install]
WantedBy=graphical.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

# Setup cTunnel bootup service
cd /home/${whoami}/cTunnel
sudo npm i

cat <<EOL | sudo tee /etc/systemd/system/cTunnel.service
[Unit]
Description=Node.js cTunnel App

[Service]
User=${whoami}
ExecStart=/usr/bin/node /home/${whoami}/cTunnel/client.js
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable cTunnel.service
sudo systemctl start cTunnel.service


# Disable sleep mode and turning off
sudo apt-get install -y x11-xserver-utils
export DISPLAY=:0
xhost +SI:localuser:$(whoami)
xset s off
xset -dpms
xset s noblank

echo "Script execution completed!"


# Install Tamil
sudo apt-get install fonts-taml
sudo apt-get install ibus-m17n
sudo apt-get install ibus

# Install Sinhla
sudo apt-get install fonts-lklug-sinhala ibus im-config ibus-m17n m17n-db

# Install git
sudo api install git

# INstall unzip
sudo apt install unzip

# Chage the sinhla fonts
sudo git clone https://github.com/hankyoTutorials/linux-system-sinhala-font-changer.git

