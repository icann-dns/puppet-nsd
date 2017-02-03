# helper class to configure an as112 server
#
class nsd::as112 {
  include ::nsd
  nsd::zone {
    '10.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '16.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '17.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '18.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '19.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '20.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '21.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '22.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '23.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '24.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '25.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '26.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '27.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '28.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '29.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '30.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '31.172.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '168.192.in-addr.arpa':
      zonefile => 'db.dr-empty';
    '254.169.in-addr.arpa':
      zonefile => 'db.dr-empty';
    'empty.as112.arpa':
      zonefile => 'db.dr-empty';
    'hostname.as112.net':
      zonefile => 'hostname.as112.net.zone';
    'hostname.as112.arpa':
      zonefile => 'hostname.as112.arpa.zone';
  }
  nsd::file {
    'db.dd-empty':
      source  => 'puppet:///modules/nsd/etc/nsd/db.dd-empty';
    'db.dr-empty':
      source  => 'puppet:///modules/nsd/etc/nsd/db.dr-empty';
    'hostname.as112.net.zone':
      content_template => 'nsd/etc/nsd/hostname.as112.net.zone.erb';
    'hostname.as112.arpa.zone':
      content_template=> 'nsd/etc/nsd/hostname.as112.arpa.zone.erb';
  }
}
