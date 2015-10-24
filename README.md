# Biogems.info

http://biogems.info/ tracks interesting Ruby gems for bioinformatics.

The following information describes the steps to getting your biogem
registered on biogems.info. If you are looking to generate the
biogems.info website instead: read INSTALL.md!

To get your gem listed, simply create a gem named 'bio-mygem', i.e.
start the *name* with bio dash, and push it onto rubygems.org. You can
use the biogem tool to create the plumbing, if you like. If you wish
to name your gem differently, or host the gem elsewhere, it can still
be listed. Either add a project description to /etc/biogems/name.yaml,
or add an issue to the github tracker at
https://github.com/pjotrp/biogems.info/issues

# Displayed gem information

The settings displayed, on biogems.info, are the ones you specify
in your gem. In particular

    gem.name = "bio-gem"
    gem.homepage = "http://github.com/helios/bioruby-gem"
    gem.license = "MIT"
    gem.summary = %Q{BioGem helps Bioinformaticians start developing plugins/modules for BioRuby creating a scaffold and a gem package}
    gem.description = %Q{BioGem is a scaffold generator for those
      ... } 
    gem.email = "ilpuccio.febo@gmail.com"
    gem.authors = ["Raoul J.P. Bonnal"]

This is the information pushed to http://rubygems.org/ when releasing a
gem. biogems.info harvests this information, with the download statistics.

= Additional settings

Information, not available through gems, is captured through overriding
settings. These are stored in this source repository, under ./etc/biogems/.
These files add information, such as doi references, and the status of a gem
(core, stable, test), but also potentially override gem settings, such 
as the summary field(!)

For example in ./etc/biogems/bio.yaml

    # Additional BioRuby settings
    :doi: 10.1093/bioinformatics/btq475
    :status: core
    :source_code_uri: https://github.com/bioruby/bioruby

It is also possible the overriding gemname.yaml is in your github 
repository(!) Just tell us where it resides through
https://github.com/pjotrp/biogems.info/issues


# Website source

This repository on github contains the source code for the
http://biogems.info/ website.

Biogems.info is an initiative by the BioRuby developers
Copyright (C) 2011-2015 Pjotr Prins <pjotr.prins@thebird.nl> 
