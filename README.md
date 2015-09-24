![Build Status](https://img.shields.io/travis/HealthHero/humanapi.svg)
![Gem Version](https://img.shields.io/gem/v/health_hero-human_api.svg)

# HumanApi

This is Health Hero's fork of the HumanApi gem.  The original gem (`human_api`) is found at [https://github.com/humanapi/humanapi](https://github.com/humanapi/humanapi).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'health_hero-human_api'
```

#### Requirements

- Ruby 2.0+
- Activesupport
- Activerecord if hooking into User model

## Configuration

### Initializer

```ruby
HumanApi.config do |c|
  c.app_id        = ENV['HUMANAPI_KEY']
  c.query_key     = ENV['HUMANAPI_SECRET']
  c.client_secret = ENV['HUMANAPI_CLIENT_SECRET']  

  # Optional:
  # If a Nestful::UnauthorizedAccess error occurs, this proc will handle it:
  c.handle_access_error = ->e,context { Airbrake.notify e; do_something_with(context) }

  # If you don't want to handle it, and want it raised:
  # (Note - if you set a proc above, this setting is ignored)
  c.raise_access_errors = true # Default is false
end
```

### User model

```ruby
class User < ActiveRecord::Base
  ...

  humanizable :get_the_token

  def get_the_token
    # the code to reach the token - attribute, association, Redis, etc.
  end
end
```

You can also configure it the initializer:

```ruby
HumanApi.config do |c|
  ...
  # This is the part where the magics happen
  c.human_model       = User           # Tell me what is the model you want to use
  c.token_method_name = :human_token   # Tell me the method you use to retrieve the token (Inside the human_model)
end
```

It should work both ways, the choice is yours.

## Usage
Once you did the configuration, the usage of the gem is quite easy:

```ruby
u = User.first
u.human.profile            # => Will return the humanapi user's profile
u.human.query(:activities) # => Will return everything you asked for (as an array of hashes)
```

Just use the _human_ instance method from your User instance and that's it

### The query method
The query method is meant to ask whatever you want whenever you want. Here are some permitted methods (according to humanapi) you can use to retrieve user's data:

```ruby
:profile
:activities
:blood_glucose
:blood_pressure
:body_fat
:genetic_traits
:heart_rate
:height
:locations
:sleeps
:weight
:bmi
:sources
```

### Query Options
Mixing up these methods with some options will give you what you want:

```ruby
u.human.query(:activities, summary: true)  #=> will give you a summary of the activities
u.human.query(:sleeps, date: "2014-01-01") #=> Will give you a single sleep measurement
u.human.query(:weight)                     #=> Will give you a single weight value

# Return metadata (not just the array of hashes)
u.human.query(:activities, return_metadata: true) #=> Nestful::Response object, with headers and body available

# Manual offset/limit:
u.human.query(:activities, limit: 3, offset: 50).count #=> 3

# Return all of a user's data jammed together, despite being across multiple pages:
u.human.query(:activities).count                  #=> 50
u.human.query(:activities, fetch_all: true).count #=> 321

# Return all of a user's data jammed together, and handle unauthorized errors:
u.human.query(:activities, fetch_all: true, handle_access_error: ->error, context { do_something_with(error, context)})
```

Lastly, as a common rule, I've identified a pattern in humanapis.
- If the method name is plural, it will give you multiple measurements when calling it. In addition, you can ask for a summary: true, for a group of value in a specific date: "DATE" or for a single known measurement id: "measurement_id"

## Common errors and troubleshooting

- `rewrite_human_model`: Could not find `token` in `User`
  - Causes: It means that the method you suggested as `:humanizable` does not exist!
  - What to check: Check if you misspelled the method name or the attribute does not exist.
  - Solving: If this does not solve, try using the `:humanizable` function passing a method you can create in your model to retrieve manually just the token.
