#! ruby

require 'yaml'
DIR='pkg'

fn = 'etc/bio-projects.yaml'

list = YAML::load(File.read(fn))

Dir.chdir(DIR) do
  list.each do | name, info |
    p name
    git = info[:source_code_uri]
    git = info[:homepage_uri] if !git
    if not File.directory?(File.basename(git))
      Kernel.system("git clone "+git)
    else
      print "Skipping ",git,"\n"
    end
  end
end
