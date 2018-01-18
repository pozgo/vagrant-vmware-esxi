vagrant-vmware-esxi plugin
==========================
This is a Vagrant plugin that adds a VMware ESXi provider support.  This allows Vagrant to control and provision VMs directly on an ESXi hypervisor without a need for vCenter or VShpere.   ESXi hypervisor is a free download from VMware!
>https://www.vmware.com/go/get-free-esxi


Features and Compatibility
--------------------------
* Any of the vmware Box formats should be compatible.
  * vmware_desktop, vmware_fusion, vmware_workstation...
  * To be fully functional, you must have open-vm-tools or vmware tools installed
* Will automatically download boxes from the web.
* Will automatically upload the box to your ESXi host.
* Automatic or manual VM names.
  * Automatic VM names are "PREFIX-HOSTNAME-USERNAME-DIR".
* Multi machine capable.
* Supports adding your VM to Resource Pools to partition CPU and memory usage from other VMs on your ESXi host.
* suspend / resume.
* snapshots.
* rsync & NFS using built-in Vagrant synced folders.
* Provision using built-in Vagrant provisioner.
* package your vm's into boxes.
* Set MAC addresses on network interfaces.
* Use Vagrants Set IP addresses on network interfaces feature. (private_network, public_network)

Requirements
------------
1. This is a vagrant plugin, so you need vagrant installed...  :-)
2. This plugin requires ovftool from VMware.  Download from VMware website.
>https://www.vmware.com/support/developer/ovf/
3. You MUST enable ssh access on your ESXi hypervisor.
  * Google 'How to enable ssh access on esxi'
4. The boxes must have open-vm-tools or vmware-tools installed to properly transition to the "running" state.
5. You should know how to use vagrant in general...

Why this plugin?
----------------
Not everyone has vCenter / vSphere...  vCenter cost $$$.  ESXi is free!
Using this plugin will allow you to use a central VMware ESXi host for your development needs.  Using a centralized host will release the extra load on your local system (vs using KVM or Virtual Box).

How to install
--------------
Download and install Vagrant on your local system using instructions from https://vagrantup.com/downloads.html.   
```
vagrant plugin install vagrant-vmware-esxi
vagrant version
```
How to use and configure a Vagrantfile
--------------------------------------

1. cd SOMEDIR
1. `vagrant init`
1. `vi Vagrantfile`  # See below to setup access your ESXi host and to set some preferences.
```ruby
Vagrant.configure("2") do |config|

  #  Box, Select any box created for VMware that is compatible with
  #    the ovftool.  To get maximum compatibility You should download
  #    and install the latest version of ovftool for your OS.
  #    https://www.vmware.com/support/developer/ovf/
  #
  #    If your box is stuck at "Powered On", then most likely
  #    the system doesn't have the vmware tools installed.
  #
  # Here are some of the MANY examples....
  config.vm.box = 'generic/centos7'
  #config.vm.box = 'generic/centos6'
  #config.vm.box = 'generic/fedora26'
  #config.vm.box = 'generic/freebsd11'
  #config.vm.box = 'generic/ubuntu1710'
  #config.vm.box = 'generic/debian9'
  #config.vm.box = 'hashicorp/precise64'
  #config.vm.box = 'steveant/CentOS-7.0-1406-Minimal-x64'
  #config.vm.box = 'geerlingguy/centos7'
  #config.vm.box = 'geerlingguy/ubuntu1604'
  #config.vm.box = 'laravel/homestead'
  #config.vm.box = "puphpet/debian75-x64"


  #  Use rsync and NFS synced folders. (or disable them)
  config.vm.synced_folder('.', '/vagrant', type: 'rsync')
  config.vm.synced_folder('.', '/vagrant', type: 'nfs', disabled: true)

  #  Vagrant can set a static IP for the additional network interfaces.  Use
  #  public_network or private_network to manually set a static IP and
  #  netmask.  ESXi doesn't use the concept of public or private networks so
  #  both are valid here.   "bridge" will be ignored.  Netmask is optional if
  #  you are using standard Class A/B/C networks. The primary network
  #  interface is considered the management interface and cannot be changed,
  #  so you can specify 3 entries here!
  #    *** Invalid settings could cause "vagrant up" to fail ***   
  #config.vm.network "private_network", ip: "192.168.10.170", netmask: "255.255.255.0"
  #config.vm.network "private_network", ip: "192.168.11.170"
  #config.vm.network "public_network", ip: "192.168.12.170"

  #
  #  Provider (esxi) settings
  #
  config.vm.provider :vmware_esxi do |esxi|

    #  REQUIRED!  ESXi hostname/IP
    #    You MUST specify a esxi_hostname or IP, uless you
    #    were lucky enough to name your esxi host "esxi".  :-)
    esxi.esxi_hostname = "esxi"

    #  ESXi username
    #    Default is "root".
    esxi.esxi_username = "root"

    #
    #  IMPORTANT!  ESXi password.
    #  *** NOTES about esxi_password & ssh keys!! ***
    #
    #    1) "prompt:"
    #       This will prompt you for the esxi password each time you
    #       run a vagrant command.  This is the default.
    #
    #    2) "file:"  or  "file:my_secret_file"
    #       This will read a plain text file containing the esxi
    #       password.   The default filename is ~/.esxi_password, or
    #       you can specify any filename after the colon ":".
    #
    #    3) "env:"  or "env:my_secret_env_var"
    #        This will read the esxi password via an environment
    #        variable.  The default is $esxi_password, but you can
    #        specify any environment variable after the colon ":".
    #
    #            $ export esxi_password="my_secret_password"
    #
    #    4)  "key:"  or  key:~/.ssh/some_ssh_private_key"
    #        Use ssh keys.  The default is to use the system private keys,
    #        or you specify a custom private key after the colon ":".
    #
    #        To test connectivity. From your command line, you should be able to
    #        run following command without an error and get an esxi prompt.
    #
    #            $ ssh root@ESXi_IP_ADDRESS
    #
    #        The ssh connections to esxi will try the ssh private
    #        keys.  However the ovftool does NOT!  To make
    #        vagrant fully password-less, you will need to use other
    #        options. (set the password, use "env:" or "file:")
    #
    #    5)  esxi.esxi_password = "my_esxi_password"
    #        Enter your esxi passowrd in clear text here...  This is the
    #        least secure method because you may share this Vagrant file without
    #        realizing the password is in clear text.
    #
    #  IMPORTANT!  Set the ESXi password or authentication method..
    esxi.esxi_password = "prompt:"

    #  ESXi ssh keys.   (This is depreciated!!!)
    #    The Default is to use system default ssh keys, However
    #    you can specify an array of keys here...
    #
    #   ***  Depreciated, use esxi_password = "key:" instead. ***
    #esxi.esxi_private_keys = []

    #  SSH port.
    #    Default port 22.
    #esxi.esxi_hostport = 22

    #  HIGHLY RECOMMENDED!  Virtual Network
    #    You should specify a Virtual Network!  If it's not specified, the
    #    default is to use the first found.  You can specify up to 4 virtual
    #    networks using an array format.  Note that Vagrant only looks at the
    #    first interface for a valid IP address.  BTW: This does not configure
    #    IP addresses.  This specifies which "ESXi virtual network" is used for
    #    each network interface in your VM.  For most OS's DHCP is the default,
    #    so, you will need a DHCP server for each virtual network.  To set a
    #    static IP, see above "config.vm.network".
    #esxi.virtual_network = ["vmnet1","vmnet2","vmnet3","vmnet4"]

    #  OPTIONAL & RISKY.  Specify up to 4 MAC addresses
    #    The default is ovftool to automatically generate a MAC address.
    #    You can specify an array of MAC addresses using upper or lower case,
    #    separated by colons ":".  I highly recommend using vmware's OUI
    #    of "00:50:56" or "00:0c:29".  I consider this option a risk
    #    because you may reuse a Vagrantfile without realizing you are
    #    duplicating the MAC address.
    #    *** Invalid settings could cause "vagrant up" to fail ***  
    #esxi.mac_address = ["00:50:56:aa:bb:cc", "00:50:56:01:01:01","00:50:56:02:02:02","00:50:56:BE:AF:01" ]

    #   OPTIONAL & RISKY.  Specify a nic_type
    #     The default is to have the virtual nic hw type automatically
    #     determined by the ovftool.  However, you can override it by specifying
    #     it here.  This is a global setting.  (all 4 virtual networks will be set)
    #     The validated list of nic_types are "e1000", "e1000e", "vmxnet",
    #     "vmxnet2", "vmxnet3", "Vlance", and "Flexible".  I consider this
    #     risky because I don't validate if the specified nic_type is
    #     compatible with your OS version.
    #    *** Invalid settings could cause "vagrant up" to fail ***  
    #esxi.nic_type = 'e1000'

    #  OPTIONAL.  Specify a Disk Store
    #    If it's not specified, the Default is to use the least used Disk Store.
    #esxi.vm_disk_store = "DS_001"

    #  OPTIONAL.  Guest VM name to use.
    #    The Default will be automatically generated.  It will be based on
    #    the vmname_prefix (see below), your hostname & username and path.
    #    Otherwise you can set a fixed guest VM name here.
    #esxi.vmname = "Custom-Guest-VM_Name"

    #  OPTIONAL.  When automatically naming VMs, use
    #    this prifix.
    #esxi.vmname_prefix = "V-"

    #  OPTIONAL.  Memory size override
    #    The default is to use the memory size specified in the
    #    vmx file, however you can specify a new value here.
    #esxi.memsize = "2048"

    #  OPTIONAL.  Virtual CPUs override
    #    The default is to use the number of virtual cpus specified
    #     in the vmx file, however you can specify a new value here.
    #esxi.numvcpus = "2"

    #  OPTIONAL.  Resource Pool
    #    If unspecified, the default is to create VMs in the "root".  You can
    #    specify a resource pool here to partition memory and cpu usage away
    #    from other systems on your esxi host.  The resource pool must
    #    already exist and have the proper permissions set.
    #     
    #     Vagrant will NOT create a Resource pool it for you.
    #esxi.resource_pool = "/Vagrant"

    #  DANGEROUS!  Allow Overwrite
    #    If unspecified, the default is to produce an error if overwriting
    #    vm's and packages.
    #    Set this to 'True' will overwrite existing VMs (with the same name)
    #    when you run vagrant up.   ie,  if the vmname already exists,
    #    it will be destroyed, then over written...  This is helpful
    #    if you have a VM that became an orphan (vagrant lost association).
    #    This will also overwrite your box when using vagrant package.
    #esxi.allow_overwrite = 'True'

  end
end
```

Basic usage
-----------
1. `vagrant up --provider=vmware_esxi`
1. To access the VM, use `vagrant ssh`
1. To destroy the VM, use `vagrant destroy`
1. Some other fun stuff you can do.
  * `vagrant status`
  * `vagrant suspend`
  * `vagrant resume`
  * `vagrant snapshot push`
  * `vagrant snapshot list`
  * `vagrant snapshot-info`
  * `vagrant snapshot pop`  
  * `vagrant halt`
  * `vagrant provision`


Known issues with vmware_esxi
-----------------------------
* The boxes must have open-vm-tools or vmware-tools installed to properly transition to the "running" state.
* Invalid settings (bad IP address, netmask, MAC address) could cause 'vagrant up' to fail.  Review your ESXi logs to help debug why it failed.
* Cleanup doesn't always destroy a VM that has been partially built.  Use the allow_overwrite = 'True' option if you need to force a rebuild, or delete the vm using the VSphere client.
* ovftool installer for windows doesn't put ovftool.exe in your path.  You can manually set your path, or install ovftool in the \HashiCorp\Vagrant\bin directory.
* In general I find NFS synced folders a little "flaky"...


Version History
---------------
* 1.4.0 Add support to set MAC and IP addresses for network interfaces.
* 1.3.2 Fix, Don't timeout ssh connection when ovftool takes a long time to upload image.
* 1.3.0 Add support to get esxi password from env, from a file or prompt.
* 1.2.1 Encode special characters in password.
* 1.2.0 Add support for up to 4 virtual networks.
* 1.7.1 Show all port groups for each virtual switch instead of just the first.
* 1.1.6 Update documenation.
* 1.1.5 Add more detailed information when waiting for state (running).
* 1.1.4 Update documentation.
* 1.1.3 Add support to create package.
* 1.1.2 Fix, reload.
* 1.1.1 Add support for NFS.
* 1.1.0 Add support for snapshots.
* 1.0.1 Init commit.

Feedback please!
----------------
* To help improve this plugin, I'm requesting that you provide some feedback.
* https://goo.gl/forms/tY14mE77HJvhNvjj1
