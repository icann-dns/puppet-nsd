if File.exist? '/usr/sbin/nsd'
  nsd_version = Facter::Util::Resolution.exec('/usr/sbin/nsd -v 2>&1').split('/n')[0].split[2]
  Facter.add(:nsd_version) do
    setcode do
      nsd_version
    end
  end
  Facter.add(:nsd_version_major) do
    setcode do
      nsd_version.split('.')[0]
    end
  end
end
