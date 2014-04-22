module ThinConnector
  module Rules

    class RuleClient

      #  For reference:

      #  public boolean addRules(Rules rules) {
      # boolean success = false;
      # try {
      #   httpClient.postResourceFor(
      #       uriStrategy.createRulesUri(
      #           environment.accountName(),
      #           environment.streamLabel()), rules.build());
      #   success = true;
      # } catch (IOException | GnipConnectionException e) {
      #     logger.error("Error adding rule on stream", e);
      # }
      # return success;
      # }
      #

      def self.add_rules(rules)
        client.post
      end

      def self.add_rule(rule)
        add_rules [rule]
      end

      def self.delete_rules(rules)

      end

      def self.delete_rule(rule)
        delete_rules [rule]
      end

      def self.list_rules

      end

      private

      def create_rule_uri

      end

      def client
        ThinConnector::GnipHTTPClient.new
      end

      def create_rules_uri_for_account(account_name, stream_label); "https://api.gnip.com:443/accounts/#{ThinConnector::Environment.instance.gnip_account}/publishers/twitter/streams/track/#{ThinConnector::Environment.instance.gnip_stream_label}/rules.json"; end

    end

  end
end