module Debian

  class BlendTask
    def initialize buf
      @pkgs = {}
      buf.split(/\n/).each do | line |
        if line =~ /^Depends:\s+/
          @pkgs[$'] = true
        end
      end
    end

    def [] str
      @pkgs[str]
    end
  end

end
