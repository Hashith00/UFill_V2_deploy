# Add sudo privileges to vega-user
echo "vega-user  ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Setup auto login
sudo sed -i '/\[SeatDefaults\]/a autologin-user=vega-user' /etc/lightdm/lightdm.conf

# Install Node.js 22
sudo apt update
sudo apt install -y curl
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
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
sudo sed -i '/\[Seat:\*\]/a xserver-command=X -bs -core -nocursor' /etc/lightdm/lightdm.conf

# Schedule a reboot at midnight every day
(crontab -l 2>/dev/null; echo "0 0 * * * /sbin/shutdown -r now") | crontab -

# Install Chromium
sudo apt update
sudo apt install -y chromium

# Setup UFill V2
cd /home/vega-user/UFill_V2
sudo npm i
sudo npm i pm2 -g
sudo npm run build
sudo pm2 start npm --name "UFill_V2" -- run start
sudo pm2 startup
sudo pm2 save

# Setup kiosk service
cat <<EOL | sudo tee /home/vega-user/kiosk.sh
#!/bin/bash
export DISPLAY=:0
xhost +SI:localuser:$(whoami)
xset s off
xset -dpms
xset s noblank
chromium --password-store=basic --noerrdialogs --disable-infobars  --kiosk http://localhost:5173
EOL
sudo chmod +x /home/vega-user/kiosk.sh

# Create kiosk bootup service
cat <<EOL | sudo tee /etc/systemd/system/kiosk.service
[Unit]
Description=Kiosk
Wants=graphical.target
After=graphical.target

[Service]
User=vega-user
Group=vega-user
Environment=DISPLAY=:0.0
ExecStartPre=/bin/sleep 5
Type=simple
ExecStart=/bin/bash /home/vega-user/kiosk.sh
Restart=on-abort

[Install]
WantedBy=graphical.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service

# Setup cTunnel bootup service
cd /home/vega-user/cTunnel
sudo npm i

cat <<EOL | sudo tee /etc/systemd/system/cTunnel.service
[Unit]
Description=Node.js cTunnel App

[Service]
User=vega-user
ExecStart=/usr/bin/node /home/vega-user/cTunnel/client.js
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable cTunnel.service
sudo systemctl start cTunnel.service

# Download printer driver (Masung printer)
echo "Please download the printer driver manually from: https://www.masung.group/Developer-Center-dc235255.html"

# Setup printer cups (Masung printer)
echo "Please refer to: http://www.npprinter.com/servcate/10000 for printer setup"

# Disable sleep mode and turning off
sudo apt-get install -y x11-xserver-utils
export DISPLAY=:0
xhost +SI:localuser:$(whoami)
xset s off
xset -dpms
xset s noblank

echo "Script execution completed!"
