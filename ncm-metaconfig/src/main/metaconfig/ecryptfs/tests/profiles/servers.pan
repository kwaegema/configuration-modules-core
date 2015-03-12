object template servers;

include 'metaconfig/ecryptfs/servers';

prefix "/software/components/metaconfig/services/{/etc/ecryptfs-servers.conf}/contents";

"keyserver" = "full.server.name";
"pwdserver" = "other.server.name";

