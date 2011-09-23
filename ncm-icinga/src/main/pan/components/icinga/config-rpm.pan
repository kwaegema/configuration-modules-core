# ${license-info}
# ${developer-info}
# ${author-info}

################################################################################
# This is 'TPL/config.tpl', a ncm-icinga's file
################################################################################
#
#
################################################################################
unique template components/icinga/config-rpm;
include {'components/icinga/functions'};
include {'components/icinga/schema'};

# Package to install
"/software/packages"=pkg_repl("ncm-icinga","0.0.2-6","noarch");
"/software/components/icinga/dependencies/pre" ?=  list ("spma");

"/software/components/icinga/active" ?= true;
"/software/components/icinga/dispatch" ?= true;
