# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

package NCM::Component::Postgresql::Service;

use strict;
use warnings;

use parent qw(CAF::Service);

use Readonly;
Readonly my $SERVICENAME => 'SERVICENAME';
Readonly my $POSTGRESQL => 'postgresql';

sub _initialize {
    my ($self, %opts) = @_;
    my $suffix = delete $opts{suffix} || '';

    $self->{$SERVICENAME} = "$SERVICENAME$suffix";

    return $self->SUPER::_initialize([$self->{$SERVICENAME}], %opts);
}

# TODO: status should check "only" postmaster process like the old code did?
# TODO: what to do with exitcode?

foreach my $action (qw(status initdb)) {
    foreach my $flavour (FLAVOURS) {
        no strict 'refs';
        *{"${method}_${flavour}"} = __make_method($method, $flavour);
        use strict 'refs';
    }
};

# TODO: generic enough for CAF::Service?
# check initstate, do X or Y, and verify if expected endstate
# result is based on status, not on the return value of the X or Y method
#   init: expected initial state 0 or 1
#   ok / notok: run method named ok when initial state == init, method named notok otherwise
#     if ok or notok is undef: log verbose and return state == init
#   end: expected end state 0 or 1, return succes if state == end after method; fail and log error otherwise
# 
# init seems not needed, but is relevant when ok or notok or btoh are undef
#    for undef ok, it means, all is as expected, nothing to do here
#    not undef notok, it means if not even in this state, giving up
sub _wrap_in_status
{
    my ($self, $ok, $notok, $end) = @_;

    my $state = $self->status() ? 1 : 0; # force to 0 /1

    my $res = $state == $init;

    my $method;
    if ($res && $ok) {
        $method = $ok;
    } elsif ((! $res) && $notokmethod) {
        $method = $notok;
    } else {
        $self->verbose("$self->{$SERVICENAME} status $state, not doing anything, return $res.");
        return $res;
    }

    $self->verbose("$self->{$SERVICENAME} status $state, going to run $method.");
    my $ec = $self->$method();
    $self->verbose("$self->{$SERVICENAME} ran $method (ec $ec).");
    
    # stop failed because still running
    $state = $self->status() ? 1 : 0; # force to 0 /1
    $self->verbose("$self->{$SERVICENAME} end status $state.");
    if ($state == $end) {
        return 1;
    } else {
        my $endlogic = $end ? 'not ' : '';
        $self->error("$self->{$SERVICENAME} ${endlogic}running.");
        return;
    };
}

# status_start: _warp_in_status, do nothing if already running
# expected result: running
sub status_start
{
    my ($self) = @_;
    return self->_wrap_in_status(1, undef, 'start', 1);
}

# status_stop: stop + _wrap_in_status, do nothing if not running
# expected result: not running
sub status_stop
{
    my ($self) = @_;
    return self->_wrap_in_status(0, undef, 'stop', 0);
}

# status_reload: _wrap_in_status, reload if running, start if not
# expected result: running
sub status_reload
{
    my ($self) = @_;
    return self->_wrap_in_status(1, 'reload', 'start', 1);
}

# status_reload: _wrap_in_status, restart if running, start if not
# expected result: running
sub status_restart
{
    my ($self) = @_;
    return self->_wrap_in_status(1, 'restart', 'start', 1);
}

# initdb: not running, initdb + start; force_restart, restart if running (no initdb), do nothing if running and not restart otherwise
# only forcerestart with initdb

# initdb_start: run initdb, followed by start, return combined exitcodes
sub initdb_start
{
    my ($self) = @_;

    my $initdb = $self->initdb();
    my $start = $self->start();

    my $res = $initdb && $start;
    $self->verbose("initdb_start: exitcodes initdb $initdb start $start result $res");
    return $res;
}

# status_initdb: _wrap_in_status, initdb+start if not running, restart otherwise
# expected result: running
sub status_initdb
{
    my ($self) = @_;
    return $self->_wrap_in_status(0, 'initdb_start', 'restart', 1);
}

# Older code also had abs_start and abs_stop, which was start and stop 
# with yet another status check and error
# is that necessary? maybe suppor tundef as endstate to not log error in regular status_start and status_stop?

1;

