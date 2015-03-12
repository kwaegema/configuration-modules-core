declaration template metaconfig/ecryptfs/schema;

include 'pan/types';

type ecryptfs_servers = {
    'keyserver' :  type_fqdn
    'pwdserver' :  type_fqdn
};


