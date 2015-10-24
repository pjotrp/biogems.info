= Biogems.info

The following information describes the steps to getting your biogem
registered on biogems.info. If you are looking to generate the
biogems.info website instead: read INSTALL.md!

http://biogems.info tracks interesting Ruby gems for bioinformatics.

To get your gem listed, simply create a gem named 'bio-mygem', i.e.
start the name with bio dash, and push it onto rubygems.org. You can
use the biogem tool to create the plumbing, if you like. If you wish
to name your gem differently, or host the gem elsewhere, it can still
be listed. Either add a project description to /etc/biogems/name.yaml,
or add an issue to the github tracker at
https://github.com/pjotrp/biogems.info/issues

= Gem settings

The settings displayed, on biogems.info, are the ones you specify
for a gem. In particular

    gem.name = "bio-gem"
    gem.homepage = "http://github.com/helios/bioruby-gem"
    gem.license = "MIT"
    gem.summary = %Q{BioGem helps Bioinformaticians start developing plugins/modules for BioRuby creating a scaffold and a gem package}
    gem.description = %Q{BioGem is a scaffold generator for those
      ... } 
    gem.email = "ilpuccio.febo@gmail.com"
    gem.authors = ["Raoul J.P. Bonnal"]

This is the information pushed to http://rubygems.org when releasing a
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

= GitHub API access limits

Without using authentication, the GitHub API allows only 60 requests
per hour from a single IP address. But during the data collection
phase of generating the biogems.info website, the script currently
needs to make around 200 requests to this API to fetch the number of
issues and stargazers for each gem.

To get around this, go to the applications tab on your GitHub
settings page and generate a new "Personal API access token". Then
copy that token (but not into the repository!), and before running the ./create_data.sh script,
set the GITHUB_API_TOKEN environment variable like this:

    export GITHUB_API_TOKEN="copy-here-the-token-string-from-github"

That lets the script make 5000 requests per hour, which should be
more then enough.

= Website source

This repository on github contains the source code for the
http://biogems.info website.

Biogems.info is an initiative by the BioRuby developers
Copyright (C) 2011,2012,2013,2014 Pjotr Prins <pjotr.prins@thebird.nl> 
