RailsCms
==========================

This guide covers the setup process and using of RailsCMS engine, the OpenSource Rails project.

After reading this guide, you will know:

* How to setup RailsCms
* How to use admin mode to create web sites and populate it
* How to use programmed experience to improve the site strength
* How to use the ActiveFile methods and their associations

--------------------------------------------------------------------------------

Why RailsCms?
-------------

Rails CMS, specially developed and designed to effective site content management, and distributed service. Admin back-end allows to make changes to different types of participators: 
language translators, front-end designers, ruby and javascript developers. RailsCms can be included at any stage of your project, like any other local gem. 
It will share own routes with your application, and add an admin mode, internatialization and many other features. It is OpenSource, and you can modify it.


What do I need for RailsCms?
----------------------------

It requires any type of ActiveRecord connection established in your project. It can be be mysql, sqlite.. Anything else. It needed to include 2 tables into your database. That's all you need for work. 
The RailsCms wizard script will setup and configure it automatically.

How to setup RailsCms?
----------------------

This is a simple steps, to set up RailsCms project from scratch on Linux system. If you already have existed project, you can skipt steps 1,2:

1. Create new RVM (rails 3.2.*)  -- strongly recommend to use RVM anywhere, anywhen.
2. Create new Rails-project, setup and configure mysql or sqlite database.
3. [Download](#.html) and install RailsCms as a local gem. To do it, just place the railscms folder in your rails root application folder, and add to Gemfile:


```ruby
gem 'railscms', :path => 'railscms'
```

4. Run `bundle` rake command.
5. Run `rake cms:wizard` rake command to setup devcms. See output to understand what modifications it applyed.
5. Start the rails server, using `rails s`
6. Open in your browser `http://localhost:3000`. You should see the admin panel. Use username `admin` and password `admin` to log in.

##### `To be continued and well described later...`

How to use admin mode to create web sites and populate it
---------------------------------------------------------

##### `Documentation for RailsCms UI coming soon`

How to use programmed experience to improve the site strength
-------------------------------------------------------------

RailsCms uses HAML and SCSS technologies.

What is ActiveFile?
-------------------

[![Gem Version](https://badge.fury.io/rb/activefile.png)](http://badge.fury.io/rb/activefile)

ActiveFile is a lightweight file system ORM, specially designed and developed for RailsCms. It will be free and opensource soon.

ActiveFile build a persistent domain model by mapping file system objects to Ruby classes. It inherits ActiveRecord-similar interface.

## Definition

This is a neat example of ActiveFile power. You can define any file system objects in a ActiveRecord-way. All of them are file objects. No database needed:

class Layout < ActiveFile::Base
  has_one :css
  has_one :seo_tag
end

class Content < ActiveFile::Base
  has_one :css
end

class Css < ActiveFile::Base
  belongs_to :layout
  belongs_to :content
  file_path "app/assets/stylesheets"
end

class SeoTag < ActiveFile::Base
  belongs_to :layout
end


How to use the ActiveFile methods and their associations?
---------------------------------------------------------

This is another example, with methods describing. Look RDoc for ActiveFile fore more details.

Define a `Shop` model. Inherit from `ActiveFile::Base`.
`parent_to` is an alias to ActiveRecord `has_many` association.

    class Shop < ActiveFile::Base
      has_many :products
    end

Okay, we have a shop which is a **parent** to products. Let's define a `Product`:

    class Product < ActiveFile::Base
      child_of :shop
    end

From now, add some logic in your controller.
At first, create a shop. `name` is a **important** attribute for every file object:

    shop = Shop.new(:name => "Apple Store")
    shop.save!

Check the sum of shops:

    Shop.all.size  #> 1

Next, create some `product`, and define it as a child of our `shop`

    iPad = Product.new(:name => "iPad", :parent => shop, :data => "The iPad is a line of tablet computers designed and marketed by Apple Inc., which runs Apple's iOS operating system.") 
    iPad.save!

Oh, iPad is a great product, ok. Note, that we defined the product file content with `data` attribute.
Let's see what we can do now:

    product = Product.where(:name => "iPad")[0]
    product.data  #>  "The iPad "...
    product.shop  #>  <Shop instance>
    product.shop.name  #> "Apple Store"

In result, two persistent files were created, accessible via ORM mechanism.

## Installation

Add this line to your application's Gemfile:

    gem 'activefile'

And then execute:

    $ bundle

## Credits


## Changelog

**all versions before `1.0.0` future version are Development contributions, and can't be used.**










-= RailsCms =-

If you set the `:validate` option to `true`, then associated objects will be validated whenever you save this object. By default, this is `false`: associated objects will not be validated when this object is saved.

#### Scopes for `has_one`

There may be times when you wish to customize the query used by `has_one`. Such customizations can be achieved via a scope block. For example:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, -> { where active: true }
end
```

You can use any of the standard [querying methods](active_record_querying.html) inside the scope block. The following ones are discussed below:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

The `where` method lets you specify the conditions that the associated object must meet.

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

You can use the `includes` method to specify second-order associations that should be eager-loaded when this association is used. For example, consider these models:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account
end

class Account < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ActiveRecord::Base
  has_many :accounts
end
```

If you frequently retrieve representatives directly from suppliers (`@supplier.account.representative`), then you can make your code somewhat more efficient by including representatives in the association from suppliers to accounts:

```ruby
class Supplier < ActiveRecord::Base
  has_one :account, -> { includes :representative }
end

class Account < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ActiveRecord::Base
  has_many :accounts
end
```

##### `readonly`

If you use the `readonly` method, then the associated object will be read-only when retrieved via the association.

##### `select`

The `select` method lets you override the SQL `SELECT` clause that is used to retrieve data about the associated object. By default, Rails retrieves all columns.

#### Do Any Associated Objects Exist?

You can see if any associated objects exist by using the `association.nil?` method:

```ruby
if @supplier.account.nil?
  @msg = "No account found for this supplier"
end
```

#### When are Objects Saved?

When you assign an object to a `has_one` association, that object is automatically saved (in order to update its foreign key). In addition, any object being replaced is also automatically saved, because its foreign key will change too.

If either of these saves fails due to validation errors, then the assignment statement returns `false` and the assignment itself is cancelled.

If the parent object (the one declaring the `has_one` association) is unsaved (that is, `new_record?` returns `true`) then the child objects are not saved. They will automatically when the parent object is saved.

If you want to assign an object to a `has_one` association without saving the object, use the `association.build` method.

### `has_many` Association Reference

The `has_many` association creates a one-to-many relationship with another model. In database terms, this association says that the other class will have a foreign key that refers to instances of this class.

#### Methods Added by `has_many`

When you declare a `has_many` association, the declaring class automatically gains 13 methods related to the association:

* `collection(force_reload = false)`
* `collection<<(object, ...)`
* `collection.delete(object, ...)`
* `collection.destroy(object, ...)`
* `collection=objects`
* `collection_singular_ids`
* `collection_singular_ids=ids`
* `collection.clear`
* `collection.empty?`
* `collection.size`
* `collection.find(...)`
* `collection.where(...)`
* `collection.exists?(...)`
* `collection.build(attributes = {}, ...)`
* `collection.create(attributes = {})`

In all of these methods, `collection` is replaced with the symbol passed as the first argument to `has_many`, and `collection_singular` is replaced with the singularized version of that symbol. For example, given the declaration:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders
end
```

Each instance of the customer model will have these methods:

```ruby
orders(force_reload = false)
orders<<(object, ...)
orders.delete(object, ...)
orders.destroy(object, ...)
orders=objects
order_ids
order_ids=ids
orders.clear
orders.empty?
orders.size
orders.find(...)
orders.where(...)
orders.exists?(...)
orders.build(attributes = {}, ...)
orders.create(attributes = {})
```

##### `collection(force_reload = false)`

The `collection` method returns an array of all of the associated objects. If there are no associated objects, it returns an empty array.

```ruby
@orders = @customer.orders
```

##### `collection<<(object, ...)`

The `collection<<` method adds one or more objects to the collection by setting their foreign keys to the primary key of the calling model.

```ruby
@customer.orders << @order1
```

##### `collection.delete(object, ...)`

The `collection.delete` method removes one or more objects from the collection by setting their foreign keys to `NULL`.

```ruby
@customer.orders.delete(@order1)
```

WARNING: Additionally, objects will be destroyed if they're associated with `dependent: :destroy`, and deleted if they're associated with `dependent: :delete_all`.

##### `collection.destroy(object, ...)`

The `collection.destroy` method removes one or more objects from the collection by running `destroy` on each object.

```ruby
@customer.orders.destroy(@order1)
```

WARNING: Objects will _always_ be removed from the database, ignoring the `:dependent` option.

##### `collection=objects`

The `collection=` method makes the collection contain only the supplied objects, by adding and deleting as appropriate.

##### `collection_singular_ids`

The `collection_singular_ids` method returns an array of the ids of the objects in the collection.

```ruby
@order_ids = @customer.order_ids
```

##### `collection_singular_ids=ids`

The `collection_singular_ids=` method makes the collection contain only the objects identified by the supplied primary key values, by adding and deleting as appropriate.

##### `collection.clear`

The `collection.clear` method removes every object from the collection. This destroys the associated objects if they are associated with `dependent: :destroy`, deletes them directly from the database if `dependent: :delete_all`, and otherwise sets their foreign keys to `NULL`.

##### `collection.empty?`

The `collection.empty?` method returns `true` if the collection does not contain any associated objects.

```erb
<% if @customer.orders.empty? %>
  No Orders Found
<% end %>
```

##### `collection.size`

The `collection.size` method returns the number of objects in the collection.

```ruby
@order_count = @customer.orders.size
```

##### `collection.find(...)`

The `collection.find` method finds objects within the collection. It uses the same syntax and options as `ActiveRecord::Base.find`.

```ruby
@open_orders = @customer.orders.find(1)
```

##### `collection.where(...)`

The `collection.where` method finds objects within the collection based on the conditions supplied but the objects are loaded lazily meaning that the database is queried only when the object(s) are accessed.

```ruby
@open_orders = @customer.orders.where(open: true) # No query yet
@open_order = @open_orders.first # Now the database will be queried
```

##### `collection.exists?(...)`

The `collection.exists?` method checks whether an object meeting the supplied conditions exists in the collection. It uses the same syntax and options as `ActiveRecord::Base.exists?`.

##### `collection.build(attributes = {}, ...)`

The `collection.build` method returns one or more new objects of the associated type. These objects will be instantiated from the passed attributes, and the link through their foreign key will be created, but the associated objects will _not_ yet be saved.

```ruby
@order = @customer.orders.build(order_date: Time.now,
                                order_number: "A12345")
```

##### `collection.create(attributes = {})`

The `collection.create` method returns a new object of the associated type. This object will be instantiated from the passed attributes, the link through its foreign key will be created, and, once it passes all of the validations specified on the associated model, the associated object _will_ be saved.

```ruby
@order = @customer.orders.create(order_date: Time.now,
                                 order_number: "A12345")
```

#### Options for `has_many`

While Rails uses intelligent defaults that will work well in most situations, there may be times when you want to customize the behavior of the `has_many` association reference. Such customizations can easily be accomplished by passing options when you create the association. For example, this association uses two such options:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, dependent: :delete_all, validate: :false
end
```

The `has_many` association supports these options:

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:validate`

##### `:as`

Setting the `:as` option indicates that this is a polymorphic association, as discussed <a href="#polymorphic-associations">earlier in this guide</a>.

##### `:autosave`

If you set the `:autosave` option to `true`, Rails will save any loaded members and destroy members that are marked for destruction whenever you save the parent object.

##### `:class_name`

If the name of the other model cannot be derived from the association name, you can use the `:class_name` option to supply the model name. For example, if a customer has many orders, but the actual name of the model containing orders is `Transaction`, you'd set things up this way:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, class_name: "Transaction"
end
```

##### `:dependent`

Controls what happens to the associated objects when their owner is destroyed:

* `:destroy` causes all the associated objects to also be destroyed
* `:delete_all` causes all the associated objects to be deleted directly from the database (so callbacks will not execute)
* `:nullify` causes the foreign keys to be set to `NULL`. Callbacks are not executed.
* `:restrict_with_exception` causes an exception to be raised if there are any associated records
* `:restrict_with_error` causes an error to be added to the owner if there are any associated objects

NOTE: This option is ignored when you use the `:through` option on the association.

##### `:foreign_key`

By convention, Rails assumes that the column used to hold the foreign key on the other model is the name of this model with the suffix `_id` added. The `:foreign_key` option lets you set the name of the foreign key directly:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, foreign_key: "cust_id"
end
```

TIP: In any case, Rails will not create foreign key columns for you. You need to explicitly define them as part of your migrations.

##### `:inverse_of`

The `:inverse_of` option specifies the name of the `belongs_to` association that is the inverse of this association. Does not work in combination with the `:through` or `:as` options.

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, inverse_of: :customer
end

class Order < ActiveRecord::Base
  belongs_to :customer, inverse_of: :orders
end
```

##### `:primary_key`

By convention, Rails assumes that the column used to hold the primary key of the association is `id`. You can override this and explicitly specify the primary key with the `:primary_key` option.

##### `:source`

The `:source` option specifies the source association name for a `has_many :through` association. You only need to use this option if the name of the source association cannot be automatically inferred from the association name.

##### `:source_type`

The `:source_type` option specifies the source association type for a `has_many :through` association that proceeds through a polymorphic association.

##### `:through`

The `:through` option specifies a join model through which to perform the query. `has_many :through` associations provide a way to implement many-to-many relationships, as discussed <a href="#the-has-many-through-association">earlier in this guide</a>.

##### `:validate`

If you set the `:validate` option to `false`, then associated objects will not be validated whenever you save this object. By default, this is `true`: associated objects will be validated when this object is saved.

#### Scopes for `has_many`

There may be times when you wish to customize the query used by `has_many`. Such customizations can be achieved via a scope block. For example:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, -> { where processed: true }
end
```

You can use any of the standard [querying methods](active_record_querying.html) inside the scope block. The following ones are discussed below:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `uniq`

##### `where`

The `where` method lets you specify the conditions that the associated object must meet.

```ruby
class Customer < ActiveRecord::Base
  has_many :confirmed_orders, -> { where "confirmed = 1" },
    class_name: "Order"
end
```

You can also set conditions via a hash:

```ruby
class Customer < ActiveRecord::Base
  has_many :confirmed_orders, -> { where confirmed: true },
                              class_name: "Order"
end
```

If you use a hash-style `where` option, then record creation via this association will be automatically scoped using the hash. In this case, using `@customer.confirmed_orders.create` or `@customer.confirmed_orders.build` will create orders where the confirmed column has the value `true`.

##### `extending`

The `extending` method specifies a named module to extend the association proxy. Association extensions are discussed in detail <a href="#association-extensions">later in this guide</a>.

##### `group`

The `group` method supplies an attribute name to group the result set by, using a `GROUP BY` clause in the finder SQL.

```ruby
class Customer < ActiveRecord::Base
  has_many :line_items, -> { group 'orders.id' },
                        through: :orders
end
```

##### `includes`

You can use the `includes` method to specify second-order associations that should be eager-loaded when this association is used. For example, consider these models:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders
end

class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :line_items
end

class LineItem < ActiveRecord::Base
  belongs_to :order
end
```

If you frequently retrieve line items directly from customers (`@customer.orders.line_items`), then you can make your code somewhat more efficient by including line items in the association from customers to orders:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, -> { includes :line_items }
end

class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :line_items
end

class LineItem < ActiveRecord::Base
  belongs_to :order
end
```

##### `limit`

The `limit` method lets you restrict the total number of objects that will be fetched through an association.

```ruby
class Customer < ActiveRecord::Base
  has_many :recent_orders,
    -> { order('order_date desc').limit(100) },
    class_name: "Order",
end
```

##### `offset`

The `offset` method lets you specify the starting offset for fetching objects via an association. For example, `-> { offset(11) }` will skip the first 11 records.

##### `order`

The `order` method dictates the order in which associated objects will be received (in the syntax used by an SQL `ORDER BY` clause).

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

If you use the `readonly` method, then the associated objects will be read-only when retrieved via the association.

##### `select`

The `select` method lets you override the SQL `SELECT` clause that is used to retrieve data about the associated objects. By default, Rails retrieves all columns.

WARNING: If you specify your own `select`, be sure to include the primary key and foreign key columns of the associated model. If you do not, Rails will throw an error.

##### `distinct`

Use the `distinct` method to keep the collection free of duplicates. This is
mostly useful together with the `:through` option.

```ruby
class Person < ActiveRecord::Base
  has_many :readings
  has_many :posts, through: :readings
end

person = Person.create(name: 'John')
post   = Post.create(name: 'a1')
person.posts << post
person.posts << post
person.posts.inspect # => [#<Post id: 5, name: "a1">, #<Post id: 5, name: "a1">]
Reading.all.inspect  # => [#<Reading id: 12, person_id: 5, post_id: 5>, #<Reading id: 13, person_id: 5, post_id: 5>]
```

In the above case there are two readings and `person.posts` brings out both of 
them even though these records are pointing to the same post.

Now let's set `distinct`:

```ruby
class Person
  has_many :readings
  has_many :posts, -> { distinct }, through: :readings
end

person = Person.create(name: 'Honda')
post   = Post.create(name: 'a1')
person.posts << post
person.posts << post
person.posts.inspect # => [#<Post id: 7, name: "a1">]
Reading.all.inspect  # => [#<Reading id: 16, person_id: 7, post_id: 7>, #<Reading id: 17, person_id: 7, post_id: 7>]
```

In the above case there are still two readings. However `person.posts` shows 
only one post because the collection loads only unique records.

If you want to make sure that, upon insertion, all of the records in the 
persisted association are distinct (so that you can be sure that when you 
inspect the association that you will never find duplicate records), you should 
add a unique index on the table itself. For example, if you have a table named 
``person_posts`` and you want to make sure all the posts are unique, you could 
add the following in a migration:

```ruby
add_index :person_posts, :post, :unique => true
```

Note that checking for uniqueness using something like ``include?`` is subject 
to race conditions. Do not attempt to use ``include?`` to enforce distinctness 
in an association. For instance, using the post example from above, the 
following code would be racy because multiple users could be attempting this 
at the same time:

```ruby
person.posts << post unless person.posts.include?(post)
```

#### When are Objects Saved?

When you assign an object to a `has_many` association, that object is automatically saved (in order to update its foreign key). If you assign multiple objects in one statement, then they are all saved.

If any of these saves fails due to validation errors, then the assignment statement returns `false` and the assignment itself is cancelled.

If the parent object (the one declaring the `has_many` association) is unsaved (that is, `new_record?` returns `true`) then the child objects are not saved when they are added. All unsaved members of the association will automatically be saved when the parent is saved.

If you want to assign an object to a `has_many` association without saving the object, use the `collection.build` method.

### `has_and_belongs_to_many` Association Reference

The `has_and_belongs_to_many` association creates a many-to-many relationship with another model. In database terms, this associates two classes via an intermediate join table that includes foreign keys referring to each of the classes.

#### Methods Added by `has_and_belongs_to_many`

When you declare a `has_and_belongs_to_many` association, the declaring class automatically gains 13 methods related to the association:

* `collection(force_reload = false)`
* `collection<<(object, ...)`
* `collection.delete(object, ...)`
* `collection.destroy(object, ...)`
* `collection=objects`
* `collection_singular_ids`
* `collection_singular_ids=ids`
* `collection.clear`
* `collection.empty?`
* `collection.size`
* `collection.find(...)`
* `collection.where(...)`
* `collection.exists?(...)`
* `collection.build(attributes = {})`
* `collection.create(attributes = {})`

In all of these methods, `collection` is replaced with the symbol passed as the first argument to `has_and_belongs_to_many`, and `collection_singular` is replaced with the singularized version of that symbol. For example, given the declaration:

```ruby
class Part < ActiveRecord::Base
  has_and_belongs_to_many :assemblies
end
```

Each instance of the part model will have these methods:

```ruby
assemblies(force_reload = false)
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=objects
assembly_ids
assembly_ids=ids
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
```

##### Additional Column Methods

If the join table for a `has_and_belongs_to_many` association has additional columns beyond the two foreign keys, these columns will be added as attributes to records retrieved via that association. Records returned with additional attributes will always be read-only, because Rails cannot save changes to those attributes.

WARNING: The use of extra attributes on the join table in a `has_and_belongs_to_many` association is deprecated. If you require this sort of complex behavior on the table that joins two models in a many-to-many relationship, you should use a `has_many :through` association instead of `has_and_belongs_to_many`.


##### `collection(force_reload = false)`

The `collection` method returns an array of all of the associated objects. If there are no associated objects, it returns an empty array.

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

The `collection<<` method adds one or more objects to the collection by creating records in the join table.

```ruby
@part.assemblies << @assembly1
```

NOTE: This method is aliased as `collection.concat` and `collection.push`.

##### `collection.delete(object, ...)`

The `collection.delete` method removes one or more objects from the collection by deleting records in the join table. This does not destroy the objects.

```ruby
@part.assemblies.delete(@assembly1)
```

WARNING: This does not trigger callbacks on the join records.

##### `collection.destroy(object, ...)`

The `collection.destroy` method removes one or more objects from the collection by running `destroy` on each record in the join table, including running callbacks. This does not destroy the objects.

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=objects`

The `collection=` method makes the collection contain only the supplied objects, by adding and deleting as appropriate.

##### `collection_singular_ids`

The `collection_singular_ids` method returns an array of the ids of the objects in the collection.

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=ids`

The `collection_singular_ids=` method makes the collection contain only the objects identified by the supplied primary key values, by adding and deleting as appropriate.

##### `collection.clear`

The `collection.clear` method removes every object from the collection by deleting the rows from the joining table. This does not destroy the associated objects.

##### `collection.empty?`

The `collection.empty?` method returns `true` if the collection does not contain any associated objects.

```ruby
<% if @part.assemblies.empty? %>
  This part is not used in any assemblies
<% end %>
```

##### `collection.size`

The `collection.size` method returns the number of objects in the collection.

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

The `collection.find` method finds objects within the collection. It uses the same syntax and options as `ActiveRecord::Base.find`. It also adds the additional condition that the object must be in the collection.

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

The `collection.where` method finds objects within the collection based on the conditions supplied but the objects are loaded lazily meaning that the database is queried only when the object(s) are accessed. It also adds the additional condition that the object must be in the collection.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

The `collection.exists?` method checks whether an object meeting the supplied conditions exists in the collection. It uses the same syntax and options as `ActiveRecord::Base.exists?`.

##### `collection.build(attributes = {})`

The `collection.build` method returns a new object of the associated type. This object will be instantiated from the passed attributes, and the link through the join table will be created, but the associated object will _not_ yet be saved.

```ruby
@assembly = @part.assemblies.build({assembly_name: "Transmission housing"})
```

##### `collection.create(attributes = {})`

The `collection.create` method returns a new object of the associated type. This object will be instantiated from the passed attributes, the link through the join table will be created, and, once it passes all of the validations specified on the associated model, the associated object _will_ be saved.

```ruby
@assembly = @part.assemblies.create({assembly_name: "Transmission housing"})
```

#### Options for `has_and_belongs_to_many`

While Rails uses intelligent defaults that will work well in most situations, there may be times when you want to customize the behavior of the `has_and_belongs_to_many` association reference. Such customizations can easily be accomplished by passing options when you create the association. For example, this association uses two such options:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, uniq: true,
                                       read_only: true
end
```

The `has_and_belongs_to_many` association supports these options:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

By convention, Rails assumes that the column in the join table used to hold the foreign key pointing to the other model is the name of that model with the suffix `_id` added. The `:association_foreign_key` option lets you set the name of the foreign key directly:

TIP: The `:foreign_key` and `:association_foreign_key` options are useful when setting up a many-to-many self-join. For example:

```ruby
class User < ActiveRecord::Base
  has_and_belongs_to_many :friends, 
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

If you set the `:autosave` option to `true`, Rails will save any loaded members and destroy members that are marked for destruction whenever you save the parent object.

##### `:class_name`

If the name of the other model cannot be derived from the association name, you can use the `:class_name` option to supply the model name. For example, if a part has many assemblies, but the actual name of the model containing assemblies is `Gadget`, you'd set things up this way:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

By convention, Rails assumes that the column in the join table used to hold the foreign key pointing to this model is the name of this model with the suffix `_id` added. The `:foreign_key` option lets you set the name of the foreign key directly:

```ruby
class User < ActiveRecord::Base
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

If the default name of the join table, based on lexical ordering, is not what you want, you can use the `:join_table` option to override the default.

##### `:validate`

If you set the `:validate` option to `false`, then associated objects will not be validated whenever you save this object. By default, this is `true`: associated objects will be validated when this object is saved.

#### Scopes for `has_and_belongs_to_many`

There may be times when you wish to customize the query used by `has_and_belongs_to_many`. Such customizations can be achieved via a scope block. For example:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

You can use any of the standard [querying methods](active_record_querying.html) inside the scope block. The following ones are discussed below:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `uniq`

##### `where`

The `where` method lets you specify the conditions that the associated object must meet.

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

You can also set conditions via a hash:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

If you use a hash-style `where`, then record creation via this association will be automatically scoped using the hash. In this case, using `@parts.assemblies.create` or `@parts.assemblies.build` will create orders where the `factory` column has the value "Seattle".

##### `extending`

The `extending` method specifies a named module to extend the association proxy. Association extensions are discussed in detail <a href="#association-extensions">later in this guide</a>.

##### `group`

The `group` method supplies an attribute name to group the result set by, using a `GROUP BY` clause in the finder SQL.

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

You can use the `includes` method to specify second-order associations that should be eager-loaded when this association is used.

##### `limit`

The `limit` method lets you restrict the total number of objects that will be fetched through an association.

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

The `offset` method lets you specify the starting offset for fetching objects via an association. For example, if you set `offset(11)`, it will skip the first 11 records.

##### `order`

The `order` method dictates the order in which associated objects will be received (in the syntax used by an SQL `ORDER BY` clause).

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

If you use the `readonly` method, then the associated objects will be read-only when retrieved via the association.

##### `select`

The `select` method lets you override the SQL `SELECT` clause that is used to retrieve data about the associated objects. By default, Rails retrieves all columns.

##### `uniq`

Use the `uniq` method to remove duplicates from the collection.

#### When are Objects Saved?

When you assign an object to a `has_and_belongs_to_many` association, that object is automatically saved (in order to update the join table). If you assign multiple objects in one statement, then they are all saved.

If any of these saves fails due to validation errors, then the assignment statement returns `false` and the assignment itself is cancelled.

If the parent object (the one declaring the `has_and_belongs_to_many` association) is unsaved (that is, `new_record?` returns `true`) then the child objects are not saved when they are added. All unsaved members of the association will automatically be saved when the parent is saved.

If you want to assign an object to a `has_and_belongs_to_many` association without saving the object, use the `collection.build` method.

### Association Callbacks

Normal callbacks hook into the life cycle of Active Record objects, allowing you to work with those objects at various points. For example, you can use a `:before_save` callback to cause something to happen just before an object is saved.

Association callbacks are similar to normal callbacks, but they are triggered by events in the life cycle of a collection. There are four available association callbacks:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

You define association callbacks by adding options to the association declaration. For example:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, before_add: :check_credit_limit

  def check_credit_limit(order)
    ...
  end
end
```

Rails passes the object being added or removed to the callback.

You can stack callbacks on a single event by passing them as an array:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(order)
    ...
  end

  def calculate_shipping_charges(order)
    ...
  end
end
```

If a `before_add` callback throws an exception, the object does not get added to the collection. Similarly, if a `before_remove` callback throws an exception, the object does not get removed from the collection.

### Association Extensions

You're not limited to the functionality that Rails automatically builds into association proxy objects. You can also extend these objects through anonymous modules, adding new finders, creators, or other methods. For example:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders do
    def find_by_order_prefix(order_number)
      find_by_region_id(order_number[0..2])
    end
  end
end
```

If you have an extension that should be shared by many associations, you can use a named extension module. For example:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Customer < ActiveRecord::Base
  has_many :orders, -> { extending FindRecentExtension }
end

class Supplier < ActiveRecord::Base
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

Extensions can refer to the internals of the association proxy using these three attributes of the `proxy_association` accessor:

* `proxy_association.owner` returns the object that the association is a part of.
* `proxy_association.reflection` returns the reflection object that describes the association.
* `proxy_association.target` returns the associated object for `belongs_to` or `has_one`, or the collection of associated objects for `has_many` or `has_and_belongs_to_many`.





      