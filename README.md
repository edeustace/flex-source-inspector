## Flex Source Inspector

given a source folder and an array of link reports, it will return a list of files that are NOT declared in the link reports.

### Usage
    flex-source-inpsector inspect /path/to/flex-src linkreport_one.xml [...linkreport_n.xml]
    
    
### Building
read: https://github.com/radar/guides/blob/master/gem-development.md

### Run Tests
    rspec spec/flex-source-inspector_spec.rb

### Install Gem Locally
    rake install
    
### Publish
    gem push (to sign in)
    rake release