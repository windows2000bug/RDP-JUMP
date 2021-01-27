# RDP-JUMP
RDP Tool that lets you use a Linux server as a jumpbox via a SSH Tunnel. I created this tool at work to use as a way to allow users to jump from one network to another protected network. We ran into issues with Windows users using Windows systems as jump boxes. The Windows Systems only allowed for two concrurrent users to be logged in at one time and using a Windows servers as a jump box added additional latency, overhead, and reduced responsiveness. Many users have used this tool and liked it over using Windows servers as jump boxes. I used batch as it could be executed on the corporate laptops w/o elevated permissions. We leveraged SSO to allow the users to login to the JumpBox without manually entering credentials. The script has a bit of logic and error checking added to it to make it easier to use for non-technical users. We used this both for systems that use VPN and Citrix.

# Jump Box Requirements

1) Linux Server w/ users authorized to login. We used an AD Group and add users to that group, when they require access.
2) Linux Server needs to be joined to a domain along with the Device the users is using. User needs to use the same username on the Linux Box as their device.
3) Proper FW Rules need to be setup between the Linux Server and the various networks you require access on for port 3389.

# Tool Requirements

1) Users need to download plink.exe and placed in the same working directory as the batch script.
2) The SSH fingerprint variable needs to be identified and set in the batch script
3) The Jumpbox IP or FQDN variable needs to be set in the batch script.
4) Create history folder in the same working directory as the batch script for quick execution.

# Using the Tool

1) Launch the rdp-jump.bat
2) Enter the Destination Host that you want to jump to and press enter.
3) Wait for the connection to be established for RDP and login.
