# INSTALL

Biogem.info is a staticmatic generated website, which can be viewed with
staticmatic. It comes with a number of scripts and rake tasks which generate
the information displayed on the site in YAML format (usually to STDOUT).

## Installation

You will need libxml support, e.g.

  apt-get install libxslt-dev libxml2-dev

Install Ruby with openssl support

  rvm pkg install openssl
  rvm pkg install iconv
  rvm remove 1.9.2
  rvm install 1.9.2 -C --with-openssl-dir=$HOME/.rvm/usr,--with-iconv-dir=$HOME/.rvm/usr

Checkout the source code and run bundler. See also the create_website.sh and
show_website.sh scripts, to see the latest commands.

  bundle update

To run the cucumber tests

  bundle exec cucumber features/

To run a 'quick' test run

  ./create_website.sh --test

which will generate the site with just a few biogems. Next run 

  bundle exec staticmatic preview website/

The rakefile has some useful tasks, which can be viewed with

  rake -T

