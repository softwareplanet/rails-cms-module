SoftwarePlanet CMS setup guide
==========================

This guide covers the setup process of SoftwarePlanet CMS engine

After reading this guide, you will know:

* How to create basic rails project with SoftwarePlanet CMS support
* How to extend existed project with SoftwarePlanet CMS capabilities

--------------------------------------------------------------------------------

How to setup SoftwarePlanet CMS?
----------------------

This is a simple steps, to set up SoftwarePlanet CMS project from scratch on Linux systems.

### Brief Instructions:

TIP: If you already have existed project, and you want to extend it with SoftwarePlanet CMS, you can skip steps 1 and 2.

* Create new RVM (rails 3.2.*)  -- strongly recommend to use RVM anywhere, anywhen.

* Create new Rails-project, setup and configure mysql or sqlite database.

* [Download](#.html) and install SoftwarePlanet CMS as a local gem. To do it, just place the SoftwarePlanet CMS folder in your rails root application folder, and add to Gemfile:

```ruby
gem 'softwareplanet-cms', :path => 'softwareplanet-cms'
```

* Run `bundle` rake command.

* Run `rake cms:wizard` rake command to setup SoftwarePlanet CMS. See output to understand what modifications it applied.

* Start the rails server, using `rails s`

* Open in your browser `http://localhost:3000`. You should see the admin panel. Use username `admin` and password `admin` to log in.

###Detailed instruction:

TIP: If you already have existed project, and you want extend it with SoftwarePlanet CMS capabilities, you can skip steps 1 and 2.

TIP: Assuming that you already have installed RVM. If not, visit [(https://rvm.io/)]. It is not necessary, but strongly recommend. If you don't want use it, skip step 1.

* 1. To begin from scratch, you need to create a simple rails project. We recommended to starts with new rvm instance.
Open a terminal, navigate to a folder where you have rights to create files, and type something like:

```bash
$ mkdir blog
$ cd blog
touch .rvmrc
```

This will create a your future project folder, and .rvmrc file. This file will be used to setup your project's ruby environment when you switch to the project root directory.
Open this file with any text editor, and paste a single line (the ruby versions will be differ on your machine!):

```ruby
rvm use ruby-1.9.3-p392@blog --create
```

TIP: The installed ruby versions can be differ on your machine. You can check your version by using `rvm list` terminal command.

After that, you can activate your rvm, by directory switching:

```bash
$ cd ..
$ cd blog
```

Choose Yes on rvm prompt. Now, you can download rails gem for your rvm version.

```bash
$ gem install rails
$ cd ..
```

* 2. Now, you can create a Rails application

```bash
$ rails new blog
```

This will create a Rails application called Blog in a directory called blog (where we had placed .rvmrc file already).
Run the bundle command, to download all required gems:

```bash
$ bundle
```

Setup your database

```bash
$ rake db:prepare
```

This will instantiate a sqlite database. If you want mysql database instead,  open the Gemfile file, and replace
`gem 'sqlite3'`
with
`gem 'mysql2'`
and configure `config/database.yml` database configuration.

* 3. [Download](#.html) and install SoftwarePlanet CMS as a local gem. To do it, just place the railscms folder in your rails root application folder, and add to Gemfile:

```ruby
gem 'softwareplanet-cms', :path => 'softwareplanet-cms'
```

4. Run in terminal

```bash
$ bundle
```

5. Run rake command to setup SoftwarePlanet CMS. See output to understand what modifications it applied:

```bash
$ rake cms:wizard
```

5. Start the rails server:
```bash
$ rails s
```
6. Open in your browser `http://localhost:3000`. You should see the admin panel. Use username `admin` and password `admin` to log in.

-= SoftwarePlanet CMS =-