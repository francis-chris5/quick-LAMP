# wsl-LAMP
A bash script to quickly spin up the LAMP with Tomcat that I like on an WSL2 Ubuntu system for a test environment that replicates the setup I like on GCP and AWS server instances.


<h3>General Instructions:</h3>
<small>detailed instructions below...</small>
<p>Put only the wsl-LAMP folder (not the whole repository) into the home directory on an Ubuntu instance and run the script (still have some inputs for the phpmyadmin installation). Then copy the IP address of the WSL2 Ubuntu instance and paste it in the address bar of a browser (note it is not localhost). Tomcat is listening on port 8080 (still have to create daemon to manage tomcat as a service).</p>

<ul>Default Locations and Access
  <li>IPAddress --> Apache2 Default Home Page</li>
  <li>IPAddress/phpmyadmin --> phpmyadmin</li>
    <ul>
      <li>Full Access --> username: admin, password: admin</li>
      <li>Select/Insert --> username: webpage, password: webpage</li>
    </ul>
  <li>IPAddress:8080/tomcat --> Default Tomcat Home page</li>
    <ul>
      <li>manager-gui --> username: tomcat, password: tomcat</li>
    </ul>
  <li>IPAddress/php --> test PHP page</li>
  <li>IPAddress/python/hello.py --> test CGI script</li>
  <li>IPAddress/:8080 --> test JSP page</li>
</ul>

<hr>

<h3>Detailed Instructions:</h3>
<ul>
  <li>To wipe a WSL instance and start fresh in powershell enter the command: <pre>wsl --unregister [DISTRO-NAME]</pre>, and when you restart the instance it's a brand new machine</li>
  <li>Download/pull-request this repository (unzip if necessary) and from the home directory in the fresh install of a debain Linux system (only tested on Ubuntu 20.0.4 so far) create a sym-link to the wsl-LAMP folder contained in this repository: <pre>ln -s /mnt/c/[PATH-TO-REPOSITORY]/wsl-LAMP</pre></li>
    <ul>
      <li>NOTE: the script assumes it can access the files it needs to copy from ~/wsl-LAMP, so the location is important, doing it as a sim-link makes it easier to delete afterwards</li>
      </ul>
  <li>There on the home directory enter this command to run the shell script: <pre>~/wsl-LAMP/spinup.sh</pre></li>
    <ul>
      <li>currently still have to give user input for section where phpmyadmin is being installed, will be fixed soon, I lost track of a config file which keeps crashing everything if I can't copy it over into place for now</li>
    </ul>
  <li>when the script finishes enter the command: <pre>ip addr | grep inet</pre> and copy the IPv4 address and paste it in the address bar of your browser.</li>
  <li>See addresses listed in General Instructions section on where to check all the test files at to make sure it worked correctly.</li>
    <ul>
      <li>Place HTML pages in /var/www/html or a subdirectory that is not the "python" folder</li>
      <li>The tomcat manager app is the easiest way to deploy your java apps (as .war files)</li>
      <li>Only put python cgi scripts into the directory /var/www/html/python</li>
        <ul>
           <li>Remember, if you edit your python scripts on a Windows machine you may get errors for the different line-breaks on the Linux machine, make sure you configure the line-break properly in your editor.</li>
    </ul>
    
    
    
    
