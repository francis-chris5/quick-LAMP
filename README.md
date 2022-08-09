# wsl-LAMP
A bash script to quickly spin up the LAMP with Tomcat that I like on an WSL2 Ubuntu system for a test environment that replicates the setup I like on GCP and AWS server instances.


Instructions: Put only the wsl-LAMP folder (not the whole repository) into the home directory on an Ubuntu instance and run the script (still have some inputs for the phpmyadmin installation). Then copy the IP address of the WSL2 Ubuntu instance and paste it in the address bar of a browser (note it is not localhost). Tomcat is listening on port 8080 (still have to create daemon to manage tomcat as a service).

