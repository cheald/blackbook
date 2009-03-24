Blackbook
http://github.com/cheald/blackbook/tree/master

== DESCRIPTION:
  
Blackbook automates the nitty-gritty of importing contacts from various services and files and exporting them as VCard, XML, or simple Hash. Utilize those contacts from services like AOL, GMail, Yahoo Mail, Hotmail or CSV to help your social networking site become GIGANTIC overnight! You'll be able to get big and sell for millions before anyone figures out it's just like every other social network.

== FEATURES/PROBLEMS:
  
The current list of supported services and file types:

Import:
* AOL
* CSV files
* Gmail
* Hotmail
* Yahoo! Mail
* Freenet
* GMX
* Web.de

Export:
* Simple hash (default)
* Vcard
* XML

If you create an additional importer or exporter - or simply find a bug - please consider submitting it as a patch to the project so the community can all benefit from your hard work and ingenuity. 

== SYNOPSIS:

# An example of fetching Gmail contacts - by default, returns an array of hashes with :name and :email
  contacts = Blackbook.get :username => 'me@gmail.com', :password => 'whatever'

# or returning XML
  contacts = Blackbook.get :username => 'me@gmail.com', :password => 'whatever', :as => :xml
  
# or importing from a CSV file 
  contacts = Blackbook.get :csv, :file => #<File:/path/to/file.csv>

== REQUIREMENTS:

* Mechanize >= 0.9.2 and its dependencies, for interacting with online providers

== INSTALL:

1. gem sources -a http://gems.github.com
2. sudo gem install cheald-blackbook

== THANKS:

Big thanks to Marton Fabo for figuring out why Mechanize couldn't log in to AOL.

== LICENSE:

Copyright (c) 2007, Contentfree

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
