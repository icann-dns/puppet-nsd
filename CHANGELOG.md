### 2017-04-06 0.2.0
* Complete rewrite of the zones hash. 
* depricated the old $tsig hash now all hashs have to be defined in $tsisg and then refrenced by name in the remotes
* added new nsd::remotes define.  allows you to define data about remote servers and then refrence them by name where ever a zone paramter would require a server e.g. masters, provide_xfrs, notifis etc
* added default_tsig_name.  this specifies which nsd::tsig should be used by default
* added default_masters.  this specifies an array of nsd::remote to use by default
* added default_provide_xfrs.  this specifies an array of nsd::remote to use by default

### 2016-08-08 0.1.10
* Dont install upstart file for ubuntu 16.04

### 2016-08-08 0.1.9
* Disable logrotate rule on freebsd

### 2016-08-08 0.1.8
* only run control-setup if control is enabled

### 2016-08-08 0.1.7
* fix slave_addresses variable scope for future parser

### 2016-08-08 0.1.6
* fix tsig variable scope for future parser

### 2016-07-07 0.1.5
* Fix concat order to use a string

### 2016-07-07 0.1.4
* Add certificate generation

