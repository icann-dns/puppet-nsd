# @summary Type for the Nsd server
type Nsd::Server = Struct[{
  address4          => Optional[Stdlib::IP::Address::V4::CIDR],
  address6          => Optional[Stdlib::IP::Address::V6::CIDR],
  fetch_tsig_name   => Optional[String],
  provide_tsig_name => Optional[String],
}]
