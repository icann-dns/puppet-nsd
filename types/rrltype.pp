# @summary Type for the Nsd rrltype
type Nsd::Rrltype = Enum[
  nxdomain,
  error,
  referral,
  any,
  rrsig,
  wildcard,
  nodata,
  dnskey,
  positive,
  all,
]
