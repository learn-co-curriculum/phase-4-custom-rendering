# Custom Rendering

## Learning Goals

- Render JSON from a Rails controller
- Select specific model attributes to render in a Rails controller
- Render a custom error message

## Setup

Fork and clone this repo, then run:

```console
$ bundle install
$ rails db:migrate db:seed
```

This will download all the dependencies for our app and set up the database.

## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/N5_l1a-3OV8?rel=0&showinfo=0" frameborder="0" allowfullscreen></iframe>

## Introduction

By using `render json:` in our Rails controller, we can take entire models or
even collections of models, have Rails convert them to JSON, and send them out
on request. We already have the makings of a basic API. In this lesson, we're
going to look at shaping that data that gets converted to JSON and making it
more useful to us from the frontend JavaScript perspective.

The way we structure our data matters — it can lead to better, simpler code in
the future. By specifically defining what data is being sent via a Rails
controller, we have full control over what data our frontend has access to.

## Removing Content When Rendering

Sometimes, when sending JSON data, such as an entire model, we don't want or
need to send the entire thing. Some data is sensitive, for instance. An API that
sends user information might contain details of a user internally that it does
not want to ever share externally. Sometimes, data is just extra clutter we
don't need. For instance, if we visit `http://localhost:3000/cheeses/2`, here's
the JSON response we receive:

```json
{
  "id": 2,
  "name": "Pepper Jack",
  "price": 4,
  "is_best_seller": true,
  "created_at": "2021-05-01T11:11:03.879Z",
  "updated_at": "2021-05-01T11:11:03.879Z"
}
```

By default, using `render json:` will include all the attributes from our Active
Record model that are defined in its schema. But for our frontend purposes, we
probably don't need things like `created_at` and `updated_at`. Rather than send
this unnecessary info when rendering, we could just pick and choose what we want
to send:

```ruby
def show
  cheese = Cheese.find_by(id: params[:id])
  render json: {
    id: cheese.id,
    name: cheese.name,
    price: cheese.price,
    is_best_seller: cheese.is_best_seller
  }
end
```

Here, we've created a new hash out of four keys, assigning the keys manually
with the attributes of `cheese`.

The result is that when we visit a specific cheese's endpoint, like
`http://localhost:3000/cheeses/2`, we'll see just the id, name, price, and best
seller properties:

```json
{
  "id": 2,
  "name": "Pepper Jack",
  "price": 4,
  "is_best_seller": true
}
```

To simplify this process, we can take advantage of some built-in _serialization_
options available to us in the `render` method. For example, we can use the
`only:` option directly after listing an object or array of objects we want to
render to JSON:

```rb
def index
  cheeses = Cheese.all
  render json: cheeses, only: [:id, :name, :price, :is_best_seller]
end
```

Visiting `http://localhost:3000/cheeses` will now produce our array
of cheese objects and each object will _only_ have the `id`, `name`, `price`,
and `is_best_seller` values, leaving out everything else:

```json
[
  {
    "id": 1,
    "name": "Cheddar",
    "price": 3,
    "is_best_seller": true
  },
  {
    "id": 2,
    "name": "Pepper Jack",
    "price": 4,
    "is_best_seller": true
  },
  {
    "id": 3,
    "name": "Limburger",
    "price": 8,
    "is_best_seller": false
  }
]
```

Alternatively, rather than specifically listing every key we want to include, we
could also exclude particular content using the `except:` option, like so:

```rb
def index
  cheeses = Cheese.all
  render json: cheeses, except: [:created_at, :updated_at]
end
```

The above code would achieve the same result, producing only `id`, `name`,
`price`, and `is_best_seller` for each cheese. All the keys _except_
`created_at` and `updated_at`.

Both the `only` and `except` options are available to us thanks to the
[`.as_json`][as_json] method, which Rails uses internally when we call
`render json:` with an Active Record object.

## Extending JSON Data with :methods

If you'll recall from previous lessons, we added one additional instance method
to our `Cheese` model:

```rb
class Cheese < ApplicationRecord

  def summary
    "#{name}: $#{price}"
  end

end
```

If we wanted to include that `summary` in the JSON response, we can do so
using the `methods` option, like so:

```rb
def show
  cheese = Cheese.find_by(id: params[:id])
  render json: cheese, except: [:created_at, :updated_at], methods: [:summary]
end
```

With that code in place, our JSON response contains an additional key-value
pair, in which the key is the name of the method and the value is the result of
calling the method for the current `Cheese` object:

```json
{
  "id": 1,
  "name": "Cheddar",
  "price": 3,
  "is_best_seller": true,
  "summary": "Cheddar: $3"
}
```

## Basic Error Messaging When Rendering JSON Data

With the power to create our own APIs, we also have the power to define what to
do when things go wrong. In our `show` action, we are currently using
`Cheese.find_by`, passing in `id: params[:id]`:

```rb
def show
  cheese = Cheese.find_by(id: params[:id])
  render json: cheese, except: [:created_at, :updated_at], methods: [:summary]
end
```

When using `find_by`, if the record is not found, `nil` is returned. As we have
it set up, if `params[:id]` does not match a valid id, `nil` will be assigned to
the `cheese` variable.

As `nil` is a _false-y_ value in Ruby, this gives us the ability to write our
own error messaging in the event that a request is made for a record that
doesn't exist:

```ruby
def show
  cheese = Cheese.find_by(id: params[:id])
  if cheese
    render json: cheese, except: [:created_at, :updated_at], methods: [:summary]
  else
    render json: { error: 'Cheese not found' }
  end
end
```

Now, if we were to send a request to an invalid endpoint like
`http://localhost:3000/cheeses/hello_cheeses`, rather than receiving a general
HTTP error, we would still receive a response from the API:

```json
{
  "error": "Cheese not found"
}
```

From here, we could build a more complex response, including additional details
about what might have occurred. We could even include a status code that follows
HTTP conventions to indicate what went wrong:

```rb
def show
  cheese = Cheese.find_by(id: params[:id])
  if cheese
    render json: cheese, except: [:created_at, :updated_at], methods: [:summary]
  else
    # status: :not_found will produce a 404 status code
    render json: { error: 'Cheese not found' }, status: :not_found
  end
end
```

Adding this status code won't change how the JSON data looks, but it will give
the client some additional information about what went wrong with this request.

## Conclusion

We can now take the instances of a model and render them to JSON, extracting out
any specific content we do or do not want to send!

Whether you are building a professional API for a company or for your own
personal site, having the ability to fine tune how your data looks is a critical
skill that we're only just beginning to scratch the surface on.

In future lessons, we'll cover the topic of _serialization_ in more depth, and
introduce some additional tools to make it easier to customize the shape of our
JSON response.

## Check For Understanding

Before you move on, make sure you can answer the following questions:

1. Why is it important to be able to customize the JSON that is returned by our
   apps?
2. What are some options we can use with the `render` method to customize the
   JSON response?

## Resources

- [ActiveRecord as_json method][as_json]

[as_json]: https://api.rubyonrails.org/classes/ActiveModel/Serializers/JSON.html
