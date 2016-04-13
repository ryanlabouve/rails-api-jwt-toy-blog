# JWT Rails API Challenge

Here's the goal:

	 Rails API that has secure resources (via JWT) and non-secure resources and is JSON API compliant.

Our scenario: We have a blog that has public posts, accessible by anyone, and private posts, only accessible to users who are logged in.


Notes:

* Posts will be a base class for PrivatePosts and PublicPosts.
* JWT authentication will be implemented using [knock](https://github.com/nsarno/knock)
* JSON API compliance will be accomplished via [JSONAPI::Resources](https://github.com/cerebris/jsonapi-resources)
* I'll link out to relevant tests, with comments on what's being test, but try to keep the article terse.

Let's get started `rails-api new rails-api-jwt-toy-blog`.

## The Models

For the schema, we want `Post(title:string, body:text, type:string` where type will for STI.

(For more on single-table inheritance, check out (this post)[http://blog.arkency.com/2013/07/sti/])

 
### Post Model

```
rails g model Post title:string body:text type:string
touch app/models/private_post.rb
touch app/models/public_post.rb
```

Then I went ahead and setup public post and private post as subclasses. This will come in handy later when we setup our resources.

```
# app/models/public_post.rb
class PublicPost < Post; end
```

and

```
# app/models/private_post.rb
class PrivatePost < Post; end
```

([checkpoint](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/commit/3af0e6beb70ce67d86d90143d5d57bdd93a85bd4)

1. Setup fixture ([code](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/blob/7f3fae7d334498a3063508de38b7cf9435c99942/test/fixtures/posts.yml))
2. Unit test on `Post` model ([code](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/blob/4ede77c0c845ad30fdf48b54a71015eded3ce8f9/test/models/post_test.rb))
3. Implement Post Model ([code](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/blob/4ede77c0c845ad30fdf48b54a71015eded3ce8f9/app/models/post.rb))

```
class Post < ActiveRecord::Base
  validates :body, presence: true
  validates :title, presence: true
  validates :type, presence: true

  POST_TYPES = %w(PublicPost PrivatePost)
  validates :type, :inclusion => { :in => POST_TYPES }
end
```

### User Resource

Here we want a `User` model that implements Rail's [`has_secure_password`](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html
). Using `has_secure_password`, When we create a `User`, we'll pass in a `password` and `password_confirmation`, rails will then encrypt and save as `password_digest`.

You'll need to add `gem 'bcrypt'` to your Gemfile if you are using Rails API for `has_secure_password` to work.

For the schema, we want `User(email:string, name:email, password_digest:string` where `password_digest` is for `has_secure_password`.

```
rails g model user password_digest:string name:string email:string
```

([checkpoint](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/commit/7f8591ccb6a51a58f8f957780afd4f092ca2eea7))

1. Setup fixtures ([code](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/blob/7de80841d0c69911afda1153e6e85194a1069574/test/fixtures/users.yml))
2. Setup unit test ([code](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/blob/7de80841d0c69911afda1153e6e85194a1069574/test/models/user_test.rb))
3. Implement `User` model ([code](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/commit/7de80841d0c69911afda1153e6e85194a1069574))

```
class User < ActiveRecord::Base
  has_secure_password
  
  validates :name, presence: true
  validates :email, presence: true
end
```
 
### Seeding Posts and Users

So now, to give us some posts and users to play with, we'll create some seeds.

Go ahead and add `gem 'faker'` to your Gemfile and `bundle install`.

```
# db/seeds.rb
Post.destroy_all
User.destroy_all

User.create!({
  name: 'Lester Tester',
  email: 'test@user.com',
  password: 'test1234',
  password_confirmation: 'test1234'
})

100.times do
  PublicPost.create!(
    title: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraphs
  )

  PrivatePost.create!(
    title: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraphs
  )
end
```

## Controllers and Resources and Routing Oh My!

Now's when we'll need to introduce [JSONAPI::Resources](https://github.com/cerebris/jsonapi-resources) by adding `gem 'jsonapi-resources'` to your gemfile.

### Public Posts

1. Generate your controller and write tests for `PublicPosts`

`rails g controller PublicPosts`.

And then set it up as a JSONAPI::Resources controller:

```
# app/controllers/public_posts_controller.rb
class PublicPostsController < ApplicationController
  include JSONAPI::ActsAsResourceController
end
```

Next, let's write the tests for the `PublicPosts`.

We want to `GET /public-posts` and get a list of the public posts, and `GET /public-posts/:id` to show a single post. Then, we should not be able to create, edit or delete. (Here are the tests: [code](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/blob/6294ceaaac4b78b3b7805a1d2fcc207e99318f50/test/controllers/public_posts_controller_test.rb))

2. Generate `PublicPosts` resource and add to your routes.rb.

`rails generate jsonapi:resource public_posts`

```
class PublicPostResource < JSONAPI::Resource
  immutable
  attributes :title, :body
end
```

and then in routes

```
# config/routes.rb
jsonapi_resources :public_posts
```

Yay, passing tests! Now let's move onto our private posts.

### Private Posts

We are using [Knock](https://github.com/nsarno/knock) to do JWT auth. Let's go ahead and set that up.

Add `gem 'knock'` to your Gemfile and `bundle install`.

run `rails generate knock:install`. This will add `config/initializers/knock.rb`, which you may want to peruse the comments.

Mount the engine in your `routes.rb`. 

```
# config/routes.rb
...
mount Knock::Engine => "/knock"
...
```

Add the `Knock::Authenticable` module in ApplicationController

```
class ApplicationController < ActionController::API
  include Knock::Authenticable
end
```

Then later we will be able to add `before_action :authenticate` to our `PrivatePosts` controller.

([code checkpoint](https://github.com/ryanlabouve/rails-api-jwt-toy-blog/commit/2fd20fce149887ce7cc4a7f3de0551eab210c528))

(There's a bit of duplication here from the previous section to setup private posts due to their similarity to public posts.)

1. Generate your controller and write tests for `Private Posts`

`rails g controller PrivatePosts`.

And then set it up as a JSONAPI::Resources controller:

```
# app/controllers/private_posts_controller.rb
class PrivatePostsController < ApplicationController
  include JSONAPI::ActsAsResourceController
end
```

Next, let's write the tests for the `PublicPosts`.

We want to `GET /public-posts` for authorized users and a `401` for unathroized users. Same things for the show routes of `GET /public-posts/:id`. Then, we should not be able to create, edit or delete. (Here are the [tests]())

2. Generate `PrivatePosts` resource and add to your routes.rb.

`rails generate jsonapi:resource private_posts`

```
class PrivatePostResource < JSONAPI::Resource
  immutable
  attributes :title, :body
end
```

and then in routes

```
# config/routes.rb
...
jsonapi_resources :private_posts
...
```

Now it's time to circle back around to adding authentication to our `PrivatePosts`.

```
class PrivatePostsController < ApplicationController
  include JSONAPI::ActsAsResourceController
  before_filter :authenticate # added line
end
```

At this point, our tests are green and our challenge is complete!

Feel free to go [check out the project]()

## Curling for Sanity

I've included the [Paw](https://luckymarmot.com/paw) file in the project: [here]().

For the sake of being generic, below I'll walk through how this works via CURL. And, we'll assume you are running this project on port 3000. If you are not, you'll need to make slight adjustments below.

Don't forget, for this to be very satisfying, you'll need to seed the database by running `bundle exec rake db:seed`.

### GET /public-posts

Highlights: 

* Requst type of GET
* Header that needs to set `Content-Type: application/json` (which this will be the same for all calls for JSONAPI compliance)

```
curl -X "GET" "http://localhost:3000/public-posts/" \
	-H "Content-Type: application/json"
```

### GET /private-posts

If you try the same request on private posts, you'll get a `401`. This is actually a two part process.

#### Step 1: Auth

Highlights:

* POST
* Pass in the email and password of the user setup in [seeds](). 
* Knock expects the request to be wrapped in a json object called auth. [Check the docs](https://github.com/nsarno/knock#authenticating-from-a-web-or-mobile-application) for more, and don't forget to check out the config file knock generaged for more customization options.

```
curl -X "POST" "http://localhost:3000/knock/auth_token" \
	-H "Content-Type: application/json" \
	-d $'{"auth": {"email": "test@user.com", "password": "test1234"}}
```

Output will be something like:

```
HTTP/1.1 201 Created 

{"jwt":"eyJ0eXAiOiJKV1QiLCJhb..."}
```

The JWT token generated here is needed for the next request.

#### Step 2: Request private resource with token

Highlights:

* The header `Authorization: Bearer [token]` is what auths our request, using the toekn from the previous step
* Otherwise, it's the same request as the one for public-posts.

```
curl -X "GET" "http://localhost:3000/private-posts" \
	-H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJI....." \
	-H "Content-Type: application/json"
```
