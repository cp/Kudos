Kudos
=====

JSON API for tracking Kudos count of posts on a Svbtle blog. Uses light caching to remove unnecessary stress from Svbtle.

## Usage

It will return the last few posts on the blog. You will need to pass the 

### Example

GET `/blog?url=aley.me`:

  * `title`: Title of the post
  * `url`: URL of the post.
  * `kudos`: Kudos count.

## Todo

* Pretiter errors
* Handle blogs that use Feedburner.