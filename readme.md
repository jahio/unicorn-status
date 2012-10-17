# unicorn_status.rb

Prints out information every few seconds (specified on command line) about what's in a given Unicorn socket.

Usage:

    ruby unicorn_status.rb /path/to/your/unicorn/socket.sock 10

Setup:

    gem install unicorn --no-ri --no-rdoc
    curl https://raw.github.com/jaustinhughey/unicorn-status/master/unicorn_status.rb > ~/unicorn_status.rb

Bugs/Contributions:
Pull requests welcome. Enhancements, bugfixes, whatever, it's all good. Fork, do work, test and submit a pull request.

Contributors:
 - Chris Rigor (https://github.com/crigor)
 - Adam Holt (https://github.com/omgitsads)
 - J. Austin Hughey (https://github.com/jaustinhughey)

License: CC Attribution 3.0 Unported (http://creativecommons.org/licenses/by/3.0/)