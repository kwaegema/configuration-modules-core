unique template metaconfig/ecryptfs/servers;

include 'metaconfig/ecryptfs/schema';

bind "/software/components/metaconfig/services/{/etc/ecryptfs-servers.conf}/contents" = ecryptfs_servers;

prefix "/software/components/metaconfig/services/{/etc/ecryptfs-servers.conf}";
"mode" = 0700;
"owner" = "root";
"group" = "root";
"daemon" = "";
"module" = "tiny";
