require 'yaml'

class BiolinuxManifest

  def initialize buf
    @pkgs = YAML::load(buf)
  end

  def [] str
    @pkgs[str]
  end
end
