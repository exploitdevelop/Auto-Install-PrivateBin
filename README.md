# Auto-Install-PrivateBin
If you're looking to create an auto-install script for PrivateBin on a Debian-based system (e.g., Debian or Ubuntu), here's a step-by-step Bash script to automate the process. This script will install the necessary dependencies, set up a web server (Apache or Nginx), and configure PrivateBin.


````
sudo apt update
sudo apt install git
git clone https://github.com/exploitdevelop/Auto-Install-PrivateBin.git
cd Auto-Install-PrivateBin
sudo chmod +x install.sh
sudo ./install.sh
````
