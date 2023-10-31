WIP, current task: extract code from legacy project

# ProcessableQueue

Main idea is to process collection of objects with multiple threads in parallel. 

- it will start new thread for each object in collection (up to the limit, by default 40 threads). When thread copmplete processing item it will pick next from the queue
- it autoscale number of threads automaticaly
- it will replece dead thread with helthy one if exception happens
- thread can add new objects to collection
- queue access is concurent, protected by mutex

Basic usage:
```
processor = proc {|item| p item} # it can be any object which respons to #call(arg1)
items = [1,2,3]

ProcessableQueue.process(processor, items)
# 1
# 2
# 3
=> true
```

Update queue from process example:
```
items = [1,2,3]
queue = ProcessableQueue::ConcurrentSet.new
queue.push(items)

processor = proc do |item| 
    if item.odd?
        queue.push(item + 1)
    end
    p item 
end

ProcessableQueue::Queue.new(processor, queue).process
# 1
# 2
# 3
# 4
=> true
```


## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/processable_queue.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
