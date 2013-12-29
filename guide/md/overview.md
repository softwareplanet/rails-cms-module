SoftwarePlanet CMS
==========================

This guide covers the setup process and using of SoftwarePlanet CMS engine, the OpenSource Rails project.

After reading this guide, you will know:

* How to setup SoftwarePlanet CMS
* How to use admin mode to create web sites and populate it
* How to use programmed experience to improve the site strength
* How to use the ActiveFile methods and their associations

--------------------------------------------------------------------------------

Why SoftwarePlanet CMS?
-------------

SoftwarePlanet CMS, specially developed and designed to effective site content management, and distributed service. Admin back-end allows to make changes to different types of participators:
language translators, front-end designers, ruby and javascript developers. SoftwarePlanet CMS can be included at any stage of your project, like any other local gem.
It will share own routes with your application, and add an admin mode, internatialization and many other features. It is OpenSource, and you can modify it.


What do I need for SoftwarePlanet CMS?
----------------------------

It requires any type of ActiveRecord connection established in your project. It can be be mysql, sqlite.. Anything else. It needed to include 2 tables into your database. That's all you need for work. 
The SoftwarePlanet CMS wizard script will setup and configure it automatically.

How to setup SoftwarePlanet CMS?
----------------------

[This guide](setup.html) explain SoftwarePlanet CMS setup process.

In brief, you should:

- add SoftwarePlanet CMS gem to your Gemfile

```ruby
gem 'softwareplanet-cms', :git => "git://github.com/softwareplanet/cms.git"
```

- run `bundle` command
- run `rake cms:wizard` rake command to finish setup.

How to use admin mode to create web sites and populate it
---------------------------------------------------------

##### `Documentation for SoftwarePlanet CMS UI coming soon`

How to use programmed experience to improve the site strength
-------------------------------------------------------------

SoftwarePlanet CMS uses HAML and SCSS technologies.

-= SoftwarePlanet CMS =-