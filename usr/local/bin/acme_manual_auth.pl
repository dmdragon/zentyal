#!/usr/bin/perl

# acme_manual_auth.pl
#
# Add the TXT record _acme-challenge for the DNS-01 challenge.
# The target is an external domain whose name ends with -external.

use strict;
use warnings;

use EBox;
use EBox::DNS;
use EBox::GlobalImpl;

EBox::init();

my $suffix = '-external';

my $impl = EBox::GlobalImpl->_new_instance;
my $dns = EBox::DNS->_create;

my $domain = $ENV{CERTBOT_DOMAIN} . $suffix;
my %host = (
    name => '_acme-challenge'
);
my %txt = (
    name => $host{name},
    data => $ENV{CERTBOT_VALIDATION}
);

if (!grep($_->{'name'} eq $host{name}, @{$dns->getHostnames($domain)})) {
    $dns->addHost($domain, \%host);
}

if (grep($_->{'target'} eq $host{name}, @{$dns->getTexts($domain)})) {
    $dns->delText($domain, {name => $txt{name}});
}
$dns->addText($domain, \%txt);

$impl->saveAllModules;

1;
