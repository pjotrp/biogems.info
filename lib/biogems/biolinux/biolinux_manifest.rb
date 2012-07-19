require 'yaml'

class BiolinuxManifest

  def initialize buf
    @pkgs = YAML::load(buf)
  end

  def [] str
    @pkgs[str]
  end

  def is_biolinux? name
    name =~ /^(bio-linux|biolinux)/i
  end

  def is_science? name
    section = @pkgs[name]["section"]
    section =~ /math/i
  end

end


