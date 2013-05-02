= Biogems.info =

Biogems.info is a generated site (using staticmatic).

== News feeds ==

News is gathered from multiple RSS feeds. You can add a blog by
editing ./etc/blogs.yaml. When running 

  rake rss

or alternatively

  ./bin/rss.rb

both an XML RSS file and a YAML file gets generated.  The information gets
collected into ./website/site/rss.xml - this is the file that is available as a
general news feed from http://biogems.info/rss.xml, which includes project
updates. Also a file ./var/news.yaml gets written - this is the file that is
used by staticmatic to generate the news feed on the website.



