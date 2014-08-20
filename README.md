#Welcome to the Ruby Thin Connector!
This is a sample app which connects to the Gnip set of streaming APIs in Ruby. The application is broken down into three basic elements:
 - A ```GnipStream``` which connects to the HTTP endpoint and buffers the streaming JSON
 - A set of processors which accept a ```Stream``` object and take action accordingly

Some key notes about this design are as follows:
 1. Modularity: We try to do our best to keep clean separation between different logical pieces of the app. Logical blocks include:
    - Incoming stream handling
    - Stream processing
    - Application configuration

 2. Non blocking IO: We use an EventMachine reactor to asynchronously handle the incoming HTTP chunks. It is important that we not block on incoming data.

 3. Logging: We log as much relevant data as possible. If this were a production application, we would want to be able to trace what happened when without digging into live code.

 4. Reconnection logic: Sometimes the stream will fail on us. We handle this gracefully by backing off the stream exponentially, and attempting to reconnect until we are successful.

##Requirements

 - Ruby 2.1.1
 - Bundler
 - [Redis](http://www.redis.io) (optional)
 - [MongoDB](http://www.mongodb.org) (optional)
 - Access to PowerTrack or Decahose stream

##Running

To get the REPL running, run the following commands from the project directory
```bash
bundle install
./start
```

From there, you can type ```help``` to get a list of commands


##Whats Next?
Now that you can access the data, where do you go from here? The world is your
oyster, and we can't wait to see what you do next. There are a few things to keep
in mind however. Getting the data in the door is just the first step, proper storage
of the data for purposes of keeping in compliance is important. The easiest
way to achieve this is to make sure to keep record of both the individual Tweet ids
and user ids, to facilitate removing tweets when necessary.

##LICENCE
Refer to the LICENCE file
