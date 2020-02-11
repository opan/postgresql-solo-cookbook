name             'postgresql_solo'
maintainer       'Gopay System'
maintainer_email 'gopay-systems@go-jek.com'
license          'All rights reserved'
description      'Installs/Configures postgresql_wrapper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends 'postgresql', '= 7.1.5'
depends 'build-essential'
depends 'apt'
