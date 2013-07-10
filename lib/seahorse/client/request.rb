# Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

module Seahorse
  class Client

    # Represents a single web service request.
    #
    # # Building a Request
    #
    # You should not need to construct a Request object directly.  They
    # are generally constructed by a {Client}.  Normally the client will
    # build and send a {Request}, returning only the resultant {Response}.
    #
    # You can ask a client to build (and not send a request) by calling
    # {Client#build_request}.  This can be useful if you need to send the
    # same request multiple times or if you need to add additional
    # event listeners to the request.
    #
    #     req = client.build_request(:request_name, request_params)
    #     req.send
    #     #=> #<Seahorse::Client::Response...>
    #
    # # Request Lifecycle
    #
    # When you {#send} a request, it will emit a sequence of events.
    # The {#send} method will either return a successful response or will
    # raise an error.  Between the call to {#send} and the final result,
    # a sequence of events will be emitted.  A successful request will
    # emit the following events:
    #
    # * `:validate`
    # * `:build`
    # * `:sign`
    # * `:send`
    # * `:http_headers`
    # * `:http_data`
    # * `:http_done`
    # * `:parse`
    # * `:success`
    # * `:complete`
    #
    # # Registering Event Listeners
    #
    # You can register callbacks for events via the {#on} method.  Specify
    # the name of the event, and pass a callable object or block.
    #
    class Request

      # @param [Hash] params
      # @api private
      def initialize(params = {})
        @params = params
        @events = EventEmitter.new
      end

      # @return [Hash]
      attr_reader :params

      # @return [EventEmitter]
      attr_reader :events

      # Sends this request, returning a response or raising an error
      # if the request fails for any reason.  Calling this method
      # multiple times will send multiple requests.
      # @return [Response]
      def send

        http_request = Http::Request.new

        resp = Response.new
        events.emit(:validate, params)
        events.emit(:build, http_request, params)
        events.emit(:sign, http_request)
        events.emit(:send)
        events.emit(:parse)
        events.emit(:success)
        events.emit(:complete)
        resp
      end

      # Registers an event listeners for the named event.
      # @param (see EventEmitter#on)
      # @return (see EventEmitter#on)
      # @see EventEmitter#on
      def on(event_name, listener = nil, &block)
        events.on(event_name, listener, &block)
      end

    end
  end
end
