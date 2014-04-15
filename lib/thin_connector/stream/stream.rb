module ThinConnector
  module Stream

    MAX_RECONNECT_SECONDS = 60 * 5

    def max_reconnect_time
      ThinConnector::Environment.max_reconnect_time || MAX_RECONNECT_SECONDS
    end
  end
end