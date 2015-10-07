# ${license-info}
# ${developer-info}
# ${author-info}

declaration template components/fstab/schema;

include {'quattor/schema'};
include {'quattor/blockdevices'};
include {'quattor/filesystems'};

@documentation{ 
Protected mountpoints and filesystem types. 
mounts is looked for on the second field of fstab, fs_file
fs_types is looked for on the third field of fstab, fs_vfstype
Default mounts is the same list as before in "protected_mounts"
}
type fstab_protected_entries = {
    "mounts" : string[] = list (
	    "/", "/usr", "/home", "/opt", "/var", "/var/lib", "/var/lib/rpm",
	    "/usr/bin", "/usr/sbin", "/usr/lib", "/usr/local/bin", "/usr/lib64",
	    "/bin", "/sbin", "/etc", "swap", "/proc", "/sys", "/dev/pts", "/dev/shm",
	    "/media/floppy", "/mnt/floppy", "/media/cdrecorder", "/media/cdrom",
	    "/mnt/cdrom", "/boot"
    )
    "fs_types" ? string[]
};

@documentation{
fstab component structure
keep entries are always kept, but can be changed
static entries can not be changed, but can be deleted
protected_mounts is still here for backwards compability, and is the same as keep/mounts
}
type structure_component_fstab = {
    include structure_component
    "keep" : fstab_protected_entries = nlist()
    "static" ? fstab_protected_entries
    "protected_mounts" ? string[] with {
        deprecated(0, "protected_mounts property has been deprecated, keep/mounts should be used instead"); 
        true;
    }
};

bind "/software/components/fstab" = structure_component_fstab;
