{ config, lib, pkgs, modulesPath, ... }:

{
  # Media storage disks
  fileSystems."/mnt/disks/data0" =
    { device = "/dev/disk/by-label/Data0";
      fsType = "btrfs";
    };
    
  # Mergerfs pool
  fileSystems."/mnt/storage" =
    { depends = [
      # The `disk*` mounts have to be mounted in this given order.
      "/mnt/disks/data0"
      ];
      device = "/mnt/disks/data*";
      fsType = "mergerfs";
      options = [ "defaults" "minfreespace=10G" "fsname=mergerfs-storage" "uid=1000" "gid=100" ];
    };
    
  # Parity disks
  fileSystems."/mnt/disks/parity0" =
    { depends = [
      # The `disk*` mounts have to be mounted in this given order.
      "/mnt/storage"
      ];
      device = "/dev/disk/by-label/Parity0";
      fsType = "ext4";
    };  

  # SnapRAID
  services.snapraid = {
    enable = true;
    #extraConfig = ''
    #  nohidden
    #  blocksize 256
    #  hashsize 16
    #  autosave 500
    #  pool /pool
    #'';
    parityFiles = [
      # Defines the file(s) to use as parity storage
      "/mnt/disks/parity0/snapraid.parity"
    ];
    contentFiles = [
      # Defines the files to use as content list.
      "/mnt/disks/data0/.snapraid.content"
      "/var/.snapraid.content"
    ];
    dataDisks = {
      # Defines the data disks to use
      # The order is relevant for parity, do not change it
      # REMEMBER to add the contentfile ^
      d0 = "/mnt/disks/data0/";
    };
    #touchBeforeSync = true; # Whether `snapraid touch` should be run before `snapraid sync`. Default: true.
    sync.interval = "03:00";
    scrub.interval = "weekly";
    #scrub.plan = 8; # Percent of the array that should be checked by `snapraid scrub`. Default: 8.
    #scrub.olderThan = 10; # Number of days since data was last scrubbed before it can be scrubbed again. Default: 10
    exclude = [
      # Defines files and directories to exclude
      # Remember that all the paths are relative at the mount points
      # Format: "FILE"
      # Format: "DIR/"
      # Format: "/PATH/FILE"
      # Format: "/PATH/DIR/"
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
      "*.!sync"
      ".AppleDouble"
      "._AppleDouble"
      ".DS_Store"
      "._.DS_Store"
      ".Thumbs.db"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".AppleDB"
    ];
  };
}
